/**
 * Reusable Utility Functions for Soccer Data Extraction Workflow
 * These functions can be copied into n8n Code nodes or used as reference
 */

// =============================================================================
// YEAR PATTERN UTILITIES
// =============================================================================

/**
 * Extract academic year patterns from text
 * @param {string} text - HTML or text content
 * @returns {string[]} - Array of year strings (e.g., ["2024-25", "2023-24"])
 */
function extractYearPatterns(text) {
  const yearPattern = /20\d{2}-\d{2}/g;
  const matches = text.match(yearPattern) || [];
  return [...new Set(matches)]; // Remove duplicates
}

/**
 * Generate fallback years (current and previous academic year)
 * @returns {string[]} - Array of fallback year strings
 */
function generateFallbackYears() {
  const currentYear = new Date().getFullYear();
  const currentAcademicYear = `${currentYear}-${(currentYear + 1).toString().slice(-2)}`;
  const previousAcademicYear = `${currentYear - 1}-${currentYear.toString().slice(-2)}`;
  return [currentAcademicYear, previousAcademicYear];
}

/**
 * Sort academic years in descending order (newest first)
 * @param {string[]} years - Array of year strings
 * @returns {string[]} - Sorted array
 */
function sortYearsDescending(years) {
  return years.sort((a, b) => b.localeCompare(a));
}

// =============================================================================
// URL BUILDERS
// =============================================================================

/**
 * Build roster and stats URLs for a given year
 * @param {string} year - Academic year (e.g., "2024-25")
 * @returns {object} - Object with rosterUrl and statsUrl
 */
function buildYearUrls(year) {
  const baseUrl = "https://hardingsports.com/sports/mens-soccer";
  return {
    year: year,
    rosterUrl: `${baseUrl}/roster/${year}`,
    statsUrl: `${baseUrl}/stats/${year}`
  };
}

/**
 * Validate URL format
 * @param {string} url - URL to validate
 * @returns {boolean} - True if valid URL format
 */
function isValidUrl(url) {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}

// =============================================================================
// HTML PARSING UTILITIES
// =============================================================================

/**
 * Clean HTML cell content (remove tags, entities, whitespace)
 * @param {string} cell - HTML cell content
 * @returns {string} - Cleaned text content
 */
function cleanCellContent(cell) {
  if (!cell) return '';
  
  // Remove opening and closing td tags
  let content = cell.replace(/<\/?td[^>]*>/gi, '');
  
  // If there's a link, extract just the text
  if (content.includes('<a')) {
    const linkMatch = content.match(/>([^<]+)</);
    content = linkMatch ? linkMatch[1] : content;
  }
  
  // Remove any remaining HTML tags
  content = content.replace(/<[^>]+>/g, '');
  
  // Clean up whitespace and HTML entities
  content = content.replace(/&nbsp;/g, ' ')
                  .replace(/&amp;/g, '&')
                  .replace(/&lt;/g, '<')
                  .replace(/&gt;/g, '>')
                  .replace(/&quot;/g, '"')
                  .replace(/\s+/g, ' ')
                  .trim();
  
  return content;
}

/**
 * Check if a table row is a header row
 * @param {string} row - HTML table row
 * @returns {boolean} - True if header row
 */
function isHeaderRow(row) {
  const lowerRow = row.toLowerCase();
  return lowerRow.includes('<th>') || 
         lowerRow.includes('player') || 
         lowerRow.includes('name') ||
         lowerRow.includes('position') ||
         lowerRow.includes('games');
}

/**
 * Extract table cells from HTML table row
 * @param {string} row - HTML table row
 * @returns {string[]} - Array of cleaned cell contents
 */
function extractTableCells(row) {
  const cells = row.match(/<td[^>]*>(.*?)<\/td>/gi) || [];
  return cells.map(cleanCellContent);
}

// =============================================================================
// DATA VALIDATION UTILITIES
// =============================================================================

/**
 * Validate if a string looks like a player name (Enhanced Version)
 * @param {string} name - Potential player name
 * @returns {boolean} - True if valid player name
 */
function isValidPlayerName(name) {
  if (!name || typeof name !== 'string') return false;
  
  const trimmedName = name.trim();
  if (trimmedName.length < 2 || !isNaN(Number(trimmedName))) return false;
  
  // Expanded list of invalid names and sports-related terms
  const invalidNames = [
    'total', 'totals', '-', 'n/a', 'tbd', 'team', 'coach', 'assistant',
    'shots', 'penalties', 'miscellaneous', 'points', 'goals', 'assists',
    'shots on goal', 'saves', 'fouls', 'corner kicks', 'opponent', 'tm',
    'harding', 'university'
  ];
  
  // Pattern matching to filter out dates, scores, game results, etc.
  const invalidPatterns = [
    /^\d{2}\/\d{2}\/\d{4}$/, // Date pattern
    /^[A-Z\s]+$/,           // All caps (likely headers)
    /^\d+-\d+$/,            // Score pattern  
    /^[LWT]$/,              // Game result (Loss/Win/Tie)
    /^\(\d+-\d+-\d+/,       // Record pattern
    /^\d+:\d+$/             // Time pattern
  ];
  
  if (invalidNames.includes(trimmedName.toLowerCase())) return false;
  
  for (const pattern of invalidPatterns) {
    if (pattern.test(trimmedName)) return false;
  }
  
  // Must contain at least one letter and one space (typical name format)
  if (!/[a-zA-Z]/.test(trimmedName) || !/\s/.test(trimmedName)) return false;
  
  return true;
}

/**
 * Validate numeric field (goals, assists, etc.)
 * @param {string} value - String value to validate
 * @returns {string} - Validated numeric string or "0"
 */
function validateNumericField(value) {
  if (!value || value.trim() === '') return '0';
  const num = parseInt(value.trim());
  return isNaN(num) ? '0' : num.toString();
}

/**
 * Validate jersey number
 * @param {string} number - Jersey number string
 * @returns {string} - Validated jersey number or empty string
 */
function validateJerseyNumber(number) {
  if (!number) return '';
  const num = parseInt(number.trim());
  return (isNaN(num) || num < 0 || num > 99) ? '' : num.toString();
}

// =============================================================================
// LOGGING UTILITIES
// =============================================================================

/**
 * Create structured log entry
 * @param {string} level - Log level (info, warn, error)
 * @param {string} message - Log message
 * @param {object} data - Additional data to log
 * @returns {object} - Structured log entry
 */
function createLogEntry(level, message, data = {}) {
  return {
    timestamp: new Date().toISOString(),
    level: level,
    message: message,
    executionId: $execution.id || 'unknown',
    nodeId: $node.id || 'unknown',
    data: data
  };
}

/**
 * Log with structure (use console.log to output in n8n)
 * @param {string} level - Log level
 * @param {string} message - Message
 * @param {object} data - Additional data
 */
function logStructured(level, message, data = {}) {
  const logEntry = createLogEntry(level, message, data);
  console.log(JSON.stringify(logEntry));
}

// =============================================================================
// RETRY UTILITIES
// =============================================================================

/**
 * Calculate exponential backoff delay
 * @param {number} attempt - Attempt number (0-based)
 * @param {number} baseDelay - Base delay in milliseconds
 * @returns {number} - Delay in milliseconds
 */
function calculateBackoffDelay(attempt, baseDelay = 1000) {
  return baseDelay * Math.pow(2, attempt);
}

/**
 * Check if HTTP response is successful
 * @param {object} response - HTTP response object
 * @returns {boolean} - True if successful
 */
function isHttpSuccess(response) {
  return response && response.statusCode >= 200 && response.statusCode < 300;
}

// =============================================================================
// EXPORT (for external testing)
// =============================================================================

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    extractYearPatterns,
    generateFallbackYears,
    sortYearsDescending,
    buildYearUrls,
    isValidUrl,
    cleanCellContent,
    isHeaderRow,
    extractTableCells,
    isValidPlayerName,
    validateNumericField,
    validateJerseyNumber,
    createLogEntry,
    logStructured,
    calculateBackoffDelay,
    isHttpSuccess
  };
}