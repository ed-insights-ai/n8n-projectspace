# Harding Soccer Stats Scraper - Workflow Design

## Overview
An n8n workflow to scrape Harding University's 2024 men's soccer season statistics from their static website and export to CSV format.

## Data Source
- **Target URL**: `https://static.hardingsports.com/custompages/msoc/2024/teamgbg.htm`
- **Player Pages**: `https://static.hardingsports.com/custompages/msoc/2024/plyr_{jersey}.htm`
- **Data Format**: HTML tables with player statistics

## Workflow Architecture

### Current Node Flow
```
Manual Trigger
    ↓
HTTP Request - Season Page
    ↓
HTML Extract - Roster Links
    ↓
Function - Parse Roster
    ↓
SplitInBatches
    ↓ (output 1 - individual players)
HTTP Request - Player Page
    ↓
HTML Extract - Player Stats  
    ↓
Function - Parse Stats
    ↓
More Players? (conditional)
    ↓ (false - all done)
Collect All Stats
    ↓
Create CSV File
```

### Node Details

#### 1. Manual Trigger
- **Type**: `n8n-nodes-base.manualTrigger`
- **Purpose**: Workflow initiation

#### 2. HTTP Request - Season Page
- **Type**: `n8n-nodes-base.httpRequest`
- **URL**: `https://static.hardingsports.com/custompages/msoc/2024/teamgbg.htm`
- **Response Format**: `string` (puts HTML in `data` property)
- **Purpose**: Fetch main team page containing player links

#### 3. HTML Extract - Roster Links
- **Type**: `n8n-nodes-base.html`
- **CSS Selector**: `a[href^="plyr_"]` (player links)
- **Return**: HTML content of each link + full body HTML
- **Purpose**: Extract individual player page links

#### 4. Function - Parse Roster
- **Type**: `n8n-nodes-base.code`
- **Input**: Player links from HTML extraction
- **Logic**: 
  - Parse `<a href="plyr_21.htm">Player Name</a>` format
  - Extract jersey number from filename pattern
  - Extract player name from link text
  - Build full player URLs
- **Output**: Array of player objects `{jersey, name, playerUrl}`

#### 5. SplitInBatches
- **Type**: `n8n-nodes-base.splitInBatches`
- **Batch Size**: 1 (process one player at a time)
- **Output 0**: Empty (currently unused)
- **Output 1**: Individual player for processing

#### 6. HTTP Request - Player Page
- **Type**: `n8n-nodes-base.httpRequest`
- **URL**: `{{ $json.playerUrl }}` (dynamic per player)
- **Response Format**: `string`
- **Purpose**: Fetch individual player statistics page

#### 7. HTML Extract - Player Stats
- **Type**: `n8n-nodes-base.html`
- **Data Property**: `data`
- **CSS Selector**: `body` (extract full page text)
- **Purpose**: Extract text content for regex parsing

#### 8. Function - Parse Stats
- **Type**: `n8n-nodes-base.code`
- **Input**: Page text content + player info from SplitInBatches
- **Regex Pattern**: `/Totals\s+([\d-]+)\s+([\d-]+)\s+([\d-]+)\s+([\d-]+)\s+([\d-]+)\s+([\d-]+)\s+([\d.-]+)/`
- **Output**: Player stats object `{jersey, name, gp, gs, g, a, pts, sh, shotPct}`

#### 9. More Players? (Conditional)
- **Type**: `n8n-nodes-base.if`
- **Condition**: `$('SplitInBatches').isCompleted === false`
- **Output True**: Loop back to SplitInBatches for next player
- **Output False**: All players processed, go to collection

#### 10. Collect All Stats
- **Type**: `n8n-nodes-base.merge`
- **Mode**: `combine` / `combineAll`
- **Purpose**: Accumulate all player statistics

#### 11. Create CSV File
- **Type**: `n8n-nodes-base.convertToFile`
- **Operation**: `toCsv`
- **Filename**: `harding_msoc_2024_stats.csv`

## Current Issues

### Problem 1: Premature Loop Termination
- **Symptom**: Only first player processed, then workflow stops
- **Cause**: `$('SplitInBatches').isCompleted` returns `true` after first player
- **Status**: ❌ BROKEN

### Problem 2: Collection Node No Output
- **Symptom**: "Collect All Stats" receives data but produces no output
- **Cause**: `combineAll` merge waiting for multiple inputs but only receives one
- **Status**: ❌ BROKEN

### Problem 3: Loop Architecture
- **Issue**: Using conditional logic instead of standard SplitInBatches pattern
- **Standard Pattern**: Output 0 for completion, Output 1 for individual items
- **Current Pattern**: Complex conditional checking `isCompleted` status

## Proposed Solutions

### Option A: Fix Current Architecture
1. Debug why `SplitInBatches.isCompleted` returns `true` prematurely
2. Fix collection merge node configuration
3. Ensure proper loop-back mechanism

### Option B: Simplify to Standard Pattern
1. Use SplitInBatches Output 0 → Direct to final collection (auto-fires when done)
2. Use SplitInBatches Output 1 → Processing → Simple accumulator
3. Remove conditional "More Players?" node entirely

## Data Flow Validation

### Expected Player Data Structure
```json
{
  "jersey": "1",
  "name": "Inigo Chavarria", 
  "playerUrl": "https://static.hardingsports.com/custompages/msoc/2024/plyr_1.htm",
  "gp": "18",
  "gs": "17", 
  "g": "16",
  "a": "0",
  "pts": "0",
  "sh": "0",
  "shotPct": "0"
}
```

### CSV Output Format
```csv
jersey,name,gp,gs,g,a,pts,sh,shotPct
1,Inigo Chavarria,18,17,16,0,0,0,0
...
```

## Testing Notes
- ✅ HTTP requests work correctly (responseFormat: "string" fix applied)
- ✅ HTML extraction finds player links successfully
- ✅ Individual player stats parsing works
- ❌ Loop processing only handles first player
- ❌ Final data collection/CSV generation broken

## Change Log
1. **2024-XX-XX**: Fixed HTTP Request responseFormat from nested to top-level
2. **2024-XX-XX**: Added dataPropertyName: "data" to HTML Extract nodes
3. **2024-XX-XX**: Removed redundant Merge - Player Data node
4. **2024-XX-XX**: Identified loop termination and collection issues