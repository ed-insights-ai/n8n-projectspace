# Node 02: Fetch Years Page

## Purpose
Makes an HTTP GET request to the Harding Sports men's soccer roster page to retrieve the HTML containing season/year selection options.

## Node Type
`n8n-nodes-base.httpRequest` (v4.2)

## Position in Workflow
```mermaid
graph LR
    A[Schedule Trigger] --> B[**Fetch Years Page**]
    B --> C[Extract Available Years]
```

## Input Schema
```json
{
  "trigger_data": "any" 
}
```
*Accepts any input from the Schedule Trigger*

## Configuration
```json
{
  "url": "https://hardingsports.com/sports/mens-soccer/roster",
  "sendHeaders": true,
  "headerParameters": {
    "parameters": [
      {
        "name": "User-Agent",
        "value": "Mozilla/5.0"
      }
    ]
  },
  "options": {}
}
```

### Configuration Details
- **URL**: Fixed endpoint for the current roster page
- **Method**: GET (default)
- **Headers**: User-Agent set to avoid bot detection
- **Authentication**: None required

## Output Schema
```json
{
  "statusCode": 200,
  "headers": {
    "content-type": "text/html; charset=utf-8",
    "...": "..."
  },
  "body": "<html>...</html>"
}
```

## Success Criteria
- HTTP status code 200
- Response body contains HTML with season selector elements
- Content-Type is text/html

## Error Scenarios

### Network Errors
- **Cause**: DNS resolution failure, connection timeout
- **Detection**: HTTP status codes 400+, connection exceptions
- **Handling**: Currently none (workflow stops)
- **Improvement**: Add retry logic with exponential backoff

### Website Changes
- **Cause**: URL structure change, page moved
- **Detection**: 404 status code, unexpected content
- **Handling**: Currently none (workflow continues with empty data)
- **Improvement**: Validate response contains expected elements

### Rate Limiting
- **Cause**: Too many requests from same IP
- **Detection**: 429 status code, slow responses
- **Handling**: None (could cascade failures)
- **Improvement**: Implement request throttling

## Testing

### Unit Test
```bash
curl -H "User-Agent: Mozilla/5.0" https://hardingsports.com/sports/mens-soccer/roster
```

### Expected Response Validation
The response should contain elements like:
```html
<select id="roster_select">
  <option value="2024-25">2024-25</option>
  <option value="2023-24">2023-24</option>
</select>
```

### Debug Checklist
1. ✅ Is hardingsports.com accessible?
2. ✅ Does the page load in a browser?
3. ✅ Are there season selector elements on the page?
4. ✅ Is the User-Agent being sent correctly?

## Improvements Needed
1. **Add Response Validation**: Check for 200 status code
2. **Add Retry Logic**: 3 attempts with 2s, 4s, 8s delays
3. **Add Content Validation**: Verify HTML contains expected selectors
4. **Add Error Handling**: Graceful failure with informative error messages
5. **Add Logging**: Log request details and response metadata

## Dependencies
- Internet connectivity
- hardingsports.com availability
- No rate limiting from target site

## Related Nodes
- **Upstream**: [01 - Schedule Trigger](01-schedule-trigger.md)
- **Downstream**: [03 - Extract Available Years](03-extract-available-years.md)
- **Similar Pattern**: [07 - Fetch Roster Page](07-fetch-roster-page.md), [08 - Fetch Stats Page](08-fetch-stats-page.md)