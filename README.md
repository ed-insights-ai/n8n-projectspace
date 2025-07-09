# Soccer Analytics Data Extraction Pipeline

An automated AI-powered data extraction and analytics workflow that scrapes, processes, stores, and provides intelligent querying capabilities for soccer team data from Harding University's athletics website.

## Project Overview

This project implements an n8n workflow automation platform with:
- **AI-powered web scraping** using Firecrawl API
- **PostgreSQL database** via Supabase for structured data storage
- **Intelligent querying** with AI agents for natural language analytics
- **Docker-based deployment** for easy local development
- **MCP server integration** for enhanced AI capabilities

### Key Features

- 🤖 **AI-powered extraction** adapts to website changes automatically
- 📊 **Structured database** with comprehensive soccer analytics schema
- 🎯 **Zero maintenance** requirements vs. traditional CSS selector scraping
- 🔍 **Natural language queries** via AI agent integration
- 📈 **Real-time analytics** capabilities for coaching staff
- 🏗️ **Scalable architecture** for multi-school deployment

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Git for cloning the repository
- Claude Code with MCP server support
- Supabase account and project
- Firecrawl API key

### 1. Initial Setup

```bash
# Generate environment file with secure passwords
make setup

# Start all services (auto-setup if needed)
make up

# View logs to verify startup
make logs
```

### 2. Access the Application

- **n8n Interface**: http://localhost:5678
- **PostgreSQL**: localhost:5432 (database: n8n, user: n8n)

### 3. Import the Soccer Analytics Workflow

1. Open n8n at http://localhost:5678
2. Navigate to **Workflows** → **Import from File**
3. Select `project/workflow.json`
4. Configure API credentials (see [API Keys Setup](#api-keys-setup))

## Architecture

### System Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   n8n Workflow │    │   Firecrawl API │    │  Supabase DB    │
│   (Port 5678)  │────│   (AI Scraping) │────│  (PostgreSQL)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         │              ┌─────────────────┐            │
         └──────────────│  Claude Code    │────────────┘
                        │  (MCP Servers)  │
                        └─────────────────┘
```

### Database Schema

The system uses 6 interconnected PostgreSQL tables:

- **schools** - Master school registry
- **seasons** - Season information
- **players** - Player roster data
- **games** - Game results and scores
- **player_game_stats** - Individual player statistics
- **soccer_extraction_log** - Audit trail and metadata

## MCP Server Configuration

This project uses two MCP (Model Context Protocol) servers to enhance AI capabilities:

### 1. n8n-mcp Server
Provides comprehensive n8n workflow management capabilities:
- Workflow creation and management
- Node configuration and validation
- Execution monitoring
- Template access

### 2. Supabase MCP Server
Enables direct database operations:
- SQL query execution
- Table management
- Real-time data access
- Analytics queries

### Setting Up .mcp.json

Create a `.mcp.json` file in the project root:

```json
{
  "mcpServers": {
      "n8n-mcp": {
         "command": "npx",
         "args": ["n8n-mcp"],
         "env": {
         "MCP_MODE": "stdio",
         "LOG_LEVEL": "error",
         "DISABLE_CONSOLE_OUTPUT": "true",
         "N8N_API_URL": "http://localhost:5678",
         "N8N_API_KEY": "YOUR_N8N_API_KEY"
         }
      },
      "supabase": {
         "command": "npx",
         "args": [
         "-y",
         "@supabase/mcp-server-supabase@latest",
         "--access-token",
         "sbp_YOUR_SUPABASE_TOKEN"
         ]
      }
   }
}
```

## API Keys Setup

### Supabase Configuration

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Go to [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)
   - Create a token

2. **Setup Database Schema**
   - Load the `project/schema.sql` into your Supabase

3. **Get Required Keys**
   - **Project URL**: `https://your-project.supabase.co`
   - **Service Role Key**: Found in Settings → API → service_role key
   - **Anon Key**: Found in Settings → API → anon key (for frontend use)

### n8n API Key Setup

1. **Access n8n Interface**
   ```bash
   # Start n8n if not running
   make up
   # Open http://localhost:5678
   ```

2. **Generate API Key**
   - Go to Settings → API Keys
   - Click "Create API Key"
   - Name it "Project Integration"
   - Copy the generated key

3. **Configure n8n Credentials**
   - Add Firecrawl API credential
   - Add Supabase API credential
   - Test connections

### Firecrawl API Key

1. **Get Firecrawl API Key**
   - Visit [firecrawl.dev](https://firecrawl.dev)
   - Sign up for an account
   - Generate API key from dashboard

2. **Configure in n8n**
   - Go to Credentials → Add Credential
   - Search for "Firecrawl"
   - Add your API key

## Usage

### Manual Execution

1. Open n8n at http://localhost:5678
2. Navigate to "Soccer Analytics Data Extraction Pipeline"
3. Click "Execute Workflow"
4. Monitor progress in execution log
5. Verify data in Supabase dashboard

### AI Agent Queries

The workflow includes an AI agent for natural language queries:

```
Example queries:
- "How many players are on the roster?"
- "What was the score of the last game?"
- "Show me all home games this season"
- "Which players scored the most goals?"
```

### Available Commands

```bash
# Show all available commands
make help

# Start all services
make up

# Stop all services
make down

# View real-time logs
make logs

# Clean all data (destructive!)
make clean

# Database backup
make backup

# Check service health
make health
```

## Data Flow

1. **Manual Trigger** → User initiates workflow
2. **Data Cleanup** → Remove old Harding 2024 data
3. **AI Scraping** → Firecrawl extracts structured content
4. **Data Extraction** → Parse players and games from markdown
5. **Database Storage** → Store in PostgreSQL via Supabase
6. **Metadata Logging** → Record extraction statistics
7. **AI Analytics** → Query data with natural language

## Directory Structure

```
n8n-projectspace/
├── docker-compose.yaml     # Service configuration
├── Makefile                # Management commands
├── setup.sh                # Environment setup
├── .env                    # Environment variables (generated)
├── .mcp.json               # MCP server configuration
├── CLAUDE.md               # AI assistant instructions
├── project/                # Soccer analytics project
│   ├── requirement.md      # Project requirements
│   ├── design-spec.md      # Technical specification
│   ├── schema.sql          # Database schema
│   └── workflow.json       # n8n workflow definition
└── n8n-workflows/          # Additional workflow samples
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| n8n not starting | Check Docker status: `docker-compose ps` |
| Database connection failed | Verify Supabase credentials in `.env` |
| Firecrawl API error | Check API key and usage limits |
| No data extracted | Verify target website accessibility |
| MCP server not found | Install servers: `npx -y @n8n/n8n-mcp` |

### Health Checks

```bash
# Check n8n health
curl http://localhost:5678/healthz

# Test database connection
docker exec -it project1-postgres-1 psql -U n8n -d n8n -c "SELECT 1;"

# Verify MCP servers
claude mcp list
```

### Log Analysis

```bash
# View n8n logs
docker-compose logs -f n8n

# View database logs
docker-compose logs -f postgres

# View all logs
make logs
```

## Services Overview

### n8n (Port 5678)
- Workflow automation platform
- Web-based workflow editor
- Integrates with 400+ apps and services
- Data stored in PostgreSQL

### PostgreSQL (Port 5432)
- Database for n8n data persistence
- Version: PostgreSQL 16
- Persistent data storage in Docker volume

## Configuration

### Environment Variables

Key configuration options in `.env`:

- `POSTGRES_DB`: Database name (default: n8n)
- `POSTGRES_USER`: Database user (default: n8n)
- `POSTGRES_PASSWORD`: Database password (must be set)
- `N8N_ENCRYPTION_KEY`: Encryption key for credentials (must be 32 characters)
- `TIMEZONE`: Your timezone (default: America/New_York)

### Platform Compatibility

This setup works on both Intel/AMD (x64) and ARM (Apple Silicon) architectures automatically.

## Development

### Extending the System

1. **Multi-School Support**
   - Modify school configuration in database
   - Update workflow URL parameters
   - Add school-specific parsing logic

2. **Additional Sports**
   - Create new database tables
   - Develop sport-specific workflows
   - Extend AI agent capabilities

3. **Advanced Analytics**
   - Add statistical calculations
   - Create dashboard integrations
   - Implement predictive models

## Data Persistence

Your n8n workflows, credentials, and database are automatically saved and will persist across restarts:

- **make down**: Stops services but keeps all your data
- **make up**: Restarts services with all your data intact
- **make clean**: ⚠️ **DELETES ALL DATA** including workflows, users, and database

Only use `make clean` if you want to completely reset everything.

## Updating Services

To update to the latest versions:

```bash
# Pull latest images
make down
docker compose pull
make up
```


## Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Workflow Templates](https://n8n.io/workflows)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase Documentation](https://supabase.com/docs)
- [Firecrawl Documentation](https://docs.firecrawl.dev/)

---

**Built with**: n8n, Supabase, Firecrawl, Docker, PostgreSQL, Claude Code MCP

*Transform your sports data collection from manual processes to automated AI-powered analytics.*