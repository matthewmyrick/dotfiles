#!/bin/bash

echo "🔧 Setting up global gitignore..."

# Source directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check if .gitignore_global exists in the dotfiles repo
if [ ! -f "$DOTFILES_DIR/.gitignore_global" ]; then
    echo "❌ .gitignore_global not found in dotfiles repo"
    exit 1
fi

# Copy .gitignore_global to home directory
echo "  📄 Copying .gitignore_global to ~/.gitignore_global"
cp "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

# Set global git configuration
echo "  ⚙️  Configuring git to use global gitignore..."
git config --global core.excludesFile ~/.gitignore_global

# Verify configuration
echo "  🔍 Verifying configuration..."
EXCLUDES_FILE=$(git config --get core.excludesFile)

if [ "$EXCLUDES_FILE" = "$HOME/.gitignore_global" ] || [ "$EXCLUDES_FILE" = "~/.gitignore_global" ]; then
    echo "  ✅ Global gitignore configured successfully!"
    echo "  📍 Location: $EXCLUDES_FILE"
else
    echo "  ❌ Failed to configure global gitignore"
    echo "  📍 Current setting: $EXCLUDES_FILE"
    exit 1
fi

echo "✓ Global gitignore setup completed!"