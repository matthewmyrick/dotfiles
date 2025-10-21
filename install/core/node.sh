#!/bin/bash

echo "📦 Installing Node.js and npm via Homebrew..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install Node.js (includes npm)
echo "  📦 Installing node..."
brew install node

# Verify installation
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    echo "  ✅ Node.js installed successfully: $NODE_VERSION"
    echo "  ✅ npm installed successfully: $NPM_VERSION"
    echo "  📍 Node location: $(which node)"
    echo "  📍 npm location: $(which npm)"
    
    # Install nvm for version management
    echo "  📦 Installing nvm for Node version management..."
    brew install nvm
    
    # Create nvm directory
    mkdir -p ~/.nvm
    
    echo "  📝 Note: Add the following to your shell profile:"
    echo "    export NVM_DIR=\"$HOME/.nvm\""
    echo "    [ -s \"/opt/homebrew/bin/nvm\" ] && \\. \"/opt/homebrew/bin/nvm\""
    echo "    [ -s \"/opt/homebrew/etc/bash_completion.d/nvm\" ] && \\. \"/opt/homebrew/etc/bash_completion.d/nvm\""
else
    echo "  ❌ Node.js/npm installation verification failed"
    exit 1
fi

echo "✓ Node.js and npm installation completed!"