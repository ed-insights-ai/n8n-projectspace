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

The project includes a specialized workflow for soccer analytics:

### Soccer Statistics Scraper 
- **Requirement**: `project/requirement.md`
- **Design**: `project/design-spec.md`
- **Schema**: `project/schema.sql`
- **Workflow**: `project/workflow.json`

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

## n8n Workflow Process

1. **ALWAYS start with**: `tools_documentation()` to understand best practices and available tools.

2. **Discovery Phase** - Find the right nodes:
   - `search_nodes({query: 'keyword'})` - Search by functionality
   - `list_nodes({category: 'trigger'})` - Browse by category
   - `list_ai_tools()` - See AI-capable nodes (remember: ANY node can be an AI tool!)

3. **Configuration Phase** - Get node details efficiently:
   - `get_node_essentials(nodeType)` - Start here! Only 10-20 essential properties
   - `search_node_properties(nodeType, 'auth')` - Find specific properties
   - `get_node_for_task('send_email')` - Get pre-configured templates
   - `get_node_documentation(nodeType)` - Human-readable docs when needed

4. **Pre-Validation Phase** - Validate BEFORE building:
   - `validate_node_minimal(nodeType, config)` - Quick required fields check
   - `validate_node_operation(nodeType, config, profile)` - Full operation-aware validation
   - Fix any validation errors before proceeding

5. **Building Phase** - Create the workflow:
   - Use validated configurations from step 4
   - Connect nodes with proper structure
   - Add error handling where appropriate
   - Use expressions like $json, $node["NodeName"].json
   - Build the workflow in an artifact (unless the user asked to create in n8n instance)

6. **Workflow Validation Phase** - Validate complete workflow:
   - `validate_workflow(workflow)` - Complete validation including connections
   - `validate_workflow_connections(workflow)` - Check structure and AI tool connections
   - `validate_workflow_expressions(workflow)` - Validate all n8n expressions
   - Fix any issues found before deployment

7. **Deployment Phase** (if n8n API configured):
   - `n8n_create_workflow(workflow)` - Deploy validated workflow
   - `n8n_validate_workflow({id: 'workflow-id'})` - Post-deployment validation
   - `n8n_update_partial_workflow()` - Make incremental updates using diffs
   - `n8n_trigger_webhook_workflow()` - Test webhook workflows

### Key Insights

- **VALIDATE EARLY AND OFTEN** - Catch errors before they reach production
- **USE DIFF UPDATES** - Use n8n_update_partial_workflow for 80-90% token savings
- **ANY node can be an AI tool** - not just those with usableAsTool=true
- **Pre-validate configurations** - Use validate_node_minimal before building
- **Post-validate workflows** - Always validate complete workflows before deployment
- **Incremental updates** - Use diff operations for existing workflows
- **Test thoroughly** - Validate both locally and after deployment to n8n

### Validation Strategy

#### Before Building:
1. validate_node_minimal() - Check required fields
2. validate_node_operation() - Full configuration validation
3. Fix all errors before proceeding

#### After Building:
1. validate_workflow() - Complete workflow validation
2. validate_workflow_connections() - Structure validation
3. validate_workflow_expressions() - Expression syntax check

#### After Deployment:
1. n8n_validate_workflow({id}) - Validate deployed workflow
2. n8n_list_executions() - Monitor execution status
3. n8n_update_partial_workflow() - Fix issues using diffs