#!/bin/bash

echo "🚀 Installing Minimal Neovim Configuration"
echo "=========================================="
echo

# Check if nvim is installed
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed. Please install it first."
    exit 1
fi

# Backup existing config
if [ -d "$HOME/.config/nvim" ]; then
    echo "📦 Backing up existing Neovim configuration..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$timestamp"
    echo "   Backup saved to: ~/.config/nvim.backup.$timestamp"
fi

# Backup data directories
if [ -d "$HOME/.local/share/nvim" ]; then
    echo "📦 Backing up Neovim data..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup.$timestamp"
fi

if [ -d "$HOME/.local/state/nvim" ]; then
    mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.backup.$timestamp"
fi

if [ -d "$HOME/.cache/nvim" ]; then
    mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.backup.$timestamp"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create symlink
echo "🔗 Creating symlink..."
ln -s "$SCRIPT_DIR" "$HOME/.config/nvim"

echo
echo "✅ Installation complete!"
echo
echo "Next steps:"
echo "  1. Launch Neovim: nvim"
echo "  2. Lazy.nvim will auto-install plugins"
echo "  3. LSP servers will be installed via Mason"
echo
echo "To restore your old config:"
echo "  rm ~/.config/nvim"
echo "  mv ~/.config/nvim.backup.$timestamp ~/.config/nvim"
echo
