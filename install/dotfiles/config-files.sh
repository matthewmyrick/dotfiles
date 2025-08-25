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
cp -R "$DOTFILES_DIR/ghostty" ~/.config/ghostty

echo "✓ Dotfiles installed successfully!"