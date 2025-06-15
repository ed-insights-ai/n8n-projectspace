# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an n8n workflow automation platform deployment using Docker Compose with PostgreSQL as the database backend. The project includes pre-built workflows for soccer statistics scraping and automation tasks.

## Common Commands

### Make Commands (Preferred)
```bash
# Show all available commands
make help

# Generate .env file with secure passwords
make setup

# Start all services (auto-setup if needed)
make up

# Stop all services
make down

# View logs from all services
make logs

# Remove all data (destructive!)
make clean
```

### Direct Docker Commands
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View specific service logs
docker-compose logs -f n8n
docker-compose logs -f postgres

# Check service status
docker-compose ps
```

### Database Management
```bash
# Access PostgreSQL directly
docker exec -it project1-postgres-1 psql -U n8n -d n8n

# Create database backup
docker exec project1-postgres-1 pg_dump -U n8n -d n8n > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker exec -i project1-postgres-1 psql -U n8n -d n8n < backup_file.sql
```

### Health Checks
```bash
# Check n8n health endpoint
curl http://localhost:5678/healthz

# Test PostgreSQL connection
docker exec -it project1-postgres-1 psql -U n8n -d n8n -c "SELECT 1;"
```

## Architecture

The application uses a multi-container Docker setup:

1. **PostgreSQL Database** (port 5432)
   - Database: n8n, User: n8n
   - Persistent volume: postgres_data
   - Health checks enabled

2. **n8n Workflow Automation** (port 5678)
   - Web interface: http://localhost:5678
   - Data persistence via PostgreSQL
   - Workflow files mapped to ./n8n-workflows/
   - Persistent volume: n8n_data

## Key Files

- `docker-compose.yaml` - Main service configuration
- `Makefile` - Convenient management commands
- `setup.sh` - Automated environment setup script
- `.env` - Environment variables (auto-generated)
- `n8n-workflows/` - Workflow JSON files
- `docs/workflow-design.md` - Workflow architecture documentation

## Workflow Structure

The project includes specialized workflows for soccer analytics:

### Soccer Statistics Scraper V2 (Current)
- **File**: `workflow/soccer-v2-fixed.json`
- **Purpose**: Scrapes Harding University soccer statistics from static HTML pages
- **Output**: Relational CSV files (games, players, player_stats, etc.)
- **Architecture**: HTTP requests → HTML parsing → CSV generation
- **Status**: Production POC with known technical debt

### Soccer Analytics V3 (Next Generation)
- **File**: `workflow/soccer-v3-architecture-spec.md`
- **Purpose**: AI-powered soccer data extraction with enterprise database storage
- **Technology**: Firecrawl + Supabase + n8n
- **Architecture**: Firecrawl API → Structured JSON → PostgreSQL database
- **Benefits**: 95% fewer parsing errors, zero maintenance, real-time analytics
- **Status**: Architecture complete, implementation planned

### V3 Key Improvements
- **Reliability**: AI-powered extraction vs brittle CSS selectors
- **Scalability**: PostgreSQL database vs CSV files
- **Maintainability**: Zero-maintenance scraping adapts to website changes
- **Performance**: Single API call vs multiple HTTP requests + parsing
- **Cost**: <$60/month for complete 6-school GAC coverage

### Workflow Import Process
1. Access n8n at http://localhost:5678
2. Navigate to Workflows → Import from File
3. Select workflow JSON files from n8n-workflows/ directory
4. Execute workflows via Manual Trigger nodes

## Environment Configuration

The setup script automatically generates:
- PostgreSQL password (20 random characters)
- n8n encryption key (32-character hex string)
- Timezone configuration (America/Central)

Environment variables are stored in `.env` and never committed to version control.

## Data Persistence

- PostgreSQL data: `postgres_data` Docker volume
- n8n configuration: `n8n_data` Docker volume
- Workflows: Stored in database + file system mapping
- Use `make clean` only when complete data reset is desired