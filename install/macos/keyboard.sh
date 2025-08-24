#!/bin/bash

echo "⌨️  Configuring macOS keyboard settings..."

# Set keyboard repeat rate for faster scrolling
echo "  Setting keyboard repeat rate for faster scrolling..."
# Set key repeat rate to fastest (1)
defaults write -g KeyRepeat -int 1
# Set delay until repeat to shortest (10)
defaults write -g InitialKeyRepeat -int 10

# Also set for the current user domain
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Force the settings to apply
defaults write com.apple.universalaccess slowKey -int 0

# Restart the SystemUIServer to apply changes
killall SystemUIServer 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "  ✓ Keyboard repeat rate set to fastest (1)"
echo "  ✓ Initial delay set to shortest (10)"
echo "  ✓ Settings applied to current session"
echo "  Note: If settings don't apply immediately, log out and back in"

echo "✓ macOS keyboard configured."