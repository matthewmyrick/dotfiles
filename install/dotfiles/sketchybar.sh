#!/bin/bash

# DISABLED: SketchyBar installation commented out
# Uncomment the lines below to re-enable sketchybar setup

# echo "🎨 Setting up SketchyBar configuration..."

# # Get the directory where this script is located and go up two levels to get to dotfiles root
# DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# SKETCHYBAR_CONFIG_DIR="$DOTFILES_DIR/sketchybar"
# HOME_CONFIG_DIR="$HOME/.config/sketchybar"

# # Backup existing config if it exists
# if [ -d "$HOME_CONFIG_DIR" ]; then
#     echo "  📦 Backing up existing config..."
#     mv "$HOME_CONFIG_DIR" "$HOME_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
# fi

# # Create fresh directory structure
# echo "  📁 Creating ~/.config/sketchybar directory..."
# mkdir -p "$HOME_CONFIG_DIR"

# # Copy all sketchybar config files
# if [ -d "$SKETCHYBAR_CONFIG_DIR" ]; then
#     echo "  📋 Copying configuration files..."
#     cp -r "$SKETCHYBAR_CONFIG_DIR/"* "$HOME_CONFIG_DIR/"
#     
#     echo "  ✅ SketchyBar configuration copied to ~/.config/sketchybar/"
# else
#     echo "  ❌ SketchyBar configuration directory not found at $SKETCHYBAR_CONFIG_DIR"
#     exit 1
# fi

# # Make scripts executable
# echo "  🔧 Making scripts executable..."
# find "$SKETCHYBAR_CONFIG_DIR" -name "*.sh" -type f -exec chmod +x {} \;
# chmod +x "$SKETCHYBAR_CONFIG_DIR/sketchybarrc"

# # Add CONFIG_DIR export to shell profiles if not already present
# add_config_export() {
#     local shell_file="$1"
#     local export_line="export CONFIG_DIR=\"\$HOME/.config/sketchybar\""
#     
#     if [ -f "$shell_file" ]; then
#         if ! grep -q "CONFIG_DIR.*sketchybar" "$shell_file"; then
#             echo "  📝 Adding CONFIG_DIR export to $(basename "$shell_file")"
#             echo "" >> "$shell_file"
#             echo "# SketchyBar configuration" >> "$shell_file"
#             echo "$export_line" >> "$shell_file"
#         else
#             echo "  ✓ CONFIG_DIR already configured in $(basename "$shell_file")"
#         fi
#     fi
# }

# # Add to common shell profiles
# add_config_export "$HOME/.zshrc"
# add_config_export "$HOME/.bashrc"
# add_config_export "$HOME/.bash_profile"

# # Stop existing sketchybar service if running
# if brew services list | grep -q "sketchybar.*started"; then
#     echo "  🛑 Stopping existing sketchybar service..."
#     brew services stop sketchybar
# fi

# # Start sketchybar service
# echo "  🚀 Starting sketchybar service..."
# brew services start sketchybar

# echo "  ✅ SketchyBar setup completed!"
# echo ""
# echo "  💡 Tips:"
# echo "    • Restart your shell or run 'source ~/.zshrc' to load CONFIG_DIR"
# echo "    • Use 'sketchybar --reload' to reload configuration"
# echo "    • Use 'brew services restart sketchybar' to restart the service"
# echo "    • Configuration files are in ~/.config/sketchybar/"

echo "⚠️  SketchyBar installation is currently disabled"
echo "   To re-enable, uncomment the lines in this script"