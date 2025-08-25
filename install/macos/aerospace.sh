#!/bin/bash

echo "✈️ Setting up AeroSpace window manager..."

# Check if AeroSpace is installed
if ! command -v aerospace &>/dev/null; then
  echo "  ⚠️  AeroSpace not found - should be installed by brew-casks.sh"
  echo "  You can install manually with: brew install --cask nikitabobko/tap/aerospace"
  exit 1
else
  echo "  ✓ AeroSpace is installed"
fi

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create AeroSpace config directory if it doesn't exist
mkdir -p ~/.config/aerospace

# Copy AeroSpace configuration if it exists in dotfiles
if [ -f "$DOTFILES_DIR/aerospace/aerospace.toml" ]; then
  echo "  Copying AeroSpace configuration..."
  cp "$DOTFILES_DIR/aerospace/aerospace.toml" ~/.config/aerospace/
  echo "  ✓ AeroSpace configuration installed"
else
  echo "  Creating default AeroSpace configuration..."
  cat > ~/.config/aerospace/aerospace.toml << 'EOF'
# AeroSpace Configuration
# https://github.com/nikitabobko/AeroSpace

# Global settings
accordion-padding = 30
default-root-container-layout = 'tiles'
default-root-container-orientation = 'auto'

# Normalizations - fix common app behaviors
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

# Visual feedback
[gaps]
inner.horizontal = 5
inner.vertical =   5
outer.left =       5
outer.bottom =     5
outer.top =        5
outer.right =      5

# Workspace assignments
[workspace-to-monitor-force-assignment]
1 = 'main'
2 = 'main' 
3 = 'main'
4 = 'main'
5 = 'secondary'
6 = 'secondary'
7 = 'secondary'
8 = 'secondary'
9 = 'secondary'

# Mode definitions
[mode.main.binding]
# Focus commands
alt-h = 'focus left'
alt-j = 'focus down'  
alt-k = 'focus up'
alt-l = 'focus right'

# Move commands
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

# Layout commands
alt-slash = 'layout tiles horizontal vertical'
alt-comma = 'layout accordion horizontal vertical'

# Workspace switching
alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'
alt-5 = 'workspace 5'
alt-6 = 'workspace 6'
alt-7 = 'workspace 7'
alt-8 = 'workspace 8'
alt-9 = 'workspace 9'

# Move to workspace
alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'
alt-shift-5 = 'move-node-to-workspace 5'
alt-shift-6 = 'move-node-to-workspace 6'
alt-shift-7 = 'move-node-to-workspace 7'
alt-shift-8 = 'move-node-to-workspace 8'
alt-shift-9 = 'move-node-to-workspace 9'

# Floating and fullscreen
alt-shift-space = 'layout floating tiling'
alt-f = 'fullscreen'

# Resizing
alt-shift-minus = 'resize smart -50'
alt-shift-equal = 'resize smart +50'

# Service mode for advanced operations
alt-semicolon = 'mode service'

[mode.service.binding]
esc = ['reload-config', 'mode main']
r = ['flatten-workspace-tree', 'mode main']
f = ['layout floating tiling', 'mode main'] 
backspace = ['close-all-windows-but-current', 'mode main']

# Application-specific rules
[[on-window-detected]]
if.app-id = 'com.apple.finder'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'com.apple.calculator'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'com.apple.ActivityMonitor'
run = 'layout floating'
EOF
  echo "  ✓ Default AeroSpace configuration created"
fi

# Check if AeroSpace is running
if pgrep -f "AeroSpace" > /dev/null; then
  echo "  ✓ AeroSpace is already running"
else
  echo "  Starting AeroSpace..."
  open -a AeroSpace
  echo "  ✓ AeroSpace started"
fi

# Reload configuration if AeroSpace is running
sleep 2
if pgrep -f "AeroSpace" > /dev/null; then
  echo "  Reloading AeroSpace configuration..."
  aerospace reload-config 2>/dev/null || echo "  Note: Config will be loaded when AeroSpace fully starts"
fi

echo "✓ AeroSpace window manager configured successfully!"
echo ""
echo "  🎮 Key Bindings:"
echo "    Alt+H/J/K/L        - Focus left/down/up/right"
echo "    Alt+Shift+H/J/K/L  - Move window left/down/up/right"
echo "    Alt+1-9            - Switch to workspace 1-9"
echo "    Alt+Shift+1-9      - Move window to workspace 1-9"
echo "    Alt+F              - Toggle fullscreen"
echo "    Alt+Shift+Space    - Toggle floating/tiling"
echo "    Alt+;              - Enter service mode"
echo ""
echo "  📖 Learn more: https://github.com/nikitabobko/AeroSpace"