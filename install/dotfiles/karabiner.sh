#!/bin/bash

echo "⌨️  Setting up Karabiner..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Close Karabiner if it's running before copying config
osascript -e 'tell application "Karabiner-Elements" to quit' 2>/dev/null || true
osascript -e 'tell application "Karabiner-EventViewer" to quit' 2>/dev/null || true

# Copy the configuration
cp -R "$DOTFILES_DIR/keyboard/mac/karabiner" ~/.config/

# Reload Karabiner configuration without opening the GUI
if command -v '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' &>/dev/null; then
  '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --reload-karabiner-config 2>/dev/null || true
fi

echo "  ✓ Karabiner configured successfully"