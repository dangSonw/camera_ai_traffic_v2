#!/bin/bash
# clean.sh - Clean build artifacts
# Usage: ./clean.sh [all|build|install|log]

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

show_help() {
    echo "Usage: ./clean.sh [target]"
    echo ""
    echo "Targets:"
    echo "  all             Clean all build artifacts (default)"
    echo "  build           Clean only build/ directory"
    echo "  install         Clean only install/ directory"
    echo "  log             Clean only log/ directory"
    echo "  soft            Soft clean (remove build/install/log but preserve package cache)"
    echo ""
    echo "Examples:"
    echo "  ./clean.sh all"
    echo "  ./clean.sh build"
    echo ""
}

print_header "ROS2 Camera AI Traffic - Clean"

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

CLEAN_TARGET="${1:all}"

# Confirm before deleting
if [ "$CLEAN_TARGET" != "log" ]; then
    echo ""
    print_info "This will delete build artifacts."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled."
        exit 0
    fi
fi

case "$CLEAN_TARGET" in
    all)
        print_info "Removing all build artifacts..."
        rm -rf build/
        print_success "Removed build/"
        rm -rf install/
        print_success "Removed install/"
        rm -rf log/
        print_success "Removed log/"
        ;;
    build)
        print_info "Removing build/ directory..."
        rm -rf build/
        print_success "Removed build/"
        ;;
    install)
        print_info "Removing install/ directory..."
        rm -rf install/
        print_success "Removed install/"
        ;;
    log)
        print_info "Removing log/ directory..."
        rm -rf log/
        print_success "Removed log/"
        ;;
    soft)
        print_info "Soft clean - removing build artifacts but preserving package cache..."
        find build/ -name CMakeCache.txt -delete 2>/dev/null || true
        find build/ -name "*.o" -delete 2>/dev/null || true
        rm -rf build/*/CMakeFiles 2>/dev/null || true
        print_success "Soft clean completed!"
        ;;
    *)
        print_error "Unknown target: $CLEAN_TARGET"
        echo "Use './clean.sh -h' to see available targets"
        exit 1
        ;;
esac

print_success "Clean completed!"
print_info "You can now build again with './build.sh'"