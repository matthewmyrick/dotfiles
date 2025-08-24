#!/bin/bash

# Modular dotfiles installer
# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

# Get the directory where this script is located
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function installDotfiles() {
  echo "🚀 Starting modular dotfiles installation..."
  echo ""

  # Define the order of installation
  local INSTALL_ORDER=(
    "dependencies"
    "dotfiles"
    "sdks"
    "clis"
    "development"
    "macos"
  )

  # Function to run all scripts in a directory
  run_scripts_in_dir() {
    local dir="$1"
    local full_path="$INSTALL_DIR/install/$dir"
    
    if [ -d "$full_path" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "🔄 Running $dir scripts..."
      echo "═══════════════════════════════════════════════════════════════"
      
      # Find all .sh files in the directory and run them
      find "$full_path" -name "*.sh" -type f | sort | while read -r script; do
        if [ -x "$script" ] || chmod +x "$script" 2>/dev/null; then
          echo ""
          echo "▶️  Running $(basename "$script")..."
          bash "$script" || {
            echo "❌ Error running $script"
            return 1
          }
        else
          echo "⚠️  Skipping $script (not executable)"
        fi
      done
      echo ""
      echo "✅ $dir scripts completed"
      echo ""
    else
      echo "⚠️  Directory $full_path not found, skipping..."
    fi
  }

  # Run scripts in the defined order
  for category in "${INSTALL_ORDER[@]}"; do
    run_scripts_in_dir "$category"
  done

  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Dotfiles installation completed successfully!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "ℹ️  Shell Module System:"
  echo "  - Modular functions installed to ~/GitHub/matthewmyrick/dotfiles/scripts/shell/"
  echo "  - Functions use lazy loading for optimal performance"
  echo "  - Run 'shell_modules' to see available modules"
  echo "  - Run 'shell_loaded' to see what's currently loaded"
  echo ""
  echo "📋 Next Steps:"
  echo "  - Restart your shell or source the appropriate file:"
  echo "    • ~/.bash_profile"
  echo "    • ~/.zshrc"
  echo "  - .gitconfig - Manual setup required"
  echo ""
}

# Main execution
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                     DOTFILES INSTALLER                       ║"
echo "║                                                               ║"
echo "║  This will install/update all dotfiles and dependencies      ║"
echo "║  This is a one-way, destructive process for some configs     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

read -p "Are you sure you want to proceed? (y/n) " -n 1
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  installDotfiles
else
  echo "Installation cancelled."
  exit 0
fi

# Cleanup
unset installDotfiles