#!/bin/bash
# dev_workspace.sh - One-time setup script for development workspace
# Run this after cloning the repository

set -e

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WORKSPACE_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_header "ROS2 Camera AI Traffic - Development Workspace Setup"

# Make scripts executable
print_info "Making scripts executable..."
chmod +x build.sh run.sh clean.sh setup_env.sh
print_success "Scripts are now executable"

# Create necessary directories
print_info "Creating workspace directories..."
mkdir -p src build install log
print_success "Workspace directories created"

# Create .vscode directory if it doesn't exist
if [ ! -d ".vscode" ]; then
    mkdir -p .vscode
    print_success "Created .vscode directory"
fi

# Check if ROS2 is installed
print_info "Checking ROS2 installation..."
if [ -f "/opt/ros/humble/setup.bash" ]; then
    ROS_DISTRO="humble"
    print_success "ROS2 Humble found"
elif [ -f "/opt/ros/foxy/setup.bash" ]; then
    ROS_DISTRO="foxy"
    print_success "ROS2 Foxy found"
else
    print_error "ROS2 not found! Please install ROS2 first."
    echo ""
    echo "Installation instructions:"
    echo "https://docs.ros.org/en/humble/Installation.html"
    exit 1
fi

# Source ROS2 and install dependencies
print_info "Installing dependencies..."
source /opt/ros/$ROS_DISTRO/setup.bash

# Install colcon if not present
if ! command -v colcon &> /dev/null; then
    print_info "Installing colcon..."
    sudo apt update
    sudo apt install -y python3-colcon-common-extensions
    print_success "colcon installed"
else