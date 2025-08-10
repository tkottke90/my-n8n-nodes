#!/bin/bash

# Exit on any error
set -e

# Global variables
VERBOSE=false

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Setup script for n8n custom nodes development environment"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script sets up the development environment by:"
    echo "  1. Installing pnpm locally using npx"
    echo "  2. Installing node modules with pnpm"
    echo "  3. Checking if Docker is installed"
    echo "  4. Optionally starting the Docker container"
    echo ""
    echo "PREREQUISITES:"
    echo "  - Node.js must be installed"
    echo "  - Docker (optional, but recommended for development)"
    echo ""
}

# Function to handle errors
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Function to log verbose messages
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "🔍 $1"
    fi
}

# Function to run commands with optional verbose output
run_command() {
    local cmd="$1"
    local description="$2"
    
    log_verbose "Running: $cmd"
    
    if [ "$VERBOSE" = true ]; then
        eval "$cmd" || error_exit "$description failed"
    else
        eval "$cmd" >/dev/null 2>&1 || error_exit "$description failed"
    fi
}

# Function to prompt user for yes/no
prompt_yes_no() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (y/n): " response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "❌ Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

echo "🚀 Setting up n8n custom nodes development environment..."
echo ""

# Check if Node.js is installed
echo "🔍 Checking if Node.js is installed..."
if ! command -v node &> /dev/null; then
    error_exit "Node.js is not installed. Please install Node.js first:
    
    Visit: https://nodejs.org/"
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js is installed (version: $NODE_VERSION)"

# Check if npx is available
echo "🔍 Checking if npx is available..."
if ! command -v npx &> /dev/null; then
    error_exit "npx is not available. Please update Node.js to a version that includes npx."
fi
echo "✅ npx is available"

# Install pnpm locally using npx
echo "📦 Installing pnpm locally..."
log_verbose "This will install pnpm in the local project directory as we do not believe in blanket global npm installs"
run_command "npx pnpm --version" "pnpm installation check"
echo "✅ pnpm is ready to use"

# Install node modules
echo "📚 Installing node modules..."
log_verbose "Installing dependencies using pnpm"
if [ "$VERBOSE" = true ]; then
    npx pnpm install || error_exit "Failed to install node modules"
else
    npx pnpm install --silent || error_exit "Failed to install node modules"
fi
echo "✅ Node modules installed successfully"

# Check if Docker is installed
echo "🐳 Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "⚠️  Warning: Docker is not installed or not in PATH."
    echo "   Docker is recommended for running the n8n development environment."
    echo "   You can install Docker from: https://docs.docker.com/get-docker/"
    echo ""
    echo "   You can still develop without Docker, but you'll need to run n8n manually."
    echo "   See the N8N Documentation for instructions: https://docs.n8n.io/integrations/creating-nodes/test/run-node-locally/"
else
    DOCKER_VERSION=$(docker --version)
    echo "✅ Docker is installed ($DOCKER_VERSION)"
    
    # Check if docker-compose is available
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version)
        echo "✅ Docker Compose is available ($COMPOSE_VERSION)"
        
        # Check if docker-compose.yml exists
        if [ -f "docker-compose.yml" ]; then
            echo ""
            if prompt_yes_no "🚀 Would you like to start the Docker container now?"; then
                echo "🔄 Starting Docker container..."
                if [ "$VERBOSE" = true ]; then
                    docker-compose up -d || error_exit "Failed to start Docker container"
                else
                    docker-compose up -d >/dev/null 2>&1 || error_exit "Failed to start Docker container"
                fi
                echo "✅ Docker container started successfully"
                echo ""
                echo "🌐 n8n should be available at: http://localhost:5678"
            else
                echo "⏭️  Skipping Docker container startup"
                echo "   You can start it later with: docker-compose up -d"
            fi
        else
            echo "⚠️  Warning: docker-compose.yml not found in current directory"
            echo "   Make sure you're running this script from the project root"
        fi
    else
        echo "⚠️  Warning: docker-compose is not available"
        echo "   Please install Docker Compose to use the development environment"
    fi
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. If Docker is running, n8n should be available at http://localhost:5678"
echo "   2. Make your changes to the custom nodes"
echo "   3. Run './bin/deploy-local.sh' to deploy your changes"
echo "   4. Restart n8n if needed to see your changes"
echo ""
echo "💡 Useful commands:"
echo "   - Start Docker: docker-compose up -d"
echo "   - Stop Docker: docker-compose down"
echo "   - View logs: docker-compose logs -f"
echo "   - Deploy changes: ./bin/deploy-local.sh"
