#!/bin/bash

echo "🤖 Setting up Claude commands..."

# Source directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_COMMANDS_SOURCE="$DOTFILES_DIR/install/ai/claude/commands"
CLAUDE_COMMANDS_TARGET="$HOME/.claude/commands"

# Check if source directory exists
if [ ! -d "$CLAUDE_COMMANDS_SOURCE" ]; then
    echo "❌ Claude commands source directory not found: $CLAUDE_COMMANDS_SOURCE"
    exit 1
fi

# Create ~/.claude directory if it doesn't exist
if [ ! -d "$HOME/.claude" ]; then
    echo "  📁 Creating ~/.claude directory..."
    mkdir -p "$HOME/.claude"
fi

# Create ~/.claude/commands directory if it doesn't exist
if [ ! -d "$CLAUDE_COMMANDS_TARGET" ]; then
    echo "  📁 Creating ~/.claude/commands directory..."
    mkdir -p "$CLAUDE_COMMANDS_TARGET"
else
    echo "  ✓ ~/.claude/commands directory already exists"
fi

# Copy all command files from source to target
echo "  📄 Installing Claude commands..."
if cp -r "$CLAUDE_COMMANDS_SOURCE"/* "$CLAUDE_COMMANDS_TARGET"/ 2>/dev/null; then
    echo "  ✅ Claude commands copied successfully"
    
    # List installed commands
    echo "  📋 Installed commands:"
    for cmd in "$CLAUDE_COMMANDS_TARGET"/*.md; do
        if [ -f "$cmd" ]; then
            local cmd_name=$(basename "$cmd" .md)
            echo "    - /$cmd_name"
        fi
    done
else
    echo "  ❌ Failed to copy Claude commands"
    exit 1
fi

# Verify installation
COMMANDS_COUNT=$(find "$CLAUDE_COMMANDS_TARGET" -name "*.md" -type f | wc -l)
if [ "$COMMANDS_COUNT" -gt 0 ]; then
    echo "  ✅ Successfully installed $COMMANDS_COUNT Claude command(s)"
else
    echo "  ⚠️  No command files found after installation"
fi

echo "✓ Claude commands setup completed!"
echo "📍 Commands installed to: $CLAUDE_COMMANDS_TARGET"