#!/bin/bash

echo "📁 Installing dotfiles..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Copy basic config files
echo "  Installing shell configs..."
cp "$DOTFILES_DIR/.aliases" ~
cp "$DOTFILES_DIR/.bash_profile" ~
cp "$DOTFILES_DIR/.bash_prompt" ~
cp "$DOTFILES_DIR/.bashrc" ~
cp "$DOTFILES_DIR/.zshrc" ~
cp "$DOTFILES_DIR/.wezterm.lua" ~
cp "$DOTFILES_DIR/.vimrc" ~

# Install Neovim config
echo "  Installing Neovim config..."
rm -rf ~/.config/nvim
cp -R "$DOTFILES_DIR/nvim" ~/.config/

# yazi removed - no longer needed

echo "  Installing ghostty config..."
cp -R "$DOTFILES_DIR/ghostty" ~/.config

echo "  Installing sketchybar config..."
mkdir -p ~/.config/sketchybar
cp "$DOTFILES_DIR/sketchybar/sketchybarrc" ~/.config/sketchybar/
chmod +x ~/.config/sketchybar/sketchybarrc

# Restart sketchybar if it's installed
if command -v sketchybar &> /dev/null; then
  echo "  Restarting sketchybar..."
  brew services restart sketchybar 2>/dev/null || echo "    Note: Could not restart sketchybar service"
fi

echo "  Installing Hammerspoon config..."
mkdir -p ~/.hammerspoon
cp "$DOTFILES_DIR/hammerspoon/init.lua" ~/.hammerspoon/

echo "  Starting Hammerspoon..."

# Open Hammerspoon if not already running
if ! pgrep -x "Hammerspoon" > /dev/null; then
  echo "    Opening Hammerspoon..."
  open -a Hammerspoon
else
  echo "    ✓ Hammerspoon already running"
  # Reload config if already running
  echo "    Reloading Hammerspoon config..."
  osascript -e 'tell application "System Events" to tell process "Hammerspoon" to click menu item "Reload Config" of menu "Hammerspoon" of menu bar item "Hammerspoon" of menu bar 1' 2>/dev/null || echo "    Note: Could not reload config automatically"
fi

echo "✓ Dotfiles installed successfully!"
