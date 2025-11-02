
build.sh
#!/bin/bash
# build.sh - Build ROS2 workspace
# Usage: ./build.sh [package_name] [options]

set -e

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WORKSPACE_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PACKAGE_NAME="${1:all}"
BUILD_TYPE="${2:default}"
SYMLINK_INSTALL="--symlink-install"
PARALLEL_JOBS=$(nproc)

# Functions
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

show_help() {
    echo "Usage: ./build.sh [package_name] [options]"
    echo ""
    echo "Arguments:"
    echo "  package_name    Build specific package or 'all' for entire workspace (default: all)"
    echo "  options         Additional colcon build options"
    echo ""
    echo "Examples:"
    echo "  ./build.sh all                          # Build entire workspace"
    echo "  ./build.sh MainProcess                  # Build MainProcess package only"
    echo "  ./build.sh ai_detection --cmake-args -DCMAKE_BUILD_TYPE=Release"
    echo ""
}

# Main
print_header "ROS2 Camera AI Traffic - Build Script"

if [[ "$PACKAGE_NAME" == "-h" ]] || [[ "$PACKAGE_NAME" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if src directory exists
if [ ! -d "src" ]; then
    print_error "src directory not found! Please run this script from workspace root."
    exit 1
fi

# Source ROS2 setup
if [ -f "/opt/ros/foxy/setup.bash" ]; then
    source /opt/ros/foxy/setup.bash
    print_info "Sourced ROS2 Foxy"
elif [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
    print_info "Sourced ROS2 Humble"
else
    print_error "ROS2 not found! Please install ROS2 first."
    exit 1
fi

# Build command
print_info "Building workspace..."
print_info "Build type: $PACKAGE_NAME"
print_info "Parallel jobs: $PARALLEL_JOBS"
echo ""

if [ "$PACKAGE_NAME" = "all" ]; then
    print_info "Building all packages..."
    colcon build \
        $SYMLINK_INSTALL \
        --parallel-workers $PARALLEL_JOBS \
        --event-handlers desktop_notification- \
        $2 $3 $4 $5
else
    print_info "Building package: $PACKAGE_NAME"
    colcon build \
        --packages-select $PACKAGE_NAME \
        $SYMLINK_INSTALL \
        --parallel-workers $PARALLEL_JOBS \
        --event-handlers desktop_notification- \
        $2 $3 $4 $5
fi

# Check build result
if [ $? -eq 0 ]; then
    print_success "Build completed successfully!"
    print_info "Sourcing install/setup.bash for current session..."
    source install/setup.bash
    print_success "Environment updated!"
else
    print_error "Build failed! Check log directory for details."
    exit 1
fi