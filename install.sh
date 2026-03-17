#!/bin/bash

set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Update system
read -p "Update System? (y/N)" -n 1 -r answer

if [[ $answer =~ ^[Yy]$ ]]; then

	print_message "Updating system..."
	sudo dnf update -y
fi

# Install All Tools
print_message "Installing essential tools..."

sudo dnf install -y \
    git \
    gnupg \
    zsh \
    zoxide \
    neovim \
    fastfetch \
    cargo \
    nix \
    jetbrains-mono-nl-fonts.noarch \
    eza \
    xz # compression tool
