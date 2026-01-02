#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function with colors
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ✓ $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ⚠ $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ✗ $1"
}

# Check internet connectivity
check_connectivity() {
    log "Checking internet connectivity..."
    
    # Try multiple hosts to be more reliable
    local hosts=("8.8.8.8" "1.1.1.1" "google.com")
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 5 "$host" &> /dev/null; then
            log_success "Internet connectivity confirmed"
            return 0
        fi
    done
    
    log_error "No internet connection available"
    echo "Please check your network connection and try again."
    exit 1
}

# Main update function
main() {
    log "Starting Ubuntu system update script..."
    
    # Check connectivity first
    check_connectivity
    
    # Update package lists
    log "Updating package lists..."
    if sudo apt update; then
        log_success "Package lists updated"
    else
        log_error "Failed to update package lists"
        exit 1
    fi
    
    # Upgrade packages
    log "Upgrading installed packages..."
    if sudo apt upgrade -y; then
        log_success "Packages upgraded"
    else
        log_error "Failed to upgrade packages"
        exit 1
    fi
    
    # Distribution upgrade
    log "Performing distribution upgrade..."
    if sudo apt dist-upgrade -y; then
        log_success "Distribution upgrade completed"
    else
        log_error "Failed to perform distribution upgrade"
        exit 1
    fi
    
    # Clean up
    log "Cleaning up unnecessary packages..."
    if sudo apt autoremove -y; then
        log_success "Unnecessary packages removed"
    else
        log_warning "Failed to remove some unnecessary packages"
    fi
    
    log "Cleaning package cache..."
    if sudo apt autoclean; then
        log_success "Package cache cleaned"
    else
        log_warning "Failed to clean package cache"
    fi
    
    # Check for reboot requirement
    if [ -f /var/run/reboot-required ]; then
        log_warning "A reboot is required to complete the updates"
        echo ""
        echo "=== REBOOT REQUIRED ==="
        echo "Some updates require a system reboot to take effect."
        echo "Please reboot your system when convenient."
        echo "======================="
    else
        log_success "No reboot required"
    fi
    
    log_success "System update completed successfully!"
    echo ""
    echo "Summary of actions performed:"
    echo "• Updated package lists"
    echo "• Upgraded installed packages"
    echo "• Performed distribution upgrade"
    echo "• Removed unnecessary packages"
    echo "• Cleaned package cache"
}

# Run main function
main
