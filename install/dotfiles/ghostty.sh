#!/bin/bash

echo "🚀 Installing/Updating Ghostty Terminal Configuration"
echo "===================================================="
echo

# Check if ghostty is installed
if ! command -v ghostty &> /dev/null; then
    echo "❌ Ghostty is not installed. Please install it first:"
    echo "   Download from: https://ghostty.org/"
    echo "   Or via Homebrew: brew install --cask ghostty"
    exit 1
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GHOSTTY_DIR="$DOTFILES_DIR/ghostty"

# Check if ghostty directory exists
if [ ! -d "$GHOSTTY_DIR" ]; then
    echo "❌ ghostty directory not found at: $GHOSTTY_DIR"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config/ghostty"

# Check if config is already properly linked
if [ -L "$HOME/.config/ghostty/config" ]; then
    CURRENT_LINK=$(readlink "$HOME/.config/ghostty/config")
    if [ "$CURRENT_LINK" = "$GHOSTTY_DIR/config" ]; then
        echo "✅ Ghostty configuration is already properly linked!"
        echo "   ~/.config/ghostty/config -> $GHOSTTY_DIR/config"
        echo ""
        echo "🎯 Next steps:"
        echo "   1. Launch Ghostty terminal"
        echo "   2. Configuration will be loaded automatically"
        echo ""
        echo "✨ Configuration is up to date!"
        exit 0
    else
        echo "🔗 Updating Ghostty symlink..."
        rm "$HOME/.config/ghostty/config"
    fi
elif [ -f "$HOME/.config/ghostty/config" ]; then
    echo "📁 Found existing Ghostty config (not symlinked), creating symlink..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/config.backup.$timestamp"
    echo "   📦 Backup saved to: ~/.config/ghostty/config.backup.$timestamp"
fi

# Create symlink for config
echo "🔗 Creating symlink to ghostty config..."
ln -s "$GHOSTTY_DIR/config" "$HOME/.config/ghostty/config"

if [ $? -eq 0 ]; then
    echo "   ✅ Config symlink created: ~/.config/ghostty/config -> $GHOSTTY_DIR/config"
else
    echo "   ❌ Failed to create config symlink"
    exit 1
fi

# Link theme if it exists
if [ -f "$GHOSTTY_DIR/theme.conf" ]; then
    if [ -f "$HOME/.config/ghostty/theme.conf" ] && [ ! -L "$HOME/.config/ghostty/theme.conf" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.config/ghostty/theme.conf" "$HOME/.config/ghostty/theme.conf.backup.$timestamp"
    elif [ -L "$HOME/.config/ghostty/theme.conf" ]; then
        rm "$HOME/.config/ghostty/theme.conf"
    fi
    
    ln -s "$GHOSTTY_DIR/theme.conf" "$HOME/.config/ghostty/theme.conf"
    echo "   ✅ Theme symlink created: ~/.config/ghostty/theme.conf -> $GHOSTTY_DIR/theme.conf"
fi

# Link shaders directory if it exists
if [ -d "$GHOSTTY_DIR/shaders" ]; then
    if [ -d "$HOME/.config/ghostty/shaders" ] && [ ! -L "$HOME/.config/ghostty/shaders" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.config/ghostty/shaders" "$HOME/.config/ghostty/shaders.backup.$timestamp"
    elif [ -L "$HOME/.config/ghostty/shaders" ]; then
        rm "$HOME/.config/ghostty/shaders"
    fi
    
    ln -s "$GHOSTTY_DIR/shaders" "$HOME/.config/ghostty/shaders"
    echo "   ✅ Shaders symlink created: ~/.config/ghostty/shaders -> $GHOSTTY_DIR/shaders"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch Ghostty terminal"
echo "   2. Configuration will be loaded automatically"
echo ""
echo "Happy terminal usage! 🎉"