.PHONY: help setup up down logs clean status v3-setup v3-validate v3-credentials v3-create-workflow v3-full-setup mcp-setup mcp-status mcp-restart full-setup

# Detect the correct docker compose command
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
    DOCKER_COMPOSE := docker compose
endif

# Default target
help:
	@echo "n8n Docker Project - Available Commands"
	@echo "======================================"
	@echo "Core Commands:"
	@echo "make setup     - Generate .env file with secure passwords"
	@echo "make up        - Start all services (runs setup if needed)"
	@echo "make down      - Stop all services"
	@echo "make logs      - Show logs from all services"
	@echo "make status    - Show service status and license info"
	@echo "make clean     - Stop services and remove all data"
	@echo ""
	@echo "V3 Soccer Analytics Commands:"
	@echo "make v3-setup           - Setup V3 with Firecrawl + Supabase credentials"
	@echo "make v3-create-workflow - Generate V3 workflow JSON file"
	@echo "make v3-full-setup      - Complete V3 setup (credentials + workflow)"
	@echo "make v3-validate        - Validate V3 configuration and connections"
	@echo "make v3-credentials     - Display V3 credential setup instructions"
	@echo ""
	@echo "Claude Code MCP Commands:"
	@echo "make mcp-setup          - Setup Claude Code MCP servers (Context7 + Supabase)"
	@echo "make mcp-status         - Check MCP server status"
	@echo "make mcp-restart        - Restart MCP servers"
	@echo "make full-setup         - Complete setup (n8n + V3 + MCP)"

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
	@if grep -q "N8N_LICENSE=" .env; then \
		LICENSE_KEY=$$(grep N8N_LICENSE .env | cut -d'=' -f2); \
		echo "🔑 n8n License: $$LICENSE_KEY (activated)"; \
		echo ""; \
	fi
	@if grep -q "N8N_BASIC_AUTH_USER=" .env; then \
		AUTH_USER=$$(grep N8N_BASIC_AUTH_USER .env | cut -d'=' -f2); \
		AUTH_PASS=$$(grep N8N_BASIC_AUTH_PASSWORD .env | cut -d'=' -f2); \
		echo "👤 Login: $$AUTH_USER / $$AUTH_PASS"; \
		echo ""; \
	fi
	@echo "To view all credentials, check your .env file"

# Stop services
down:
	@$(DOCKER_COMPOSE) down
	@echo "✅ Services stopped"

# View logs
logs:
	@$(DOCKER_COMPOSE) logs -f

# Show status and license info
status:
	@echo "🔍 n8n Service Status"
	@echo "===================="
	@echo ""
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@if [ -f .env ]; then \
		echo "📋 Configuration:"; \
		if grep -q "N8N_LICENSE=" .env; then \
			LICENSE_KEY=$$(grep N8N_LICENSE .env | cut -d'=' -f2); \
			echo "🔑 License: $$LICENSE_KEY"; \
		else \
			echo "❌ No license key found"; \
		fi; \
		if grep -q "N8N_BASIC_AUTH_USER=" .env; then \
			AUTH_USER=$$(grep N8N_BASIC_AUTH_USER .env | cut -d'=' -f2); \
			AUTH_PASS=$$(grep N8N_BASIC_AUTH_PASSWORD .env | cut -d'=' -f2); \
			echo "👤 Login: $$AUTH_USER / $$AUTH_PASS"; \
		fi; \
		echo "🌐 Access: http://localhost:5678"; \
	else \
		echo "❌ No .env file found. Run 'make setup' first."; \
	fi
	@echo ""
	@echo "⚽ V3 Soccer Analytics:"; \
	if grep -q "FIRECRAWL_API_KEY=" .env; then \
		echo "✅ Firecrawl configured"; \
	else \
		echo "❌ Firecrawl not configured"; \
	fi; \
	if grep -q "SUPABASE_URL=" .env; then \
		echo "✅ Supabase configured"; \
	else \
		echo "❌ Supabase not configured"; \
	fi
	@echo ""
	@echo "🤖 Claude Code MCP:"
	@if command -v claude &> /dev/null; then \
		echo "✅ Claude Code installed"; \
		echo "📋 MCP servers:"; \
		claude mcp list 2>/dev/null | grep -E "^\s*-\s" || echo "   No MCP servers configured"; \
	else \
		echo "❌ Claude Code not installed"; \
	fi

# Clean everything (careful!)
clean:
	@echo "⚠️  This will delete all data including workflows!"
	@echo "Note: .env file will be preserved (contains license key)"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		echo "✅ All data removed"; \
		echo "✅ .env file preserved with license key"; \
		echo ""; \
		echo "🚀 Restarting services with license activation..."; \
		$(DOCKER_COMPOSE) up -d; \
		echo ""; \
		echo "⏳ Waiting for n8n to start..."; \
		sleep 10; \
		echo "✅ Services restarted with license activated"; \
		echo "📋 Access n8n at: http://localhost:5678"; \
		if grep -q "N8N_LICENSE=" .env; then \
			LICENSE_KEY=$$(grep N8N_LICENSE .env | cut -d'=' -f2); \
			echo "🔑 License: $$LICENSE_KEY (auto-activated)"; \
		fi; \
	else \
		echo "❌ Cancelled"; \
	fi

# V3 Soccer Analytics Setup
v3-setup:
	@echo "🚀 Soccer Analytics V3 Setup"
	@echo "============================"
	@echo ""
	@if grep -q "FIRECRAWL_API_KEY=" .env && grep -q "SUPABASE_URL=" .env; then \
		echo "✅ V3 credentials already configured in .env file"; \
		FIRECRAWL_KEY=$$(grep FIRECRAWL_API_KEY .env | cut -d'=' -f2); \
		SUPABASE_URL=$$(grep SUPABASE_URL .env | cut -d'=' -f2); \
		echo "🔑 Firecrawl: $$FIRECRAWL_KEY"; \
		echo "🗄️  Supabase: $$SUPABASE_URL"; \
	else \
		echo "📝 Adding V3 credentials to .env file..."; \
		echo "" >> .env; \
		echo "# V3 Soccer Analytics Configuration" >> .env; \
		read -p "Enter your Firecrawl API key (fc-...): " FIRECRAWL_KEY; \
		echo "FIRECRAWL_API_KEY=$$FIRECRAWL_KEY" >> .env; \
		read -p "Enter your Supabase URL (https://...supabase.co): " SUPABASE_URL; \
		echo "SUPABASE_URL=$$SUPABASE_URL" >> .env; \
		read -p "Enter your Supabase API key (eyJ...): " SUPABASE_KEY; \
		echo "SUPABASE_API_KEY=$$SUPABASE_KEY" >> .env; \
		echo "SUPABASE_ACCESS_TOKEN=$$SUPABASE_KEY" >> .env; \
		echo ""; \
		echo "✅ Added V3 credentials to main .env file"; \
	fi
	@echo ""
	@echo "🔧 Next steps:"
	@echo "1. Run 'make v3-create-workflow' to generate workflow"
	@echo "2. Import generated workflow into n8n"
	@echo "3. Run 'make v3-validate' to test configuration"

# Display V3 credential setup instructions
v3-credentials:
	@echo "🔑 V3 n8n Credential Setup Instructions"
	@echo "======================================"
	@echo ""
	@echo "1. Open n8n at http://localhost:5678"
	@echo "2. Go to Settings → Credentials"
	@echo "3. Add 'HTTP Header Auth' credential:"
	@echo "   - Name: 'Firecrawl API'"
	@echo "   - Header Name: 'Authorization'"
	@if grep -q "FIRECRAWL_API_KEY=" .env; then \
		FIRECRAWL_KEY=$$(grep FIRECRAWL_API_KEY .env | cut -d'=' -f2); \
		echo "   - Header Value: 'Bearer $$FIRECRAWL_KEY'"; \
	else \
		echo "   - Header Value: 'Bearer YOUR_FIRECRAWL_KEY'"; \
	fi
	@echo ""
	@echo "4. (Optional) Add 'Supabase' credential if using Supabase nodes:"
	@if grep -q "SUPABASE_URL=" .env; then \
		SUPABASE_URL=$$(grep SUPABASE_URL .env | cut -d'=' -f2 | sed 's|https://||' | sed 's|\.supabase\.co||'); \
		SUPABASE_KEY=$$(grep SUPABASE_API_KEY .env | cut -d'=' -f2); \
		echo "   - Host: '$$SUPABASE_URL.supabase.co'"; \
		echo "   - API Key: '$$SUPABASE_KEY'"; \
	else \
		echo "   - Host: 'your-project.supabase.co'"; \
		echo "   - API Key: 'your-supabase-key'"; \
	fi

# Validate V3 configuration
v3-validate:
	@echo "🔍 Validating V3 Configuration"
	@echo "=============================="
	@echo ""
	@if ! grep -q "FIRECRAWL_API_KEY=" .env; then \
		echo "❌ Firecrawl API key not found in .env. Run 'make v3-setup' first."; \
		exit 1; \
	fi
	@echo "✅ Main .env file exists"
	@if grep -q "FIRECRAWL_API_KEY=fc-" .env; then \
		echo "✅ Firecrawl API key configured"; \
	else \
		echo "❌ Firecrawl API key missing or invalid"; \
	fi
	@if grep -q "SUPABASE_URL=https://" .env; then \
		echo "✅ Supabase URL configured"; \
	else \
		echo "❌ Supabase URL missing or invalid"; \
	fi
	@if grep -q "SUPABASE_API_KEY=eyJ" .env; then \
		echo "✅ Supabase API key configured"; \
	else \
		echo "❌ Supabase API key missing or invalid"; \
	fi
	@echo ""
	@if [ -f workflow/soccer-v3-generated.json ]; then \
		echo "✅ V3 generated workflow file exists"; \
	elif [ -f workflow/soccer-v3-clean.json ]; then \
		echo "✅ V3 clean workflow file exists"; \
	else \
		echo "❌ V3 workflow file missing - run 'make v3-create-workflow'"; \
	fi
	@echo ""
	@echo "🚀 Ready to test V3 workflow!"
	@echo "Import workflow file into n8n and execute."

# Create V3 workflow JSON file dynamically

# Claude Code MCP Server Setup
mcp-setup:
	@echo "🤖 Setting up Claude Code MCP Servers"
	@echo "====================================="
	@echo ""
	@echo "📋 Checking Claude Code installation..."
	@if ! command -v claude &> /dev/null; then \
		echo "❌ Claude Code not found. Please install Claude Code first:"; \
		echo "   https://claude.ai/code"; \
		exit 1; \
	fi
	@echo "✅ Claude Code found"
	@echo ""
	@echo "🔧 Setting up Context7 MCP server..."
	@claude mcp add context7 -s local npx -y @context7/mcp-server@latest
	@echo "✅ Context7 MCP server added"
	@echo ""
	@echo "🔧 Setting up Supabase MCP server..."
	@claude mcp add-json supabase '{"command":"npx","args":["-y","@supabase/mcp-server-supabase@latest"]}'
	@echo "✅ Supabase MCP server added"
	@echo ""
	@echo "🔑 Configuring Supabase MCP with credentials..."
	@if grep -q "SUPABASE_URL=" .env && grep -q "SUPABASE_ACCESS_TOKEN=" .env; then \
		SUPABASE_URL=$$(grep SUPABASE_URL .env | cut -d'=' -f2); \
		SUPABASE_TOKEN=$$(grep SUPABASE_ACCESS_TOKEN .env | cut -d'=' -f2); \
		echo "   Setting SUPABASE_URL=$$SUPABASE_URL"; \
		echo "   Setting SUPABASE_ACCESS_TOKEN=$$SUPABASE_TOKEN"; \
		echo "⚠️  Note: MCP environment variables should be set in your shell profile"; \
		echo "   Add these to ~/.zshrc or ~/.bashrc:"; \
		echo "   export SUPABASE_URL=$$SUPABASE_URL"; \
		echo "   export SUPABASE_ACCESS_TOKEN=$$SUPABASE_TOKEN"; \
	else \
		echo "❌ Supabase credentials not found in .env"; \
		echo "   Run 'make v3-setup' first to configure Supabase"; \
	fi
	@echo ""
	@echo "✅ MCP servers configured!"
	@echo ""
	@echo "🧪 Testing MCP server status..."
	@claude mcp list
	@echo ""
	@echo "🎉 MCP Setup Complete!"
	@echo "You can now use Claude Code with Supabase and Context7 integration"

# Check MCP server status
mcp-status:
	@echo "🔍 Claude Code MCP Server Status"
	@echo "================================"
	@echo ""
	@if ! command -v claude &> /dev/null; then \
		echo "❌ Claude Code not installed"; \
		exit 1; \
	fi
	@echo "📋 Installed MCP servers:"
	@claude mcp list
	@echo ""
	@echo "🔧 Environment variables needed for Supabase MCP:"
	@if grep -q "SUPABASE_URL=" .env; then \
		SUPABASE_URL=$$(grep SUPABASE_URL .env | cut -d'=' -f2); \
		SUPABASE_TOKEN=$$(grep SUPABASE_ACCESS_TOKEN .env | cut -d'=' -f2); \
		echo "   SUPABASE_URL=$$SUPABASE_URL"; \
		echo "   SUPABASE_ACCESS_TOKEN=$$SUPABASE_TOKEN"; \
		echo ""; \
		echo "💡 To use in Claude Code, ensure these are exported in your shell:"; \
		echo "   export SUPABASE_URL=$$SUPABASE_URL"; \
		echo "   export SUPABASE_ACCESS_TOKEN=$$SUPABASE_TOKEN"; \
	else \
		echo "❌ Supabase credentials not configured"; \
	fi

# Restart MCP servers
mcp-restart:
	@echo "🔄 Restarting Claude Code MCP Servers"
	@echo "====================================="
	@echo ""
	@if ! command -v claude &> /dev/null; then \
		echo "❌ Claude Code not installed"; \
		exit 1; \
	fi
	@echo "🔄 Restarting MCP servers..."
	@claude mcp restart
	@echo "✅ MCP servers restarted"
	@echo ""
	@echo "📋 Current status:"
	@claude mcp list

# Complete setup - everything together
full-setup: setup v3-setup mcp-setup
	@echo ""
	@echo "🎉 COMPLETE SETUP FINISHED!"
	@echo "=========================="
	@echo ""
	@echo "✅ n8n Docker environment ready"
	@echo "✅ V3 Soccer Analytics configured"
	@echo "✅ Claude Code MCP servers installed"
	@echo ""
	@echo "🚀 Next steps:"
	@echo "1. Start n8n: make up"
	@echo "2. Generate V3 workflow: make v3-create-workflow"
	@echo "3. Import workflow into n8n at http://localhost:5678"
	@echo "4. Test Claude Code with MCP integration"
	@echo ""
	@echo "📋 Quick commands:"
	@echo "   make status      - Check all service status"
	@echo "   make mcp-status  - Check MCP server status"
	@echo "   make v3-validate - Validate V3 configuration"# Create V3 workflow JSON file dynamically
v3-create-workflow:
	@echo "🛠️  V3 Workflow Setup"
	@echo "====================="
	@echo ""
	@if ! grep -q "FIRECRAWL_API_KEY=" .env; then \
		echo "❌ V3 credentials not found in .env. Run 'make v3-setup' first."; \
		exit 1; \
	fi
	@if [ ! -f workflow/soccer-v3-clean.json ]; then \
		echo "❌ Base workflow file missing. Please ensure workflow/soccer-v3-clean.json exists."; \
		exit 1; \
	fi
	@echo "📝 Using existing clean workflow: workflow/soccer-v3-clean.json"
	@echo "✅ V3 workflow ready for import into n8n"
	@echo ""
	@echo "📋 Next Steps:"
	@echo "   1. Start n8n: make up"
	@echo "   2. Open http://localhost:5678"
	@echo "   3. Import workflow/soccer-v3-clean.json"
	@echo "   4. Configure credentials in n8n (Firecrawl API key, Supabase URL/key)"
	@echo "   5. Run workflow with Manual Trigger"

# Complete V3 setup - credentials + workflow validation
v3-full-setup: v3-setup v3-create-workflow
	@echo ""
	@echo "🎉 Complete V3 Setup Finished!"
	@echo "=============================="
	@echo ""
	@echo "📁 V3 Configuration:"
	@echo "   ✅ Credentials configured in .env"
	@echo "   ✅ soccer-v3-clean.json workflow ready"
	@echo ""
	@echo "🚀 Ready to import workflow into n8n!"
