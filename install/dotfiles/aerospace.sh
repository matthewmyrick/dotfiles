#!/bin/bash

echo "✈️ Installing AeroSpace configuration..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create AeroSpace config directory
mkdir -p ~/.config/aerospace

# Copy AeroSpace configuration
if [ -f "$DOTFILES_DIR/aerospace/aerospace.toml" ]; then
  cp "$DOTFILES_DIR/aerospace/aerospace.toml" ~/.config/aerospace/
  echo "  ✓ AeroSpace configuration copied to ~/.config/aerospace/"
else
  echo "  ⚠️  AeroSpace config not found in dotfiles"
fi

echo "✓ AeroSpace configuration installed."