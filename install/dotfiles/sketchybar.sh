#!/bin/bash

echo "🚀 Installing/Updating SketchyBar Configuration"
echo "=============================================="
echo

# Check if sketchybar is installed
if ! command -v sketchybar &> /dev/null; then
    echo "❌ SketchyBar is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install felixkratz/formulae/sketchybar
    else
        echo "❌ Homebrew not found. Please install Homebrew first."
        exit 1
    fi
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKETCHYBAR_DIR="$DOTFILES_DIR/sketchybar"

# Check if sketchybar directory exists
if [ ! -d "$SKETCHYBAR_DIR" ]; then
    echo "❌ sketchybar directory not found at: $SKETCHYBAR_DIR"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config/sketchybar"

# Check if config is already properly linked
if [ -L "$HOME/.config/sketchybar/sketchybarrc" ]; then
    CURRENT_LINK=$(readlink "$HOME/.config/sketchybar/sketchybarrc")
    if [ "$CURRENT_LINK" = "$SKETCHYBAR_DIR/sketchybarrc" ]; then
        echo "✅ SketchyBar configuration is already properly linked!"
        echo "   ~/.config/sketchybar/sketchybarrc -> $SKETCHYBAR_DIR/sketchybarrc"
        echo ""
        echo "🎯 Next steps:"
        echo "   1. Restart SketchyBar: brew services restart felixkratz/formulae/sketchybar"
        echo ""
        echo "✨ Configuration is up to date!"
        exit 0
    else
        echo "🔗 Updating SketchyBar symlink..."
        rm "$HOME/.config/sketchybar/sketchybarrc"
    fi
elif [ -f "$HOME/.config/sketchybar/sketchybarrc" ]; then
    echo "📁 Found existing SketchyBar config (not symlinked), creating symlink..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.config/sketchybar/sketchybarrc" "$HOME/.config/sketchybar/sketchybarrc.backup.$timestamp"
    echo "   📦 Backup saved to: ~/.config/sketchybar/sketchybarrc.backup.$timestamp"
fi

# Create symlink
echo "🔗 Creating symlink to sketchybar config..."
ln -s "$SKETCHYBAR_DIR/sketchybarrc" "$HOME/.config/sketchybar/sketchybarrc"

if [ $? -eq 0 ]; then
    echo "   ✅ Symlink created: ~/.config/sketchybar/sketchybarrc -> $SKETCHYBAR_DIR/sketchybarrc"
else
    echo "   ❌ Failed to create symlink"
    exit 1
fi

# Make sketchybarrc executable
chmod +x "$HOME/.config/sketchybar/sketchybarrc"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Start SketchyBar:     brew services start felixkratz/formulae/sketchybar"
echo "   2. Restart SketchyBar:   brew services restart felixkratz/formulae/sketchybar"
echo ""
echo "Happy customizing! 🎉"