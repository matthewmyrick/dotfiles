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

# Install nvim-postgres config (PostgreSQL client)
echo "  Installing nvim-postgres config..."
rm -rf ~/.config/nvim-postgres
cp -R "$DOTFILES_DIR/nvim-postgres" ~/.config/
mkdir -p ~/.config/nvim-postgres/sql

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

echo "  Installing ptpython config..."
mkdir -p ~/.ptpython
cp "$DOTFILES_DIR/ptpython/"* ~/.ptpython/

echo "  Installing sre-agent..."
mkdir -p ~/.config/sre-agent/services
mkdir -p ~/.config/sre-agent/analysis
cp "$DOTFILES_DIR/sre-agent/sre" ~/.config/sre-agent/
chmod +x ~/.config/sre-agent/sre
cp "$DOTFILES_DIR/sre-agent/services/"* ~/.config/sre-agent/services/ 2>/dev/null || true

echo "  Installing ssh-manager..."
mkdir -p ~/.config/ssh-manager/keys
cp "$DOTFILES_DIR/ssh-manager/ssm" ~/.config/ssh-manager/
chmod +x ~/.config/ssh-manager/ssm
# Only copy config if it doesn't exist (preserve user's connections)
if [ ! -f ~/.config/ssh-manager/config.yaml ]; then
    cp "$DOTFILES_DIR/ssh-manager/config.yaml" ~/.config/ssh-manager/
fi

echo "✓ Dotfiles installed successfully!"
