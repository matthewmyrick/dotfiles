#!/bin/bash

echo "🎨 Setting up custom prompt configuration..."

# Source directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPT_SOURCE="$DOTFILES_DIR/scripts/shell/prompt"
PROMPT_TARGET="$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/prompt"

# Check if source directory exists
if [ ! -d "$PROMPT_SOURCE" ]; then
    echo "❌ Prompt source directory not found: $PROMPT_SOURCE"
    exit 1
fi

# Create target directory if it doesn't exist
if [ ! -d "$(dirname "$PROMPT_TARGET")" ]; then
    echo "  📁 Creating shell modules directory..."
    mkdir -p "$(dirname "$PROMPT_TARGET")"
fi

# Check if prompt is already installed
if [ -d "$PROMPT_TARGET" ]; then
    echo "  ✓ Prompt configuration already exists at $PROMPT_TARGET"
    echo "  🔄 Updating with latest version..."
fi

# Copy prompt configuration
echo "  📄 Installing prompt configuration..."
cp -r "$PROMPT_SOURCE" "$(dirname "$PROMPT_TARGET")/"

# Check if the prompt is being sourced in .zshrc
if ! grep -q "scripts/shell/prompt/config.sh" ~/.zshrc 2>/dev/null; then
    echo ""
    echo "  ⚠️  Prompt not yet configured in ~/.zshrc"
    echo ""
    echo "  📝 To activate the prompt, add this line to your ~/.zshrc:"
    echo ""
    echo "     source \"\$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/prompt/config.sh\""
    echo ""
    echo "  Or if using the shell module system, it should load automatically."
else
    echo "  ✅ Prompt is already configured in ~/.zshrc"
fi

echo ""
echo "✓ Prompt configuration installed successfully!"
echo ""
echo "📋 Features:"
echo "  • Two-line prompt with icons"
echo "  • Git branch and status indicators"
echo "  • Colorful and modern design"
echo "  • Username, hostname, and directory info"
echo ""
echo "🔄 To apply changes, run: source ~/.zshrc"
echo "💡 To customize, edit: ~/GitHub/matthewmyrick/dotfiles/scripts/shell/prompt/config.sh"