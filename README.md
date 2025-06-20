# n8n Workflow Automation Platform

This project provides an easy-to-use Docker Compose setup for running n8n, an extendable workflow automation tool. It includes PostgreSQL for data persistence and custom workflows for soccer-related automation.

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- At least 2GB of available RAM
- 5GB of free disk space

## Quick Start

### Option 1: Automatic Setup (Recommended)

```bash
# Clone or download this repository, then:
make up
```

This will:
- Automatically generate a `.env` file with secure random passwords
- Create required directories
- Start all services
- Display your login credentials

### Option 2: Using the Setup Script

```bash
# Run the setup script
./setup.sh

# Start services
make up
```


## Accessing n8n

### First Time Setup
When you first access n8n:
1. Go to http://localhost:5678
2. You'll see a setup wizard where you'll:
   - Enter your email address
   - Create a password
   - Receive and activate a license key (free for personal use)
3. After setup, you'll use these credentials to log in

### Subsequent Logins
- **URL:** http://localhost:5678
- Use the email and password you created during setup

### Import Workflows

After logging in:
1. Go to Workflows → Import from File
2. Import the workflows from the `n8n-workflows` directory

## Workflows Included

### 1. Soccer Workflow
Soccer-related automation workflow.

**File:** `n8n-workflows/soccer.json`

### 2. Aitor Workflow
Custom workflow for Aitor-related automation.

**File:** `n8n-workflows/aitor.json`

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

## Common Operations

### Using Make Commands

```bash
# Show available commands
make help

# Generate/regenerate .env file
make setup

# Start services (auto-setup if needed)
make up

# Stop services
make down

# View logs
make logs

# Remove all data (careful!)
make clean
```


### Backup Your Workflows

```bash
# Export workflows from n8n UI
# Go to Workflows → Download All

# Or backup the database
docker exec project1-postgres-1 pg_dump -U n8n -d n8n > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore from Backup

```bash
# Restore database backup
docker exec -i project1-postgres-1 psql -U n8n -d n8n < your_backup_file.sql
```

## Directory Structure

```
project1/
├── docker-compose.yaml    # Main configuration file
├── .env                  # Environment variables (auto-generated by setup.sh)
├── .gitignore           # Git ignore file
├── README.md            # This file
├── CLAUDE.md            # Instructions for Claude Code AI
├── setup.sh             # Auto-setup script for generating .env
├── Makefile             # Convenient commands for managing the project
└── n8n-workflows/       # Workflow files
    ├── aitor.json
    └── soccer.json
```

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

## Troubleshooting

### Services won't start

1. Check if ports are already in use:
   ```bash
   # Check if ports are free
   lsof -i :5678  # n8n
   lsof -i :5432  # PostgreSQL
   ```

2. Check Docker logs:
   ```bash
   make logs
   ```

### Environment variable issues

If you see errors about missing environment variables:

1. Ensure `.env` file exists:
   ```bash
   ls -la .env
   ```

2. If missing, run setup:
   ```bash
   make setup
   ```

### Can't connect to PostgreSQL

1. Ensure PostgreSQL is healthy:
   ```bash
   docker compose ps
   ```

2. Test connection:
   ```bash
   docker exec -it project1-postgres-1 psql -U n8n -d n8n -c "SELECT 1;"
   ```

### n8n workflows not persisting

Ensure the n8n_data volume is properly created:
```bash
docker volume ls | grep n8n_data
```

## Security Recommendations

For production use:

1. **Never commit .env to version control** - The `.gitignore` file excludes it
2. **Use strong passwords** (minimum 16 characters, mix of letters, numbers, symbols)
3. **Generate a proper encryption key** for N8N_ENCRYPTION_KEY:
   ```bash
   openssl rand -hex 16
   ```
4. **Enable HTTPS** by adding a reverse proxy (nginx, Traefik, etc.)
5. **Restrict database access** by not exposing PostgreSQL port (remove `ports` section)
6. **Keep services updated** - regularly pull latest images
7. **Rotate credentials regularly** and update the .env file

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

## Next Steps

1. **Explore n8n's capabilities:**
   - Create your own workflows
   - Connect to external services
   - Set up automated tasks

2. **Learn more:**
   - [n8n Documentation](https://docs.n8n.io/)
   - [n8n Workflow Templates](https://n8n.io/workflows)
   - [n8n Community Forum](https://community.n8n.io/)

3. **Extend the setup:**
   - Add a reverse proxy for HTTPS
   - Set up automated backups
   - Configure email notifications

## Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Workflow Templates](https://n8n.io/workflows)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## License

This Docker Compose configuration is provided as-is. n8n is licensed under the [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md).

## Support

For issues with:
- This Docker setup: Create an issue in this repository
- n8n itself: Visit the [n8n community forum](https://community.n8n.io/)
- PostgreSQL: Check the [PostgreSQL documentation](https://www.postgresql.org/docs/)