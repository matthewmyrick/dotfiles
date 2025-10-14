#!/bin/bash

echo "🚀 Installing/Updating Neovim Configuration"
echo "==========================================="
echo

# Check if nvim is installed
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed. Please install it first:"
    echo "   brew install neovim"
    exit 1
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NVIM_DIR="$DOTFILES_DIR/nvim"

# Check if nvim directory exists
if [ ! -d "$NVIM_DIR" ]; then
    echo "❌ nvim directory not found at: $NVIM_DIR"
    exit 1
fi

# Check if config is already properly linked
if [ -L "$HOME/.config/nvim" ]; then
    CURRENT_LINK=$(readlink "$HOME/.config/nvim")
    if [ "$CURRENT_LINK" = "$NVIM_DIR" ]; then
        echo "✅ Neovim configuration is already properly linked!"
        echo "   ~/.config/nvim -> $NVIM_DIR"
        echo ""
        echo "📋 Current setup:"
        echo "   Location: $NVIM_DIR"
        echo "   Symlink:  ~/.config/nvim"
        echo ""
        echo "🎯 Next steps:"
        echo "   1. Your config is up to date (using symlink)"
        echo "   2. Open Neovim to use latest configuration"
        echo "   3. Run :Lazy sync if you want to update plugins"
        echo ""
        echo "✨ No changes needed - you're all set!"
        exit 0
    else
        echo "🔗 Neovim symlink exists but points to wrong location:"
        echo "   Current: $CURRENT_LINK"
        echo "   Expected: $NVIM_DIR"
        echo "   Updating symlink..."
        rm "$HOME/.config/nvim"
    fi
elif [ -d "$HOME/.config/nvim" ]; then
    echo "📁 Found existing Neovim directory (not symlinked)"
    echo ""
    read -p "🔄 Replace with symlink to dotfiles? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$timestamp"
        echo "   📦 Backup saved to: ~/.config/nvim.backup.$timestamp"
    else
        echo "   ⏭️  Keeping existing configuration"
        exit 0
    fi
fi

# Create the config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Create symlink
echo "🔗 Creating symlink to nvim configuration..."
ln -s "$NVIM_DIR" "$HOME/.config/nvim"

if [ $? -eq 0 ]; then
    echo "   ✅ Symlink created: ~/.config/nvim -> $NVIM_DIR"
else
    echo "   ❌ Failed to create symlink"
    exit 1
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Configuration details:"
echo "   Location: $NVIM_DIR"
echo "   Symlink:  ~/.config/nvim"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch Neovim:    nvim"
echo "   2. Plugins will auto-install via Lazy.nvim"
echo "   3. LSP servers will install via Mason"
echo "   4. Database UI available with <leader>xb"
echo ""
echo "📚 Documentation:"
echo "   README:     $NVIM_DIR/README.md"
echo "   Comparison: $NVIM_DIR/COMPARISON.md"
echo ""
echo "Happy coding! 🎉"