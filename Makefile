.PHONY: help setup up down logs clean

# Detect the correct docker compose command
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
    DOCKER_COMPOSE := docker compose
endif

# Default target
help:
	@echo "n8n Docker Project - Available Commands"
	@echo "======================================"
	@echo "make setup  - Generate .env file with secure passwords"
	@echo "make up     - Start all services (runs setup if needed)"
	@echo "make down   - Stop all services"
	@echo "make logs   - Show logs from all services"
	@echo "make clean  - Stop services and remove all data"

# Setup environment
setup:
	@./setup.sh

# Start services (with automatic setup)
up:
	@if [ ! -f .env ]; then \
		echo "No .env file found. Running setup..."; \
		./setup.sh; \
	fi
	@$(DOCKER_COMPOSE) up -d
	@echo ""
	@echo "✅ Services started!"
	@echo "Access n8n at: http://localhost:5678"
	@echo ""
	@echo "To view credentials, check your .env file"

# Stop services
down:
	@$(DOCKER_COMPOSE) down
	@echo "✅ Services stopped"

# View logs
logs:
	@$(DOCKER_COMPOSE) logs -f

# Clean everything (careful!)
clean:
	@echo "⚠️  This will delete all data including workflows!"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		echo "✅ All data removed"; \
	else \
		echo "❌ Cancelled"; \
	fi