#!/bin/bash

# Overleaf Deployment Script
# This script automates the deployment of Overleaf Community Edition

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Creating from example..."
        if [ -f "env.example" ]; then
            cp env.example .env
            print_warning "Please edit .env file with your configuration before continuing."
            exit 1
        else
            print_error "env.example file not found. Cannot create .env file."
            exit 1
        fi
    fi
    
    print_success "Prerequisites check passed!"
}

# Build TeX Live image
build_texlive() {
    print_status "Building TeX Live image..."
    if [ -d "develop/texlive" ]; then
        docker build develop/texlive -t texlive-full
        print_success "TeX Live image built successfully!"
    else
        print_warning "TeX Live directory not found. Skipping TeX Live build."
    fi
}

# Start services
start_services() {
    print_status "Starting Overleaf services..."
    
    # Pull latest images
    docker-compose -f docker-compose.production.yml pull
    
    # Start services
    docker-compose -f docker-compose.production.yml up -d
    
    print_success "Services started successfully!"
}

# Wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to be healthy..."
    
    # Wait for MongoDB
    print_status "Waiting for MongoDB..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker-compose -f docker-compose.production.yml exec -T mongo mongosh --eval "db.stats()" >/dev/null 2>&1; then
            print_success "MongoDB is ready!"
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -eq 0 ]; then
        print_error "MongoDB failed to start within 60 seconds"
        exit 1
    fi
    
    # Wait for Overleaf
    print_status "Waiting for Overleaf..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost/status >/dev/null 2>&1; then
            print_success "Overleaf is ready!"
            break
        fi
        sleep 10
        timeout=$((timeout - 10))
    done
    
    if [ $timeout -eq 0 ]; then
        print_error "Overleaf failed to start within 120 seconds"
        exit 1
    fi
}

# Show status
show_status() {
    print_status "Current service status:"
    docker-compose -f docker-compose.production.yml ps
    
    echo ""
    print_success "Deployment completed successfully!"
    print_status "You can access Overleaf at:"
    
    if [ -f ".env" ]; then
        DOMAIN=$(grep DOMAIN .env | cut -d '=' -f2)
        if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "your-domain.com" ]; then
            echo "  https://$DOMAIN"
        fi
    fi
    
    echo "  http://localhost (if running locally)"
    echo ""
    print_status "To create the first admin user, visit:"
    echo "  http://localhost/launchpad"
}

# Main deployment function
main() {
    echo "================================="
    echo "Overleaf Deployment Script"
    echo "================================="
    echo ""
    
    check_prerequisites
    build_texlive
    start_services
    wait_for_services
    show_status
}

# Handle script arguments
case "${1:-}" in
    "start")
        start_services
        ;;
    "stop")
        print_status "Stopping services..."
        docker-compose -f docker-compose.production.yml down
        print_success "Services stopped!"
        ;;
    "restart")
        print_status "Restarting services..."
        docker-compose -f docker-compose.production.yml restart
        print_success "Services restarted!"
        ;;
    "status")
        show_status
        ;;
    "logs")
        docker-compose -f docker-compose.production.yml logs -f
        ;;
    "update")
        print_status "Updating services..."
        docker-compose -f docker-compose.production.yml pull
        docker-compose -f docker-compose.production.yml up -d
        print_success "Services updated!"
        ;;
    *)
        main
        ;;
esac
