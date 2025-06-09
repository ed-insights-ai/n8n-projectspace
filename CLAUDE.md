# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an n8n workflow automation platform deployment using Docker Compose with PostgreSQL as the database backend. The stack includes:
- CloudNativePG operator and PostgreSQL 16 database
- n8n workflow automation platform
- pgAdmin for database management
- Automated PostgreSQL backup service

## Common Commands

### Starting the Services
```bash
docker-compose up -d
```

### Stopping the Services
```bash
docker-compose down
```

### Viewing Service Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f n8n
docker-compose logs -f postgres
```

### Database Management
```bash
# Access PostgreSQL
docker exec -it project1-postgres-1 psql -U n8n -d n8n

# Manual database backup
docker exec project1-postgres-1 pg_dump -U n8n -d n8n > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker exec -i project1-postgres-1 psql -U n8n -d n8n < backup_file.sql
```

### Service Health Check
```bash
# Check all services status
docker-compose ps

# Check n8n health
curl http://localhost:5678/healthz
```

## Architecture

The application uses a multi-container Docker setup with the following components:

1. **PostgreSQL Database** (port 5432)
   - Database: n8n, User: n8n
   - Persistent volume for data storage

2. **n8n Workflow Automation** (port 5678)
   - Web interface: http://localhost:5678
   - First-time setup wizard for user creation
   - Connected to PostgreSQL for data persistence
   - Workflow files mapped to ./n8n-workflows

## Security Notes

The setup script automatically generates secure credentials:
- PostgreSQL password (random 20 characters)
- n8n encryption key (32-character hex string)

These are stored in the `.env` file. For production deployment, ensure you:
- Keep the `.env` file secure and never commit it to version control
- Use strong passwords if manually creating the `.env` file
- Enable HTTPS with a reverse proxy