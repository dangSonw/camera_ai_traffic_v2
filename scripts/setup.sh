#!/bin/bash
# setup_env.sh - Setup ROS2 development environment
# Run once to configure your shell environment

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_header "ROS2 Camera AI Traffic - Environment Setup"

# Determine shell config file
SHELL_RC=""
if [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
elif [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
else
    print_info "Could not find shell config file. Please manually add the following to your shell config:"
    echo ""
    echo "# ROS2 Camera AI Traffic Setup"
    echo "export CAMERA_AI_TRAFFIC_WS=$WORKSPACE_DIR"
    echo "source /opt/ros/humble/setup.bash  # or foxy"
    echo "source \$CAMERA_AI_TRAFFIC_WS/install/setup.bash"
    echo "alias cb='cd \$CAMERA_AI_TRAFFIC_WS && ./build.sh'"
    echo "alias cr='cd \$CAMERA_AI_TRAFFIC_WS && ./run.sh'"
    echo "alias cc='cd \$CAMERA_AI_TRAFFIC_WS && ./clean.sh'"
    exit 0
fi

# Check if already configured
if grep -q "CAMERA_AI_TRAFFIC_WS" "$SHELL_RC"; then
    print_info "Environment already configured in $SHELL_RC"
    exit 0
fi

# Add to shell config
print_info "Adding aliases to $SHELL_RC..."

cat >> "$SHELL_RC" << 'EOF'

# ROS2 Camera AI Traffic Setup
export CAMERA_AI_TRAFFIC_WS="__WORKSPACE_DIR__"

# Load ROS2 base
if [ -f /opt/ros/humble/setup.bash ]; then
    source /opt/ros/humble/setup.bash
elif [ -f /opt/ros/foxy/setup.bash ]; then
    source /opt/ros/foxy/setup.bash
fi

# Load workspace
if [ -f $CAMERA_AI_TRAFFIC_WS/install/setup.bash ]; then
    source $CAMERA_AI_TRAFFIC_WS/install/setup.bash
fi

# Convenient aliases
alias cb='cd $CAMERA_AI_TRAFFIC_WS && ./build.sh'       # Build
alias cr='cd $CAMERA_AI_TRAFFIC_WS && ./run.sh'         # Run
alias cc='cd $CAMERA_AI_TRAFFIC_WS && ./clean.sh'       # Clean
alias ccd='cd $CAMERA_AI_TRAFFIC_WS'                    # Change to workspace
alias cbr='./build.sh && ./run.sh system'               # Build and run system

# Auto-complete for ros2 commands (if installed)
if command -v colcon_cd &> /dev/null; then
    eval "$(colcon_cd)"
fi
EOF

# Replace placeholder
sed -i "s|__WORKSPACE_DIR__|$WORKSPACE_DIR|g" "$SHELL_RC"

print_success "Environment configured!"
print_info "Please reload your shell configuration:"
echo ""
echo "  source $SHELL_RC"
echo ""
print_info "Or open a new terminal window"
echo ""
print_info "Available aliases:"
echo "  cb       - Build workspace"
echo "  cr       - Run nodes/launches"
echo "  cc       - Clean artifacts"
echo "  ccd      - Change to workspace directory"
echo "  cbr      - Build and run system"