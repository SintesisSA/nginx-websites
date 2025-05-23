#!/bin/bash

# nginx-reload.sh - Script para validar y recargar configuración de nginx en Docker

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Default values
CONTAINER_NAME="nginx-server"

# Functions
success() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}" >&2
}

usage() {
    cat << EOF
Nginx Docker Reload Script

Usage: $0 [OPTIONS]

OPTIONS:
    -c, --container CONTAINER    Container name (default: nginx)
    -h, --help                  Show this help message

EXAMPLES:
    $0                          # Reload default 'nginx' container
    $0 -c my-nginx             # Reload 'my-nginx' container
    $0 --container web-server   # Reload 'web-server' container

EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running or you don't have permissions"
        exit 1
    fi
}

check_container() {
    local container=$1
    
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
        error "Container '${container}' is not running"
        echo "Available running containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" | head -10
        exit 1
    fi
}

validate_nginx() {
    local container=$1
    
    echo "Validating nginx configuration..."
    
    if docker exec "${container}" nginx -t > /dev/null 2>&1; then
        success "Configuration is valid"
        return 0
    else
        error "Configuration validation failed"
        docker exec "${container}" nginx -t
        return 1
    fi
}

reload_nginx() {
    local container=$1
    
    echo "Reloading nginx..."
    
    if docker exec "${container}" nginx -s reload > /dev/null 2>&1; then
        success "Nginx reloaded successfully"
        return 0
    else
        error "Failed to reload nginx"
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    check_docker
    check_container "${CONTAINER_NAME}"
    
    # Validate configuration
    if validate_nginx "${CONTAINER_NAME}"; then
        # Configuration is valid, proceed with reload
        if reload_nginx "${CONTAINER_NAME}"; then
            success "Nginx configuration validated and reloaded successfully"
        else
            error "Failed to reload nginx"
            exit 1
        fi
    else
        error "Configuration validation failed. Reload aborted"
        exit 1
    fi
}

# Execute main function
main
