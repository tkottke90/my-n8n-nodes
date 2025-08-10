#! /bin/bash

# Exit on any error
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy n8n custom nodes to local development environment"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script builds the custom n8n nodes and deploys them to the local"
    echo "  development environment. It requires the env-dev folder to exist (created"
    echo "  by running 'docker-compose up -d' first)."
    echo ""
    echo "PREREQUISITES:"
    echo "  - Docker and docker-compose must be running"
    echo "  - n8n development environment must be started with 'docker-compose up -d'"
    echo "  - pnpm must be installed and available"
    echo ""
}

# Function to handle errors
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Variables
PROJECT_PATH="env-dev/.n8n/custom/@tkottke/my-n8n-nodes"

# Check if dev folder exists, abort if missing
echo "🔍 Checking if env-dev folder exists..."
if [ ! -d "env-dev" ]; then
  error_exit "env-dev folder not found. Please run n8n in a separate terminal first:

  docker-compose up -d"
fi
echo "✅ env-dev folder found"

# Check if pnpm is available
echo "🔍 Checking if pnpm is available..."
if ! command -v pnpm &> /dev/null; then
    error_exit "pnpm is not installed or not in PATH. Please install pnpm first:

    npm install -g pnpm"
fi
echo "✅ pnpm is available"

# Check if the `custom` folder exists in the `env-dev` folder, create it if not
echo "📁 Setting up custom folder structure..."
if [ ! -d $PROJECT_PATH ]; then
  mkdir -p "$PROJECT_PATH" || error_exit "Failed to create custom folder structure"
  echo "✅ Created custom folder structure"
else
  echo "✅ Custom folder structure already exists"
fi

# Clear out the `custom` folder
echo "🧹 Clearing existing custom nodes..."
rm -rf env-dev/custom/* || error_exit "Failed to clear custom folder"
echo "✅ Custom folder cleared"

# Build the project
echo "🔨 Building the project..."
if ! npx pnpm build; then
    error_exit "Project build failed. Please check the build output above for errors."
fi
echo "✅ Project build completed"

# Check if dist folder exists
if [ ! -d "dist" ]; then
    error_exit "dist folder not found after build. Build may have failed."
fi

# Check if dist folder has content
if [ -z "$(ls -A dist)" ]; then
    error_exit "dist folder is empty after build. Build may have failed."
fi

# Copy the `dist` folder to the `custom` folder
echo "📦 Deploying built files to custom nodes folder..."
if ! cp -r dist/* "$PROJECT_PATH"; then
    error_exit "Failed to copy built files to custom nodes folder"
fi
echo "✅ Deployment completed successfully!"

# Restart n8n
echo "🔄 Restarting n8n to apply changes..."
docker-compose restart n8n

echo ""
echo "🎉 Local deployment complete! Your custom n8n nodes are now available in the development environment."
echo "   You may need to restart n8n to see the changes."


