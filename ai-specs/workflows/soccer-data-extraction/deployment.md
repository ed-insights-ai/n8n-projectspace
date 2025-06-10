# Soccer Workflow Deployment Guide

## Prerequisites

### n8n Requirements
- **n8n Version**: 1.0+ (required for Code node)
- **Hosting**: Self-hosted or n8n Cloud
- **Memory**: Minimum 512MB available for workflow execution
- **Network**: Internet connectivity to hardingsports.com

### Environment Setup
- No external dependencies required
- No API keys or authentication needed
- No database connections required

## Import Instructions

### Method 1: Direct JSON Import
1. Download the workflow file: `soccer.json`
2. Open your n8n instance
3. Go to **Workflows** → **Import from File**
4. Select the `soccer.json` file
5. Click **Import**

### Method 2: Manual Creation
If importing fails, create the workflow manually using the [node documentation](nodes/).

## Configuration Steps

### 1. Schedule Configuration
```json
{
  "rule": {
    "interval": [
      {
        "field": "cronExpression",
        "expression": "0 2 * * 1"  // Weekly on Monday at 2 AM
      }
    ]
  }
}
```

**Options:**
- **Manual Trigger**: Leave interval empty for manual execution
- **Daily**: `0 2 * * *`
- **Weekly**: `0 2 * * 1` (Monday 2 AM)
- **Monthly**: `0 2 1 * *` (First day of month, 2 AM)

### 2. Rate Limiting Settings
Current configuration: 2-second delays between requests
- **Conservative**: Increase to 5 seconds if experiencing rate limiting
- **Aggressive**: Reduce to 1 second if site allows (monitor for errors)

### 3. Output Configuration
Default: Creates CSV file in n8n's temporary storage
- **File Name**: Auto-generated with timestamp
- **Format**: CSV with headers
- **Encoding**: UTF-8

## Validation After Import

### 1. Node Verification
Check that all nodes are properly connected:
```
Schedule Trigger → Fetch Years Page → Extract Available Years → 
Parse Available Years → Split Into Batches → ...
```

### 2. Test Execution
1. **Manual Test**: Click "Test workflow" button
2. **Check Output**: Verify CSV generation
3. **Review Logs**: Look for any error messages
4. **Data Quality**: Validate extracted player information

### 3. Configuration Verification
- ✅ All HTTP Request nodes have User-Agent headers
- ✅ Wait nodes have 2-second delays
- ✅ JavaScript code nodes have proper error handling
- ✅ CSS selectors are configured correctly

## Troubleshooting Common Issues

### Import Failures

#### Issue: "Unknown node type" error
**Cause**: n8n version too old or missing node types
**Solution**: 
- Upgrade to n8n 1.0+
- Check that all required nodes are available

#### Issue: "Invalid workflow format" error
**Cause**: Corrupted JSON file
**Solution**:
- Re-download the workflow file
- Validate JSON format using online validator
- Try manual creation using documentation

### Execution Failures

#### Issue: HTTP 403/429 errors
**Cause**: Rate limiting or bot detection
**Solution**:
- Increase wait time between requests
- Verify User-Agent headers are set
- Check if IP is blocked by target site

#### Issue: No data extracted
**Cause**: Website structure changes
**Solution**:
- Check CSS selectors in HTML extraction nodes
- Compare current site structure with expected format
- Update selectors if needed

#### Issue: JavaScript execution errors
**Cause**: Syntax errors or missing data
**Solution**:
- Check browser console for detailed errors
- Validate input data structure
- Test JavaScript code in isolation

## Performance Optimization

### For Large Datasets
- **Batch Size**: Keep default (1 season at a time)
- **Memory**: Monitor memory usage during execution
- **Timeout**: Increase node timeout if needed

### For Multiple Seasons
- **Expected Time**: ~30 seconds per season
- **Rate Limiting**: Don't reduce below 1-second delays
- **Concurrent Execution**: Avoid running multiple instances

## Security Considerations

### Data Privacy
- **No Personal Data Stored**: Workflow processes public sports data
- **Temporary Storage**: CSV files stored temporarily in n8n
- **No Authentication Required**: Accesses publicly available pages

### Network Security
- **HTTPS Only**: All requests use secure connections
- **User-Agent**: Identifies requests appropriately
- **Rate Limiting**: Respects target site resources

## Maintenance

### Regular Updates Needed
1. **CSS Selectors**: Update if website structure changes
2. **URLs**: Verify links still work
3. **Data Validation**: Check output quality periodically
4. **Error Handling**: Monitor logs for new error patterns

### Monitoring
- **Execution Frequency**: Check workflow runs successfully
- **Data Quality**: Validate player counts and information
- **Performance**: Monitor execution time trends
- **Errors**: Review logs for warnings or failures

## Version Control

### Workflow Versioning
- **Export**: Regularly export workflow JSON
- **Backup**: Store copies with version dates
- **Changes**: Document modifications made
- **Rollback**: Keep previous working versions

### Change Management
```json
{
  "version": "1.0",
  "lastUpdated": "2024-01-15",
  "changes": [
    "Initial deployment",
    "Added error handling for missing data",
    "Updated CSS selectors for new site layout"
  ]
}
```

## Support

### Log Analysis
Enable debug logging for troubleshooting:
1. Check execution logs in n8n interface
2. Look for JavaScript console.log outputs
3. Monitor HTTP response status codes
4. Validate data at each workflow step

### Getting Help
- **Documentation**: Refer to [node-specific documentation](nodes/)
- **Testing**: Use [test cases](testing/test-cases.md) for validation
- **Code**: Review [utility functions](code-snippets/utilities.js)

## Deployment Checklist

### Pre-Deployment
- [ ] n8n version 1.0+ installed
- [ ] Workflow JSON file available
- [ ] Network connectivity verified
- [ ] Required permissions granted

### Deployment
- [ ] Workflow imported successfully
- [ ] All nodes properly connected
- [ ] Configuration parameters set
- [ ] Schedule configured (if desired)

### Post-Deployment
- [ ] Test execution completed successfully
- [ ] Output CSV generated with valid data
- [ ] Error handling tested
- [ ] Monitoring enabled
- [ ] Documentation updated

### Production Readiness
- [ ] Backup workflow exported
- [ ] Monitoring alerts configured
- [ ] Team trained on maintenance
- [ ] Support procedures documented