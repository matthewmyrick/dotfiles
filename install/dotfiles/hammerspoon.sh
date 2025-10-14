#!/bin/bash

echo "🚀 Installing Hammerspoon Configuration"
echo "======================================="
echo

# Check if hammerspoon is installed
if ! test -d "/Applications/Hammerspoon.app"; then
    echo "❌ Hammerspoon is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install --cask hammerspoon
    else
        echo "❌ Homebrew not found. Please install Hammerspoon manually:"
        echo "   Download from: https://www.hammerspoon.org/"
        exit 1
    fi
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HAMMERSPOON_DIR="$DOTFILES_DIR/hammerspoon"

# Check if hammerspoon directory exists
if [ ! -d "$HAMMERSPOON_DIR" ]; then
    echo "❌ hammerspoon directory not found at: $HAMMERSPOON_DIR"
    exit 1
fi

# Backup existing config
if [ -d "$HOME/.hammerspoon" ] || [ -L "$HOME/.hammerspoon" ]; then
    echo "📦 Backing up existing Hammerspoon configuration..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -L "$HOME/.hammerspoon" ]; then
        echo "   Removing existing symlink..."
        rm "$HOME/.hammerspoon"
    else
        mv "$HOME/.hammerspoon" "$HOME/.hammerspoon.backup.$timestamp"
        echo "   ✅ Backup saved to: ~/.hammerspoon.backup.$timestamp"
    fi
fi

# Create symlink
echo "🔗 Creating symlink to hammerspoon config..."
ln -s "$HAMMERSPOON_DIR" "$HOME/.hammerspoon"

if [ $? -eq 0 ]; then
    echo "   ✅ Symlink created: ~/.hammerspoon -> $HAMMERSPOON_DIR"
else
    echo "   ❌ Failed to create symlink"
    exit 1
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Configuration details:"
echo "   Location: $HAMMERSPOON_DIR"
echo "   Config:   ~/.hammerspoon"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch Hammerspoon.app"
echo "   2. Enable Accessibility permissions when prompted"
echo "   3. Click 'Reload Config' in the Hammerspoon menu"
echo "   4. Configuration will be loaded automatically"
echo ""
echo "🔧 Hammerspoon Commands:"
echo "   Reload config:  Cmd+Option+Ctrl+R (or menu bar)"
echo "   Open console:   From Hammerspoon menu bar"
echo ""
echo "🔄 To restore old config (if backed up):"
echo "   rm ~/.hammerspoon"
echo "   mv ~/.hammerspoon.backup.* ~/.hammerspoon"
echo ""
echo "Happy automating! 🎉"