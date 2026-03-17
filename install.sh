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

echo

if [[ $answer =~ ^[Yy]$ ]]; then

	print_message "Updating system..."
	sudo dnf update -y
fi

# Install All Tools
print_message "Installing essential tools..."

sudo dnf install -y \
    git \
    delta \
    gnupg \
    zsh \
    zoxide \
    neovim \
    fastfetch \
    cargo \
    nix \
    jetbrains-mono-nl-fonts.noarch \
    xz \
    jq

echo

if ! command -v eza &>/dev/null; then
    print_message "Building eza from source..."
    (
    cd /tmp || exit
    git clone https://github.com/eza-community/eza.git
    cd eza
    cargo install --path .
    rm -rf /tmp/eza
    )
else
    print_message "eza already installed"
fi

# Git Prompt
GIT_CONFIG="$HOME/.gitconfig.local"

if ! grep -q "\[user\]" "$GIT_CONFIG"; then

	print_message "Git User config exists at $GIT_CONFIG"

	echo "Setting up your Git identity..."

	echo

	while true; do 
	
	read -p "Enter your full name: " git_name
	read -p "Enter your email address: " git_email
	
	echo
	
	read -p "Are you sure? (Y/n)" confirm

		case $confirm in
			[Nn]*)
				echo
				continue
				;;
			*)
				echo
                		cat >> "$GIT_CONFIG" << EOF
[user]
    name = $git_name
    email = $git_email
EOF
                		echo "Added user config to $GIT_CONFIG"
                		break
            		    	;;
		esac
	done
else
	echo "Git config exists at $GIT_CONFIG"

fi
