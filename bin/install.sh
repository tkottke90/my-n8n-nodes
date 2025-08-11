#!/bin/bash

# Exit on any error
set -e

# Configuration
REPO_OWNER="tkottke90"
REPO_NAME="my-n8n-nodes"
PACKAGE_NAME="@tkottke90-my-n8n-nodes"
N8N_CUSTOM_DIR="/home/node/.n8n/custom"
VERSION_FILE="$N8N_CUSTOM_DIR/.${REPO_NAME}.version"
TEMP_DIR=""
DRY_RUN=false
VERBOSE=false

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install n8n custom nodes package from GitHub releases"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --version VERSION   Install specific version (e.g., v1.0.0)"
    echo "  -L, --list-versions     List available versions"
    echo "  --location              Show location of version file"
    echo "  --dry-run              Show what would be done without making changes"
    echo "  --verbose              Enable verbose output"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script downloads and installs the latest release of $PACKAGE_NAME"
    echo "  into your n8n custom nodes directory (~/.n8n/custom)."
    echo ""
    echo "EXAMPLES:"
    echo "  $0                      # Install latest version"
    echo "  $0 -v v1.2.3           # Install specific version"
    echo "  $0 -L                  # List available versions"
    echo "  $0 --dry-run           # Preview what would be installed"
    echo ""
}

# Function to handle errors and cleanup
error_exit() {
    echo "❌ Error: $1" >&2
    cleanup
    exit 1
}

# Function to cleanup temporary files
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log_verbose "🧹 Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Function to log verbose messages
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "🔍 $1"
    fi
}

# Function to log dry run actions
log_dry_run() {
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 [DRY RUN] $1"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get GitHub API URL
get_api_url() {
    echo "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"
}

# Function to list available versions
list_versions() {
    echo "📋 Fetching available versions..."

    if ! command_exists wget; then
        error_exit "wget is required but not installed"
    fi

    local api_url=$(get_api_url)
    local releases=$(wget -qO- "$api_url/releases" | grep '"tag_name":' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' | head -20)

    if [ -z "$releases" ]; then
        error_exit "No releases found or failed to fetch releases"
    fi

    echo "Available versions:"
    echo "$releases" | while read -r version; do
        echo "  $version"
    done
}

# Function to get latest release info
get_latest_release() {
    local api_url=$(get_api_url)
    wget -qO- "$api_url/releases/latest"
}

# Function to get specific release info
get_release_info() {
    local version="$1"
    local api_url=$(get_api_url)
    wget -qO- "$api_url/releases/tags/$version"
}

# Function to extract download URL from release info
get_download_url() {
    local release_info="$1"
    echo "$release_info" | grep '"browser_download_url":' | grep '\.tar\.gz"' | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/'
}

# Function to extract version from release info
get_version_from_release() {
    local release_info="$1"
    echo "$release_info" | grep '"tag_name":' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
}

# Function to create n8n custom directory if it doesn't exist
ensure_custom_dir() {
    if [ ! -d "$N8N_CUSTOM_DIR" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_dry_run "Would create directory: $N8N_CUSTOM_DIR"
        else
            echo "📁 Creating n8n custom directory: $N8N_CUSTOM_DIR"
            mkdir -p "$N8N_CUSTOM_DIR" || error_exit "Failed to create custom directory"
        fi
    fi
}

# Function to download and extract package
download_and_extract() {
    local download_url="$1"
    local version="$2"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d) || error_exit "Failed to create temporary directory"
    log_verbose "Created temporary directory: $TEMP_DIR"
    
    # Download the tarball
    echo "📥 Downloading $PACKAGE_NAME $version..."
    local tarball_path="$TEMP_DIR/package.tar.gz"
    
    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would download: $download_url"
        log_dry_run "Would extract to: $TEMP_DIR"
        return 0
    fi
    
    if ! wget -q -O "$tarball_path" "$download_url"; then
        error_exit "Failed to download package from $download_url"
    fi
    
    # Extract the tarball
    echo "📦 Extracting package..."
    if ! tar -xzf "$tarball_path" -C "$TEMP_DIR"; then
        error_exit "Failed to extract package"
    fi
    
    log_verbose "Package extracted to: $TEMP_DIR"
}

# Function to sync files to n8n custom directory
sync_files() {
    local version="$1"
    
    # Find the extracted directory (should contain the dist files)
    local source_dir
    if [ -d "$TEMP_DIR/dist" ]; then
        source_dir="$TEMP_DIR/dist/"
    else
        # Look for any directory that might contain the files
        source_dir=$(find "$TEMP_DIR" -type d -name "dist" | head -1)
        if [ -z "$source_dir" ]; then
            error_exit "Could not find dist directory in extracted package"
        fi
        source_dir="$source_dir/"
    fi
    
    echo "🔄 Syncing files to n8n custom directory..."
    
    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would sync from: $source_dir"
        log_dry_run "Would sync to: $N8N_CUSTOM_DIR/"
        log_dry_run "Would exclude: package.json, tsconfig.buildinfo"
        log_dry_run "Would update version file: $VERSION_FILE"
        return 0
    fi
    
    # Use rsync to sync files, excluding package.json and tsconfig.buildinfo
    if ! rsync -av --exclude="package.json" --exclude="tsconfig.buildinfo" "$source_dir" "$N8N_CUSTOM_DIR/"; then
        error_exit "Failed to sync files to custom directory"
    fi
    
    # Update version file
    echo "$version" > "$VERSION_FILE" || error_exit "Failed to update version file"
    
    echo "✅ Installation completed successfully!"
    echo "   Installed version: $version"
    echo "   Location: $N8N_CUSTOM_DIR"
}

# Function to get current installed version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo ""
    fi
}

# Function to show current installed version
show_current_version() {
    local current_version=$(get_current_version)
    if [ -n "$current_version" ]; then
        echo "📌 Currently installed version: $current_version"
    else
        echo "📌 No version currently installed"
    fi
}

# Function to show version file location
show_version_file_location() {
    if [ -f "$VERSION_FILE" ]; then
        echo "$VERSION_FILE"
    else
        echo "NONE"
    fi
}

# Function to prompt user for yes/no confirmation
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

# Function to check version and prompt for confirmation if same
check_version_and_confirm() {
    local target_version="$1"
    local current_version=$(get_current_version)

    if [ -n "$current_version" ] && [ "$current_version" = "$target_version" ]; then
        echo ""
        echo "⚠️  Version $target_version is already installed."
        echo ""
        if [ "$DRY_RUN" = true ]; then
            log_dry_run "Would prompt user for re-installation confirmation"
            return 0
        fi

        if ! prompt_yes_no "Do you want to re-download and reinstall this version?"; then
            echo "❌ Installation cancelled by user."
            exit 0
        fi
        echo ""
    fi
}

# Main installation function
install_package() {
    local target_version="$1"
    local release_info
    
    # Check required commands
    for cmd in wget tar rsync; do
        if ! command_exists "$cmd"; then
            error_exit "$cmd is required but not installed"
        fi
    done
    
    # Get release information
    if [ -n "$target_version" ]; then
        echo "🔍 Fetching release information for version: $target_version"
        release_info=$(get_release_info "$target_version")
    else
        echo "🔍 Fetching latest release information..."
        release_info=$(get_latest_release)
    fi
    
    if [ -z "$release_info" ] || echo "$release_info" | grep -q '"message": "Not Found"'; then
        if [ -n "$target_version" ]; then
            error_exit "Version $target_version not found"
        else
            error_exit "No releases found"
        fi
    fi
    
    # Extract download URL and version
    local download_url=$(get_download_url "$release_info")
    local version=$(get_version_from_release "$release_info")
    
    if [ -z "$download_url" ]; then
        error_exit "Could not find download URL for package"
    fi
    
    echo "📋 Package: $PACKAGE_NAME"
    echo "📋 Version: $version"
    echo "📋 Download URL: $download_url"

    show_current_version

    # Check if same version is already installed and prompt for confirmation
    check_version_and_confirm "$version"

    # Ensure custom directory exists
    ensure_custom_dir
    
    # Download and extract
    download_and_extract "$download_url" "$version"
    
    # Sync files
    sync_files "$version"
    
    # Cleanup
    cleanup
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Parse command line arguments
TARGET_VERSION=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            TARGET_VERSION="$2"
            shift 2
            ;;
        -L|--list-versions)
            list_versions
            exit 0
            ;;
        --location)
            show_version_file_location
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
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

# Main execution
echo "🚀 Installing $PACKAGE_NAME..."
echo ""

install_package "$TARGET_VERSION"
