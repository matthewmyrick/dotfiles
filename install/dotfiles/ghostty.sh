#!/bin/bash

echo "🚀 Installing Ghostty Terminal Configuration"
echo "============================================"
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

# Backup existing config
if [ -f "$HOME/.config/ghostty/config" ] || [ -L "$HOME/.config/ghostty/config" ]; then
    echo "📦 Backing up existing Ghostty configuration..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -L "$HOME/.config/ghostty/config" ]; then
        echo "   Removing existing symlink..."
        rm "$HOME/.config/ghostty/config"
    else
        mv "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/config.backup.$timestamp"
        echo "   ✅ Backup saved to: ~/.config/ghostty/config.backup.$timestamp"
    fi
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
    if [ -f "$HOME/.config/ghostty/theme.conf" ] || [ -L "$HOME/.config/ghostty/theme.conf" ]; then
        if [ -L "$HOME/.config/ghostty/theme.conf" ]; then
            rm "$HOME/.config/ghostty/theme.conf"
        else
            mv "$HOME/.config/ghostty/theme.conf" "$HOME/.config/ghostty/theme.conf.backup.$timestamp"
        fi
    fi
    
    ln -s "$GHOSTTY_DIR/theme.conf" "$HOME/.config/ghostty/theme.conf"
    echo "   ✅ Theme symlink created: ~/.config/ghostty/theme.conf -> $GHOSTTY_DIR/theme.conf"
fi

# Link shaders directory if it exists
if [ -d "$GHOSTTY_DIR/shaders" ]; then
    if [ -d "$HOME/.config/ghostty/shaders" ] || [ -L "$HOME/.config/ghostty/shaders" ]; then
        if [ -L "$HOME/.config/ghostty/shaders" ]; then
            rm "$HOME/.config/ghostty/shaders"
        else
            mv "$HOME/.config/ghostty/shaders" "$HOME/.config/ghostty/shaders.backup.$timestamp"
        fi
    fi
    
    ln -s "$GHOSTTY_DIR/shaders" "$HOME/.config/ghostty/shaders"
    echo "   ✅ Shaders symlink created: ~/.config/ghostty/shaders -> $GHOSTTY_DIR/shaders"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Configuration details:"
echo "   Location: $GHOSTTY_DIR"
echo "   Config:   ~/.config/ghostty/"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch Ghostty terminal"
echo "   2. Configuration will be loaded automatically"
echo "   3. Check the README for customization options"
echo ""
echo "📚 Documentation:"
echo "   README: $GHOSTTY_DIR/README.md"
echo ""
echo "🔄 To restore old config (if backed up):"
echo "   rm ~/.config/ghostty/config"
echo "   mv ~/.config/ghostty/config.backup.* ~/.config/ghostty/config"
echo ""
echo "Happy terminal usage! 🎉"