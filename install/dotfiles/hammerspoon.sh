#!/bin/bash

echo "🚀 Installing/Updating Hammerspoon Configuration"
echo "=============================================="
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

# Check if config is already properly linked
if [ -L "$HOME/.hammerspoon" ]; then
    CURRENT_LINK=$(readlink "$HOME/.hammerspoon")
    if [ "$CURRENT_LINK" = "$HAMMERSPOON_DIR" ]; then
        echo "✅ Hammerspoon configuration is already properly linked!"
        echo "   ~/.hammerspoon -> $HAMMERSPOON_DIR"
        echo ""
        echo "🎯 Next steps:"
        echo "   1. Launch Hammerspoon.app"
        echo "   2. Click 'Reload Config' in the Hammerspoon menu"
        echo ""
        echo "✨ Configuration is up to date!"
        exit 0
    else
        echo "🔗 Updating Hammerspoon symlink..."
        rm "$HOME/.hammerspoon"
    fi
elif [ -d "$HOME/.hammerspoon" ]; then
    echo "📁 Found existing Hammerspoon directory (not symlinked), creating symlink..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.hammerspoon" "$HOME/.hammerspoon.backup.$timestamp"
    echo "   📦 Backup saved to: ~/.hammerspoon.backup.$timestamp"
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
echo "🎯 Next steps:"
echo "   1. Launch Hammerspoon.app"
echo "   2. Enable Accessibility permissions when prompted"
echo "   3. Click 'Reload Config' in the Hammerspoon menu"
echo ""
echo "🔧 Hammerspoon Commands:"
echo "   Reload config:  Cmd+Option+Ctrl+R (or menu bar)"
echo "   Open console:   From Hammerspoon menu bar"
echo ""
echo "Happy automating! 🎉"