#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update system packages
print_message "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install basic dependencies
print_message "Installing basic dependencies..."
sudo apt install -y curl wget git unzip build-essential software-properties-common apt-transport-https ca-certificates gnupg

# Install required PHP extensions and tools
print_message "Installing PHP dependencies..."
sudo apt install -y \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsqlite3-dev \
    libzip-dev \
    libonig-dev

# Add PHP repository
print_message "Adding PHP repository..."
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Install multiple PHP versions (7.4, 8.0, 8.1, 8.2, 8.3)
php_versions=("7.4" "8.0" "8.1" "8.2" "8.3")

for version in "${php_versions[@]}"; do
    print_message "Installing PHP $version and extensions..."
    sudo apt install -y php$version \
        php$version-cli \
        php$version-common \
        php$version-curl \
        php$version-mbstring \
        php$version-mysql \
        php$version-xml \
        php$version-zip \
        php$version-bcmath \
        php$version-fpm \
        php$version-sqlite3 \
        php$version-intl \
        php$version-gd
done

# Install PHP 8.4
print_message "Installing PHP 8.4..."
/bin/bash -c "$(curl -fsSL https://php.new/install/linux/8.4)"

# Install Composer
if ! command_exists composer; then
    print_message "Installing Composer..."
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
else
    print_message "Composer is already installed"
fi

# Add Composer global bin to PATH
if ! grep -q "export PATH=\"\$PATH:\$HOME/.config/composer/vendor/bin\"" ~/.bashrc; then
    print_message "Adding Composer global bin to PATH..."
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
fi

if ! grep -q "export PATH=\"\$PATH:\$HOME/.composer/vendor/bin\"" ~/.bashrc; then
    print_message "Adding alternative Composer global bin to PATH..."
    echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
fi

# Ensure PATH is updated in current session
export PATH="$PATH:$HOME/.config/composer/vendor/bin:$HOME/.composer/vendor/bin"

# Install Valet Linux Plus dependencies
print_message "Installing Valet Linux Plus dependencies..."
sudo apt install -y network-manager libnss3-tools jq xsel

# Install Valet Linux Plus
if ! command_exists valet; then
    print_message "Installing Valet Linux Plus..."
    composer global require genesisweb/valet-linux-plus
    if [[ $? -ne 0 ]]; then
        print_error "Valet installation failed! Please check the output for errors."
        exit 1
    fi

    # Update PATH for current session
    export PATH="$PATH:$HOME/.config/composer/vendor/bin"
    source ~/.bashrc
    
    # Initialize Valet
    valet install
    if [[ $? -ne 0 ]]; then
        print_error "Valet initialization failed! Please check the output for errors."
        exit 1
    fi
else
    print_message "Valet Linux Plus is already installed"
fi

# Install NVM
if ! command_exists nvm; then
    print_message "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.bashrc
    if [[ $? -ne 0 ]]; then
        print_error "NVM installation failed! Please check the output for errors."
        exit 1
    fi
else
    print_message "NVM is already installed"
fi

# Install Node.js
if ! command_exists node; then
    print_message "Installing Node.js..."
    nvm install node
    if [[ $? -ne 0 ]]; then
        print_error "Node.js installation failed! Please check the output for errors."
        exit 1
    fi
else
    print_message "Node.js is already installed"
fi

# Print final instructions
print_message "
==============================================
Important: To complete the setup, Please restart your terminal or run:
'source ~/.bashrc' to apply all changes.

You can then use the following commands:
- 'valet' for Valet Linux Plus
- 'laravel new project-name' for creating new Laravel projects
=============================================="
