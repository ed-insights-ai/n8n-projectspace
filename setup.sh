#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🚀 n8n Docker Setup Script"
echo "========================="

# Check if .env file exists
if [ -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file already exists!${NC}"
    read -p "Do you want to regenerate it with new passwords? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ Using existing .env file${NC}"
        exit 0
    fi
    # Backup existing .env
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✓ Backed up existing .env file${NC}"
fi

# Function to generate random password
generate_password() {
    if command -v openssl &> /dev/null; then
        openssl rand -base64 24 | tr -d "=+/" | cut -c1-20
    else
        # Fallback to /dev/urandom if openssl is not available
        tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 20
    fi
}

# Function to generate encryption key (32 chars)
generate_encryption_key() {
    if command -v openssl &> /dev/null; then
        openssl rand -hex 16
    else
        # Fallback to /dev/urandom if openssl is not available
        tr -dc 'a-f0-9' < /dev/urandom | head -c 32
    fi
}

echo "🔐 Generating secure passwords..."

# Generate passwords
POSTGRES_PASSWORD=$(generate_password)
ENCRYPTION_KEY=$(generate_encryption_key)

# Create .env file
cat > .env << EOF
# PostgreSQL Configuration
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# n8n Configuration
N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Timezone Configuration
TIMEZONE=America/Central
EOF

echo -e "${GREEN}✓ Created .env file with secure passwords${NC}"
echo
echo "📋 Generated Configuration:"
echo "========================"
echo "PostgreSQL Password: ${POSTGRES_PASSWORD}"
echo "Encryption Key: ${ENCRYPTION_KEY}"
echo
echo -e "${YELLOW}⚠️  Please save these credentials in a secure location!${NC}"
echo

# Create required directories
echo "📁 Creating required directories..."
mkdir -p n8n-workflows
echo -e "${GREEN}✓ Created n8n-workflows directory${NC}"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop first.${NC}"
    exit 1
fi

echo
echo -e "${GREEN}✅ Setup complete!${NC}"
echo
echo "Next steps:"
# Detect the correct docker compose command
if command -v docker-compose &> /dev/null; then
    echo "1. Run: docker-compose up -d"
else
    echo "1. Run: docker compose up -d"
fi
echo "2. Access n8n at: http://localhost:5678"
echo "3. Complete the n8n setup wizard:"
echo "   - Enter your email address"
echo "   - Create a password"
echo "   - Activate your license (free for personal use)"
echo
echo "To see the generated configuration, check the .env file"