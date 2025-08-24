#!/bin/bash

echo "📜 Installing scripts..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create necessary directories
echo "  Creating script directories..."
mkdir -p ~/.local/bin
mkdir -p ~/GitHub/matthewmyrick/dotfiles/scripts

# Copy Python scripts to ~/.local/bin (if they're executables)
if [ -d "$DOTFILES_DIR/scripts/python" ] && [ "$(ls -A "$DOTFILES_DIR"/scripts/python/*.py 2>/dev/null)" ]; then
  echo "  Python scripts to ~/.local/bin"
  for script in "$DOTFILES_DIR"/scripts/python/*.py; do
    if [ -f "$script" ] && [ -x "$script" ]; then
      cp "$script" ~/.local/bin/
    fi
  done
fi

# Copy the entire scripts directory structure for shell modules
echo "  Shell modules to ~/GitHub/matthewmyrick/dotfiles/scripts"
if [ -d "$DOTFILES_DIR/scripts" ]; then
  # Ensure the destination exists
  mkdir -p ~/GitHub/matthewmyrick/dotfiles
  # Copy the entire scripts directory structure
  cp -R "$DOTFILES_DIR/scripts" ~/GitHub/matthewmyrick/dotfiles/
  echo "    ✓ Copied modular shell functions"
  echo "    ✓ Copied shell module loader"
  echo "    ✓ Preserved directory structure for lazy loading"
fi

# Handle telemetry formatter separately if needed
if [ -f "$DOTFILES_DIR/scripts/python/telemetry.py" ]; then
  echo "  Telemetry formatter"
  mkdir -p ~/.config/zsh/scripts
  cp "$DOTFILES_DIR/scripts/python/telemetry.py" ~/.config/zsh/scripts/telemetry_formatter.py
fi

echo "✓ Scripts installed successfully!"