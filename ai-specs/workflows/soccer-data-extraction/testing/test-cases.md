# Soccer Workflow Test Cases

## Overview
This document outlines test cases for validating the soccer data extraction workflow both in isolation and as an integrated system.

## Unit Test Cases

### Node 02: Fetch Years Page
```bash
# Manual HTTP test
curl -H "User-Agent: Mozilla/5.0" https://hardingsports.com/sports/mens-soccer/roster

# Expected: 200 status code, HTML content with season selectors
```

### Node 03: Extract Available Years
**Test Input:**
```html
<select id="roster_select">
  <option value="2024-25">2024-25</option>
  <option value="2023-24">2023-24</option>
</select>
```

**Expected Output:**
```json
{
  "yearOptions": ["<option value=\"2024-25\">2024-25</option>", ...],
  "yearLinks": [...]
}
```

### Node 04: Parse Available Years
**Test Inputs:**
```javascript
// Test Case 1: Normal year options
const input1 = {
  yearOptions: ['<option value="2024-25">2024-25</option>', '<option value="2023-24">2023-24</option>'],
  yearLinks: []
};

// Test Case 2: Empty input (fallback scenario)
const input2 = {
  yearOptions: [],
  yearLinks: []
};

// Test Case 3: Mixed sources
const input3 = {
  yearOptions: ['<option value="2024-25">2024-25</option>'],
  yearLinks: ['<a href="/roster/2022-23">2022-23</a>']
};
```

**Expected Outputs:**
```javascript
// Expected 1: Extracted years
[
  {year: "2024-25", rosterUrl: "...", statsUrl: "..."},
  {year: "2023-24", rosterUrl: "...", statsUrl: "..."}
]

// Expected 2: Current/previous year fallback
[
  {year: "2024-25", rosterUrl: "...", statsUrl: "..."},
  {year: "2023-24", rosterUrl: "...", statsUrl: "..."}
]

// Expected 3: Combined and sorted
[
  {year: "2024-25", rosterUrl: "...", statsUrl: "..."},
  {year: "2022-23", rosterUrl: "...", statsUrl: "..."}
]
```

### Node 11: Parse Roster Data
**Test Input:**
```html
<tr>
  <td>23</td>
  <td><a href="#">John Smith</a></td>
  <td>MID</td>
  <td>5'10"</td>
  <td>165</td>
  <td>Jr</td>
  <td>Chicago, IL</td>
</tr>
```

**Expected Output:**
```json
{
  "section_type": "roster",
  "season": "2024-25",
  "jersey_number": "23",
  "name": "John Smith",
  "position": "MID",
  "height": "5'10\"",
  "weight": "165",
  "year_in_school": "Jr",
  "hometown": "Chicago, IL"
}
```

### Node 12: Parse Stats Data
**Test Input:**
```html
<tr>
  <td>John Smith</td>
  <td>23</td>
  <td>15</td>
  <td>12</td>
  <td>8</td>
  <td>3</td>
  <td>19</td>
  <td>45</td>
  <td>28</td>
</tr>
```

**Expected Output:**
```json
{
  "section_type": "stats",
  "season": "2024-25",
  "name": "John Smith",
  "jersey_number": "23",
  "GP": "15",
  "GS": "12",
  "G": "8",
  "A": "3",
  "PTS": "19",
  "SH": "45",
  "SOG": "28"
}
```

## Integration Test Cases

### End-to-End Happy Path
1. **Trigger**: Schedule trigger fires
2. **Discovery**: Successfully fetches years page and extracts 2+ seasons
3. **Processing**: Processes each season with roster and stats data
4. **Output**: Creates CSV with combined data from all seasons
5. **Validation**: CSV contains expected columns and valid player data

### Error Handling Test Cases

#### Network Failure Tests
```javascript
// Test Case: Website unreachable
// Expected: Graceful failure with error message
// Current: Workflow stops without clear error

// Test Case: 404 on specific year page
// Expected: Skip year and continue
// Current: Workflow may fail completely

// Test Case: Timeout on HTTP request
// Expected: Retry with backoff
// Current: Immediate failure
```

#### Data Quality Tests
```javascript
// Test Case: No players found on roster page
// Expected: Log warning and continue
// Current: May produce empty results

// Test Case: Malformed HTML structure
// Expected: Use fallback selectors
// Current: May extract incorrect data

// Test Case: Website structure changes
// Expected: Alert and use fallbacks
// Current: Silent failure
```

## Performance Test Cases

### Load Testing
- **Single Season**: Time to process one season's data
- **Multiple Seasons**: Performance with 5+ seasons
- **Memory Usage**: Memory consumption during processing
- **Rate Limiting**: Verify 2-second delays are respected

### Scalability Testing
- **Concurrent Requests**: Test if workflow handles multiple simultaneous runs
- **Large Datasets**: Performance with teams having 30+ players
- **Long-Running**: Stability over extended execution times

## Regression Test Cases

### Data Consistency
```javascript
// Test Case: Compare output between workflow runs
// Expected: Same data for same season
// Validate: Player names, stats, jersey numbers match

// Test Case: Historical data accuracy
// Expected: Previous seasons remain unchanged
// Validate: Compare against archived data
```

### Format Validation
```javascript
// Test Case: CSV structure validation
// Expected: Consistent column headers and data types
// Validate: 
// - All required columns present
// - No empty critical fields (name, season)
// - Numeric fields contain valid numbers
```

## Test Data Sets

### Mock HTML Responses
Located in `sample-responses/` directory:
- `roster-page-2024-25.html` - Current season roster
- `stats-page-2024-25.html` - Current season statistics  
- `years-page.html` - Main page with season selectors
- `empty-roster.html` - Page with no players
- `malformed-table.html` - Corrupted HTML structure

### Expected Outputs
- `expected-roster-data.json` - Parsed roster data
- `expected-stats-data.json` - Parsed statistics data
- `expected-final-csv.csv` - Complete workflow output

## Testing Tools

### Manual Testing Scripts
```bash
# Quick connectivity test
./scripts/test-connectivity.sh

# Validate current workflow output
./scripts/validate-output.sh

# Compare with expected results
./scripts/compare-results.sh
```

### Automated Testing
```javascript
// Jest-style test runner for utility functions
npm test

// n8n workflow testing (when available)
n8n test workflow soccer-data-extraction
```

## Test Environment Setup

### Prerequisites
- n8n instance (local or cloud)
- Internet connectivity to hardingsports.com
- Test data files in place

### Test Configuration
```json
{
  "testMode": true,
  "useTestData": false,
  "logLevel": "debug",
  "timeoutMs": 30000,
  "retryAttempts": 3
}
```

## Success Criteria

### Functional Requirements
- ✅ Extracts player data from multiple seasons
- ✅ Combines roster and statistics information
- ✅ Outputs valid CSV format
- ✅ Handles missing data gracefully
- ✅ Respects rate limiting

### Quality Requirements
- ✅ No data corruption or loss
- ✅ Consistent output format
- ✅ Reasonable execution time (<5 minutes for 3 seasons)
- ✅ Proper error reporting
- ✅ Maintains audit trail in logs

### Reliability Requirements
- ✅ Handles website unavailability
- ✅ Recovers from partial failures
- ✅ Provides debugging information
- ✅ Maintains data integrity
- ✅ Reproducible results