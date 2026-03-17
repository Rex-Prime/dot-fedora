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
    git-crypt \
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

# Stow

stow_package() {
    
    	local pkg=$1        # $1 = First Arg
    	local target=$2	    # $2 = Second Arg
    
    	# i.e stow_package [first] [second]

    	local any_exist=false
    	local existing_files+=()

	if [ ! -d "$pkg" ]; then
        	print_error "Package '$pkg' not found!"
        	return 1
		fi

       	# Sets (I)nternal (F)ield (S)eparator to nothing, preserving leading/trailing whitespace
	# while read -r reads each line, file

	while IFS= read -r file; do
        
	# Remove the ./ prefix to get relative path
        relative_path="${file#./}"

	dest="$target/$relative_path"
        
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            any_exist=true
            existing_files+=("$relative_path")
        fi
    	done < <(cd "$pkg" && find . -type f -o -type l 2>/dev/null) # the input's value is stored in 'file' 

    if [ "$any_exist" = true ]; then
        print_warning "$pkg config already exists in $target (${#existing_files[@]} files)"
        
        # Show which files
        # for f in "${existing_files[@]}"; do
        #     echo "  - $f"
        # done
        
        read -p "Overwrite all? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$target"
	    stow --restow --target="$target" "$pkg"
            
	    print_message "$pkg config stowed to $target"
        else
            print_warning "Skipping $pkg config"
        fi
    else
        mkdir -p "$target"
        stow --target="$target" "$pkg"
        print_message "$pkg config stowed to $target"
    fi
}

cd ~/dot-fedora || exit

# Add new config here
stow_package "git" "$HOME"
stow_package "zsh" "$HOME"

# Git Prompt
GIT_CONFIG="$HOME/.gitconfig.local"

if ! grep -q "\[user\]" "$GIT_CONFIG"; then

	print_warning "Git User config doesn't exists at $GIT_CONFIG"

	print_message "Setting up your Git identity..."

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
				: "${GIT_CONFIG}"
        			{	
            			printf "[user]\n"
            			printf "    name = %s\n" "$git_name"
				printf "    email = %s\n" "$git_email"
        			} >> "$GIT_CONFIG"

				print_message "Added user config to $GIT_CONFIG"
                		break
            		    	;;
		esac
	done
else
	print_message "Git config exists at $GIT_CONFIG"

fi
