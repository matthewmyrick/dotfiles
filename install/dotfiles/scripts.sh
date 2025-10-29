#!/bin/bash

echo "📜 Installing scripts..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create necessary directories
echo "  Creating script directories..."
mkdir -p ~/.local/bin

# Copy Python scripts to ~/.local/bin (if they're executables)
if [ -d "$DOTFILES_DIR/scripts/python" ] && [ "$(ls -A "$DOTFILES_DIR"/scripts/python/*.py 2>/dev/null)" ]; then
  echo "  Python scripts to ~/.local/bin"
  for script in "$DOTFILES_DIR"/scripts/python/*.py; do
    if [ -f "$script" ] && [ -x "$script" ]; then
      cp "$script" ~/.local/bin/
    fi
  done
fi

# Scripts are already in the dotfiles directory - no need to copy
echo "  Shell modules available at $DOTFILES_DIR/scripts"
if [ -d "$DOTFILES_DIR/scripts" ]; then
  echo "    ✓ Modular shell functions available"
  echo "    ✓ Shell module loader ready"
  echo "    ✓ Directory structure preserved for lazy loading"
fi

# Handle telemetry formatter separately if needed
if [ -f "$DOTFILES_DIR/scripts/python/telemetry.py" ]; then
  echo "  Telemetry formatter"
  mkdir -p ~/.config/zsh/scripts
  cp "$DOTFILES_DIR/scripts/python/telemetry.py" ~/.config/zsh/scripts/telemetry_formatter.py
fi

echo "✓ Scripts installed successfully!"