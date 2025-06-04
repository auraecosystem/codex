#!/bin/bash
# 

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js version
check_node_version() {
    if command_exists node; then
        local current_version=$(node --version | sed 's/v//' | cut -d. -f1)
        if [ "$current_version" -eq "$1" ]; then
            return 0
        fi
    fi
    return 1
}

# Main installation
export NODE_MAJOR=23

# Check if Node.js v23 is already installed
if check_node_version $NODE_MAJOR; then
    print_success "Node.js v$NODE_MAJOR is already installed ($(node --version))"
else
    print_status "Installing Node.js v$NODE_MAJOR..."
    
    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings
    
    # Download and add NodeSource GPG key (overwrite if exists)
    print_status "Adding NodeSource GPG key..."
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    
    # Add NodeSource repository (overwrite if exists)
    print_status "Adding NodeSource repository..."
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    
    # Update and install Node.js
    print_status "Updating package list and installing Node.js..."
    sudo apt-get update -qq
    sudo apt-get install -y nodejs
    
    # Clean up apt cache
    sudo apt-get clean
    sudo apt-get autoremove -y
    sudo apt-get purge -y --auto-remove
    
    print_success "Node.js installed successfully"
fi

# Display versions
print_status "Node version: $(node --version)"
print_status "npm version: $(npm --version)"

# Check and install Yarn
if command_exists yarn; then
    print_success "Yarn is already installed ($(yarn --version))"
else
    print_status "Installing Yarn globally..."
    sudo npm install --global yarn
    print_success "Yarn installed successfully"
fi

# Configure npm global packages for user
print_status "Configuring npm for user-level global packages..."
mkdir -p ~/.npm-global

# Check if npm prefix is already set correctly
current_prefix=$(npm config get prefix 2>/dev/null || echo "")
expected_prefix="$HOME/.npm-global"

if [ "$current_prefix" != "$expected_prefix" ]; then
    npm config set prefix ~/.npm-global
    print_success "npm prefix configured"
else
    print_success "npm prefix already configured correctly"
fi

# Add to PATH if not already there
if ! grep -q 'export PATH=~/.npm-global/bin:$PATH' ~/.bashrc; then
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    print_success "PATH updated in ~/.bashrc"
else
    print_success "PATH already configured in ~/.bashrc"
fi

# Export for current session
export PATH=~/.npm-global/bin:$PATH

# Check and install claude-code
if command_exists claude-code; then
    print_success "claude-code is already installed at: $(which claude-code)"
    
    # Optionally check for updates
    print_status "Checking for claude-code updates..."
    npm update -g @anthropic-ai/claude-code 2>/dev/null || true
else
    print_status "Installing claude-code..."
    npm install -g @anthropic-ai/claude-code
    print_success "claude-code installed at: $(which claude-code)"
fi

echo ""
print_success "Installation complete!"

# Check if we need to source bashrc
if [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
    print_warning "You may need to restart your shell or run 'source ~/.bashrc' to use claude-code"
else
    print_success "Everything is ready to use!"
fi