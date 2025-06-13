# Harding Soccer Stats Scraper

An n8n workflow that scrapes Harding University's 2024 men's soccer season statistics and generates a comprehensive CSV file with game-by-game player data.

## Overview

This workflow extracts individual player statistics from each game of the 2024 season, creating a detailed dataset where each row represents one game for one player. The resulting CSV can be used for pivot analysis, performance tracking, and statistical analysis.

## Data Source

- **Team Page**: `https://static.hardingsports.com/custompages/msoc/2024/teamgbg.htm`
- **Player Pages**: `https://static.hardingsports.com/custompages/msoc/2024/plyr_{jersey}.htm`
- **Season**: 2024 Men's Soccer

## Workflow Architecture

```
Manual Trigger
    ↓
HTTP Request - Season Page
    ↓
HTML Extract - Roster Links
    ↓
Function - Parse Roster
    ↓
HTTP Request - Player Page (with Continue On Fail)
    ↓
HTML Extract - Player Stats
    ↓
Function - Parse Stats
    ↓
Create CSV File
```

## Node Details

### 1. Manual Trigger
- **Type**: `n8n-nodes-base.manualTrigger`
- **Purpose**: Workflow initiation

### 2. HTTP Request - Season Page
- **Type**: `n8n-nodes-base.httpRequest`
- **URL**: `https://static.hardingsports.com/custompages/msoc/2024/teamgbg.htm`
- **Response Format**: `string`
- **Purpose**: Fetch main team page containing player links

### 3. HTML Extract - Roster Links
- **Type**: `n8n-nodes-base.html`
- **CSS Selectors**: 
  - `a[href^="plyr_"]` (player links)
  - `body` (full HTML as fallback)
- **Purpose**: Extract individual player page links

### 4. Function - Parse Roster
- **Type**: `n8n-nodes-base.code`
- **Input**: Player links from HTML extraction
- **Logic**: 
  - Parse `<a href="plyr_21.htm">Player Name</a>` format
  - Extract jersey number from filename pattern (`plyr_{jersey}.htm`)
  - Extract player name from link text
  - Build full player URLs
- **Output**: Array of player objects `{jersey, name, playerUrl}`

### 5. HTTP Request - Player Page
- **Type**: `n8n-nodes-base.httpRequest`
- **URL**: `={{ $json.playerUrl }}` (dynamic per player)
- **Response Format**: `string`
- **Options**: `continueOnFail: true` (prevents workflow failure on missing pages)
- **Purpose**: Fetch individual player statistics page

### 6. HTML Extract - Player Stats
- **Type**: `n8n-nodes-base.html`
- **CSS Selector**: `body` (extract full page text)
- **Data Property**: `data`
- **Options**: `keepOnlySet: false`
- **Purpose**: Extract text content for parsing

### 7. Function - Parse Stats
- **Type**: `n8n-nodes-base.code`
- **Input**: Page text content from each player page
- **Logic**: 
  - Extract jersey number and name from page header using regex `/#\s*(\d+)\s+([^\n]+)/`
  - Find game rows using date pattern `/(\d{2}\/\d{2}\/\d{2})\s+([^\n]+)/g`
  - Parse each game row into structured data
  - Split columns by multiple spaces (`/\s{2,}/`)
- **Output**: Game-by-game statistics for each player

### 8. Create CSV File
- **Type**: `n8n-nodes-base.convertToFile`
- **Operation**: Default (automatic CSV conversion)
- **Filename**: `harding_msoc_2024_stats.csv`
- **Purpose**: Generate downloadable CSV file

## Output Data Structure

Each row in the CSV represents one game for one player:

```csv
jersey,name,date,opponent,score,gp,gs,minutes,ga,gaaVg,saves,savePct,w,l,t,sho
1,Inigo Chavarria,09/05/24,UNION (TN),1-3,*,,90:00,3,3.00,4,.571,0,0,0,-
1,Inigo Chavarria,09/07/24,CHRISTIAN BROTHERS,1-3,*,,90:00,3,3.00,6,.625,0,0,0,-
...
```

### Column Definitions

- **jersey**: Player's jersey number
- **name**: Player's full name
- **date**: Game date (MM/DD/YY format)
- **opponent**: Opposing team name
- **score**: Final score of the game
- **gp**: Games Played indicator (usually "*")
- **gs**: Games Started indicator
- **minutes**: Minutes played (MM:SS format)
- **ga**: Goals Against (goalkeeper stat)
- **gaaVg**: Goals Against Average (goalkeeper stat)
- **saves**: Number of saves made (goalkeeper stat)
- **savePct**: Save percentage (goalkeeper stat)
- **w**: Wins (goalkeeper stat)
- **l**: Losses (goalkeeper stat)
- **t**: Ties (goalkeeper stat)
- **sho**: Shutouts (goalkeeper stat)

## Expected Output

- **Total Records**: ~400-500 rows (26 players × ~18 games each)
- **File Size**: Approximately 50-100 KB
- **Format**: Standard CSV with headers

## Usage for Analysis

This dataset enables various analytical approaches:

### Pivot Analysis Examples

1. **Player Season Totals**: Pivot by player name to aggregate statistics
2. **Team Performance vs Opponents**: Pivot by opponent to see team trends
3. **Performance Over Time**: Pivot by date to track season progression
4. **Goalkeeper vs Field Player Stats**: Filter by stat columns to analyze different positions

### Sample Queries

- Which players appeared in the most games?
- How did team performance change over the season?
- What was the team's record against specific opponents?
- Which goalkeeper had the best save percentage?

## Technical Notes

### Error Handling

- **Continue On Fail**: HTTP requests won't break workflow if player pages are missing
- **Fallback Parsing**: Multiple extraction methods for roster links
- **Graceful Degradation**: Returns basic info even if game parsing fails

### Reliability Features

- Uses existing jersey/name from page content (most reliable source)
- Processes all players using n8n's natural iteration
- Handles missing or malformed data gracefully

### Performance Considerations

- Processes ~26 HTTP requests (one per player)
- Total execution time: ~30-60 seconds
- Memory usage: Minimal (text-only processing)

## Running the Workflow

1. Import the JSON file into n8n
2. Click "Execute Workflow" on the Manual Trigger node
3. Wait for completion (~1-2 minutes)
4. Download the generated `harding_msoc_2024_stats.csv` file

## Troubleshooting

### Common Issues

1. **No players found**: Check if the team page URL is accessible
2. **Missing game data**: Verify individual player pages are available
3. **Parsing errors**: Check if page format has changed

### Debug Information

The workflow includes console logging for:
- Number of players found
- Individual player processing
- Game row extraction
- Final statistics count

## Future Enhancements

Potential improvements for future seasons:

1. **Multi-season support**: Parameterize year in URLs
2. **Field player stats**: Add support for non-goalkeeper statistics
3. **Automated scheduling**: Run workflow automatically at season end
4. **Data validation**: Add checks for data quality and completeness
5. **Export options**: Support multiple output formats (JSON, Excel)

## File Location

**Workflow File**: `soccer.json`

**Generated Output**: `harding_msoc_2024_stats.csv` (downloaded via n8n interface)

## Import Instructions

1. Open n8n interface at http://localhost:5678
2. Go to **Workflows** → **Import from File**
3. Select the `soccer.json` file
4. Click **Import**
5. The workflow will be ready to execute

## Technical Implementation Details

### Key Code Patterns

#### Roster Parsing
```javascript
// Extract jersey number from filename pattern
const jerseyMatch = href.match(/plyr_(\d+)\.htm/);
const jersey = jerseyMatch ? jerseyMatch[1] : null;
```

#### Game Data Extraction
```javascript
// Find game rows using date pattern
const gameRowPattern = /(\d{2}\/\d{2}\/\d{2})\s+([^\n]+)/g;
while ((match = gameRowPattern.exec(pageContent)) !== null) {
    gameRows.push(match[0]);
}
```

#### Column Parsing
```javascript
// Split by multiple spaces to separate columns
const parts = gameRow.split(/\s{2,}/);
```

### Workflow Execution Flow

1. **Single HTTP Request** → Team page
2. **HTML Extraction** → Player links 
3. **Code Processing** → Parse links to get roster
4. **26 HTTP Requests** → Individual player pages (parallel execution)
5. **HTML Extraction** → Page content from each player
6. **Code Processing** → Parse game-by-game stats
7. **File Generation** → Convert to CSV format

## Version History

- **v1.0**: Initial implementation with totals-only extraction
- **v2.0**: Enhanced to extract game-by-game data
- **v2.1**: Added error handling and reliability improvements
- **v2.2**: Simplified architecture and improved parsing accuracy