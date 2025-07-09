## Requirement: Soccer Analytics Data Extraction Pipeline with AI Agent
Objective: Develop an automated data extraction and analytics workflow that scrapes, processes, stores, and provides intelligent querying capabilities for soccer team data from Harding University's athletics website.
Data Source: The system must extract data from https://static.hardingsports.com/custompages/msoc/2024/roster.htm, which contains both player roster information and game results for the men's soccer team.
Functional Requirements:
1. Web Scraping: Utilize Firecrawl API to extract clean markdown content from the Harding sports website, filtering out unnecessary media elements (images, SVG, video, audio).
2. Data Extraction: Implement AI-powered parsing to intelligently identify and extract:
   - Player information: jersey numbers, names, positions (with goalkeeper detection)
   - Game results: dates, opponents, scores, home/away status
3. Data Processing: 
   - Parse unstructured web content using multiple regex patterns for adaptability
   - Validate and deduplicate extracted data
   - Format dates consistently (YYYY-MM-DD)
   - Generate unique identifiers for players and games
4. Database Storage: Store processed data in Supabase PostgreSQL database across three tables:
   - players (player roster data)
   - games (match results)
   - soccer_extraction_log (audit trail and metadata)
5. AI Agent Query Interface: Implement an intelligent agent capability that can:
   - Accept natural language queries about soccer data
   - Generate appropriate SQL queries against the database
   - Return formatted responses with player statistics, game results, and analytics
   - Handle complex queries like "Who scored the most goals?" or "Show me all away games"
   - Provide conversational responses with context and insights
6. Error Handling: Include conditional logic to handle scraping failures with appropriate error logging and troubleshooting guidance.
Technical Requirements:
- Built as an n8n workflow with manual trigger capability
- Authentication via Firecrawl API credentials
- Robust pattern recognition to adapt to website structure changes
- AI agent integration for natural language database querying
- Real-time data availability for analytics and reporting
Success Criteria: The system must successfully extract, validate, and store both player roster and game result data, while providing an intelligent agent interface that can answer natural language questions about the soccer analytics data.