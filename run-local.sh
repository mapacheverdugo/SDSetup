#!/bin/bash

# SDSetup Local Development Script for Podman
# This script helps you run SDSetup locally using Podman

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed. Please install it first:"
        echo "  Fedora/RHEL/CentOS: sudo dnf install podman podman-compose"
        echo "  Ubuntu/Debian: sudo apt-get install podman podman-compose"
        echo "  macOS: brew install podman"
        exit 1
    fi
    print_success "Podman is installed"
}

# Check if podman-compose is installed
check_podman_compose() {
    if ! command -v podman-compose &> /dev/null; then
        print_error "podman-compose is not installed. Please install it first:"
        echo "  Fedora/RHEL/CentOS: sudo dnf install podman-compose"
        echo "  Ubuntu/Debian: sudo apt-get install podman-compose"
        echo "  Or install via pip: pip install podman-compose"
        exit 1
    fi
    print_success "podman-compose is installed"
}

# Check if required files exist
check_files() {
    local required_files=("docker-compose.yml" "Dockerfile.backend" "Dockerfile.blazor" "nginx.conf")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            exit 1
        fi
    done
    print_success "All required files found"
}

# Check if ports are available
check_ports() {
    local ports=(80 5000)
    
    for port in "${ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            print_warning "Port $port is already in use"
            echo "  You may need to stop other services or change ports in docker-compose.yml"
        fi
    done
}

# Start the application
start_app() {
    print_status "Starting SDSetup with Podman..."
    
    # Build and start services
    podman-compose up --build -d
    
    print_success "SDSetup is starting up!"
    echo ""
    echo "Access the application:"
    echo "  Frontend: http://localhost"
    echo "  Backend API: http://localhost:5000"
    echo ""
    echo "To view logs: podman-compose logs -f"
    echo "To stop: podman-compose down"
}

# Stop the application
stop_app() {
    print_status "Stopping SDSetup..."
    podman-compose down
    print_success "SDSetup stopped"
}

# Show logs
show_logs() {
    print_status "Showing logs (Ctrl+C to exit)..."
    podman-compose logs -f
}

# Clean up everything
cleanup() {
    print_status "Cleaning up SDSetup..."
    podman-compose down -v
    podman system prune -a -f
    print_success "Cleanup completed"
}

# Show status
show_status() {
    print_status "SDSetup status:"
    podman-compose ps
}

# Main script logic
main() {
    case "${1:-start}" in
        "start")
            check_podman
            check_podman_compose
            check_files
            check_ports
            start_app
            ;;
        "stop")
            stop_app
            ;;
        "restart")
            stop_app
            sleep 2
            start_app
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|"-h"|"--help")
            echo "SDSetup Local Development Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  start     Start SDSetup (default)"
            echo "  stop      Stop SDSetup"
            echo "  restart   Restart SDSetup"
            echo "  logs      Show logs"
            echo "  status    Show status"
            echo "  cleanup   Stop and clean up everything"
            echo "  help      Show this help"
            echo ""
            echo "Examples:"
            echo "  $0              # Start SDSetup"
            echo "  $0 start        # Start SDSetup"
            echo "  $0 logs         # Show logs"
            echo "  $0 stop         # Stop SDSetup"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 