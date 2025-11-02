#!/bin/bash
# run.sh - Run ROS2 nodes and launch files
# Usage: ./run.sh [node_name|launch_file] [args]

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

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_help() {
    echo "Usage: ./run.sh [target] [arguments]"
    echo ""
    echo "Targets (nodes):"
    echo "  main_node                  # Run main orchestrator node"
    echo "  camera                     # Run camera interface node"
    echo "  detector                   # Run AI detection node"
    echo "  tracker                    # Run object tracking node"
    echo "  controller                 # Run traffic controller node"
    echo "  uart                       # Run UART communication node"
    echo "  viz                        # Run visualization node"
    echo ""
    echo "Targets (launch files):"
    echo "  system                     # Launch entire system (main_system.launch)"
    echo "  camera_pipeline            # Launch camera + AI pipeline"
    echo "  communication              # Launch UART + Network communication"
    echo "  debug                      # Launch system with debug enabled"
    echo ""
    echo "Examples:"
    echo "  ./run.sh main_node"
    echo "  ./run.sh system"
    echo "  ./run.sh camera"
    echo ""
}

# Check arguments
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [[ -z "$1" ]]; then
    show_help
    exit 0
fi

# Source workspace
if [ ! -f "install/setup.bash" ]; then
    print_error "install/setup.bash not found! Please build workspace first with ./build.sh"
    exit 1
fi

source install/setup.bash

print_header "ROS2 Camera AI Traffic - Run"
print_info "Target: $1"

# Define node and launch mappings
case "$1" in
    main_node)
        print_info "Launching Main Orchestrator Node..."
        ros2 run MainProcess main_node_exe ${@:2}
        ;;
    camera)
        print_info "Launching Camera Interface Node..."
        ros2 run camera_interface camera_node_exe ${@:2}
        ;;
    detector)
        print_info "Launching AI Detection Node..."
        ros2 run ai_detection detector_exe ${@:2}
        ;;
    tracker)
        print_info "Launching Vehicle Tracking Node..."
        ros2 run ai_detection tracker_exe ${@:2}
        ;;
    controller)
        print_info "Launching Traffic Controller Node..."
        ros2 run traffic_controller controller_exe ${@:2}
        ;;
    uart)
        print_info "Launching UART Communication Node..."
        ros2 run uart_communication uart_node_exe ${@:2}
        ;;
    viz)
        print_info "Launching Visualization Node..."
        ros2 run visualization viz_node_exe ${@:2}
        ;;
    system)
        print_info "Launching entire system..."
        ros2 launch MainProcess main_system.launch.xml ${@:2}
        ;;
    camera_pipeline)
        print_info "Launching camera pipeline..."
        ros2 launch MainProcess camera_pipeline.launch.xml ${@:2}
        ;;
    communication)
        print_info "Launching communication nodes..."
        ros2 launch MainProcess communication.launch.xml ${@:2}
        ;;
    debug)
        print_info "Launching system in debug mode..."
        ros2 launch MainProcess debug.launch.xml ${@:2}
        ;;
    *)
        print_error "Unknown target: $1"
        echo "Use './run.sh -h' to see available targets"
        exit 1
        ;;
esac