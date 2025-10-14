#!/bin/bash

echo "🚀 Installing Minimal Neovim Configuration (nvim-new)"
echo "======================================================="
echo

# Check if nvim is installed
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed. Please install it first:"
    echo "   brew install neovim"
    exit 1
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NVIM_NEW_DIR="$DOTFILES_DIR/nvim-new"

# Check if nvim-new exists
if [ ! -d "$NVIM_NEW_DIR" ]; then
    echo "❌ nvim-new directory not found at: $NVIM_NEW_DIR"
    exit 1
fi

# Backup existing config
if [ -d "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
    echo "📦 Backing up existing Neovim configuration..."
    timestamp=$(date +%Y%m%d_%H%M%S)

    # Remove symlink if it exists
    if [ -L "$HOME/.config/nvim" ]; then
        echo "   Removing existing symlink..."
        rm "$HOME/.config/nvim"
    else
        # Move directory
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$timestamp"
        echo "   ✅ Backup saved to: ~/.config/nvim.backup.$timestamp"
    fi
fi

# Backup data directories (optional, comment out if you want to keep them)
echo ""
read -p "🗑️  Clean Neovim data directories? (removes plugins, cache, state) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Backing up Neovim data directories..."
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [ -d "$HOME/.local/share/nvim" ]; then
        mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup.$timestamp"
        echo "   ✅ Data backup saved"
    fi

    if [ -d "$HOME/.local/state/nvim" ]; then
        mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.backup.$timestamp"
        echo "   ✅ State backup saved"
    fi

    if [ -d "$HOME/.cache/nvim" ]; then
        mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.backup.$timestamp"
        echo "   ✅ Cache backup saved"
    fi
else
    echo "⏭️  Skipping data cleanup (keeping existing plugins/cache)"
fi

# Create symlink
echo ""
echo "🔗 Creating symlink to nvim-new..."
ln -s "$NVIM_NEW_DIR" "$HOME/.config/nvim"

if [ $? -eq 0 ]; then
    echo "   ✅ Symlink created: ~/.config/nvim -> $NVIM_NEW_DIR"
else
    echo "   ❌ Failed to create symlink"
    exit 1
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Configuration details:"
echo "   Location: $NVIM_NEW_DIR"
echo "   Symlink:  ~/.config/nvim"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch Neovim:    nvim"
echo "   2. Plugins will auto-install via Lazy.nvim"
echo "   3. LSP servers will install via Mason"
echo ""
echo "📚 Documentation:"
echo "   README:     $NVIM_NEW_DIR/README.md"
echo "   Comparison: $NVIM_NEW_DIR/COMPARISON.md"
echo ""
echo "🔄 To restore old config (if backed up):"
echo "   rm ~/.config/nvim"
echo "   mv ~/.config/nvim.backup.$timestamp ~/.config/nvim"
echo ""
echo "Happy coding! 🎉"
