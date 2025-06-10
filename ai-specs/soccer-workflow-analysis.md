# Soccer Workflow Analysis

## Overview
The soccer.json workflow is an automated data extraction system that scrapes soccer player information from Harding Sports website (hardingsports.com). It extracts both roster and statistical data for men's soccer players across multiple seasons and outputs the combined data as a CSV file.

## Workflow Purpose
This workflow automates the collection of comprehensive soccer player data for analysis, reporting, or archival purposes. It systematically gathers:
- Player roster information (demographics, physical stats)
- Player performance statistics (games, goals, assists, etc.)
- Multi-season historical data

## Technical Architecture

### Trigger
- **Schedule Trigger**: Runs automatically on a defined interval
- **Type**: Time-based scheduling (interval configuration present but empty)

### Data Flow

#### 1. Year Discovery Phase
- **Fetch Years Page**: GET request to `https://hardingsports.com/sports/mens-soccer/roster`
- **Extract Available Years**: HTML parsing to find season selectors and year links
- **Parse Available Years**: JavaScript code extracts year patterns (e.g., "2024-25", "2023-24")
- **Split Into Batches**: Processes each season individually to avoid overwhelming the server

#### 2. Data Extraction Phase (Per Season)
- **Wait 2 Seconds**: Rate limiting to be respectful to the target server
- **Parallel Data Fetching**:
  - **Fetch Roster Page**: GET `https://hardingsports.com/sports/mens-soccer/roster/{year}`
  - **Fetch Stats Page**: GET `https://hardingsports.com/sports/mens-soccer/stats/{year}`

#### 3. Data Processing Phase
- **Extract HTML**: Uses CSS selectors to isolate player data tables
- **Parse Data**: JavaScript processing to extract structured information
  - **Roster Parser**: Extracts jersey numbers, names, positions, height, weight, year in school, hometown
  - **Stats Parser**: Extracts games played, goals, assists, points, shots, shots on goal
- **Merge**: Combines roster and stats data for each season

#### 4. Loop Control
- **More Years?**: Conditional check to process additional seasons
- **Collect All Data**: Aggregates data from all processed seasons
- **Create CSV File**: Converts final dataset to CSV format

## Data Schema

### Roster Data Fields
- `section_type`: "roster"
- `season`: Academic year (e.g., "2024-25")
- `jersey_number`: Player's uniform number
- `name`: Full player name
- `position`: Playing position (GK, DEF, MID, FWD, etc.)
- `height`: Player height
- `weight`: Player weight
- `year_in_school`: Academic standing (Fr, So, Jr, Sr)
- `hometown`: Player's hometown

### Statistics Data Fields
- `section_type`: "stats"
- `season`: Academic year
- `name`: Player name (for matching with roster)
- `jersey_number`: Uniform number
- `GP`: Games Played
- `GS`: Games Started
- `G`: Goals
- `A`: Assists
- `PTS`: Points
- `SH`: Shots
- `SOG`: Shots on Goal

## Error Handling & Robustness

### Parsing Resilience
- Multiple CSS selector strategies for different page layouts
- Regex pattern matching with fallbacks
- Data validation (name length, numeric checks)
- Debug mode for troubleshooting failed extractions

### Rate Limiting
- 2-second delays between requests
- Batch processing to avoid server overload
- User-Agent headers to identify requests properly

### Data Quality
- Filters out header rows and invalid entries
- Validates player names and data integrity
- Handles missing data gracefully with empty string defaults

## Output Format
- **File Type**: CSV
- **Structure**: Flat table with combined roster and statistics data
- **Usage**: Ready for import into spreadsheet applications, databases, or analytics tools

## Use Cases
1. **Season Analysis**: Compare player performance across different seasons
2. **Recruitment**: Analyze player development and statistics
3. **Historical Archive**: Maintain records of team rosters and performance
4. **Analytics**: Feed data into sports analytics platforms
5. **Reporting**: Generate team reports and player profiles

## Technical Considerations
- **Web Scraping Ethics**: Includes rate limiting and proper headers
- **Data Persistence**: Outputs to file format for long-term storage
- **Scalability**: Processes multiple seasons efficiently
- **Maintainability**: Modular design with clear separation of concerns