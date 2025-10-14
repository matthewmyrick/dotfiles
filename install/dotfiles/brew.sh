#!/bin/bash

echo "🚀 Installing Homebrew Packages"
echo "==============================="
echo

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Installing Homebrew first..."
    if [ -f "$DOTFILES_DIR/install/dependencies/homebrew.sh" ]; then
        bash "$DOTFILES_DIR/install/dependencies/homebrew.sh"
    else
        echo "Installing Homebrew directly..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Reload shell to get brew in PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo ""
echo "🍺 Installing Homebrew packages..."

# Run the existing brew scripts
if [ -f "$DOTFILES_DIR/install/dependencies/brew-packages.sh" ]; then
    echo "📦 Installing Homebrew packages..."
    bash "$DOTFILES_DIR/install/dependencies/brew-packages.sh"
else
    echo "⚠️  brew-packages.sh not found, skipping packages installation"
fi

if [ -f "$DOTFILES_DIR/install/dependencies/brew-casks.sh" ]; then
    echo ""
    echo "📱 Installing Homebrew casks..."
    bash "$DOTFILES_DIR/install/dependencies/brew-casks.sh"
else
    echo "⚠️  brew-casks.sh not found, skipping casks installation"
fi

echo ""
echo "✅ Homebrew installation complete!"
echo ""
echo "📋 Installed packages:"
echo "   View packages: brew list"
echo "   View casks:    brew list --cask"
echo ""
echo "🎯 Next steps:"
echo "   - All Homebrew packages and applications are now installed"
echo "   - Check Applications folder for newly installed apps"
echo ""
echo "Happy brewing! 🍺"