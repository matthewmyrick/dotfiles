#!/bin/bash

# Modular dotfiles installer
# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

# Get the directory where this script is located
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
INSTALL_TARGET=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--install)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: --install requires a target"
        echo "Run '$0 --help' for usage information"
        exit 1
      fi
      INSTALL_TARGET="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -i, --install <target>  Install specific component"
      echo "                          Available targets:"
      echo "                            brew        - Homebrew and packages"
      echo "                            nvim        - Neovim configuration"
      echo "                            sketchybar  - SketchyBar configuration"
      echo "                            ghostty     - Ghostty terminal configuration"
      echo "                            scripts     - Shell scripts and modules"
      echo "                            hammerspoon - Hammerspoon configuration"
      echo ""
      echo "  -h, --help              Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 --install nvim       # Install only Neovim configuration"
      echo "  $0 --install brew       # Install only Homebrew packages"
      echo "  $0                      # Run full installation (all components)"
      echo ""
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
done

# Validate install target if provided
if [[ -n "$INSTALL_TARGET" ]]; then
  case "$INSTALL_TARGET" in
    brew|nvim|sketchybar|ghostty|scripts|hammerspoon)
      # Valid target
      ;;
    *)
      echo "Error: Invalid install target '$INSTALL_TARGET'"
      echo "Valid targets: brew, nvim, sketchybar, ghostty, scripts, hammerspoon"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
fi

function installNvimOnly() {
  echo "🚀 Starting Neovim configuration installation..."
  echo ""
  
  # Run only nvim-related scripts
  if [ -f "$INSTALL_DIR/install/dotfiles/nvim.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Neovim configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/nvim.sh" || {
      echo "❌ Error installing Neovim configuration"
      return 1
    }
    echo "✅ Neovim configuration installed successfully!"
  else
    echo "⚠️  Neovim installation script not found at $INSTALL_DIR/install/dotfiles/nvim.sh"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Neovim installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Next Steps:"
  echo "  - Open Neovim and run :Lazy sync to install plugins"
  echo "  - Configuration is located at ~/GitHub/matthewmyrick/dotfiles/nvim"
  echo ""
}

function installBrewOnly() {
  echo "🚀 Starting Homebrew packages installation..."
  echo ""
  
  # First ensure Homebrew is installed
  if [ -f "$INSTALL_DIR/install/dependencies/homebrew.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Checking/Installing Homebrew..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/homebrew.sh" || {
      echo "❌ Error with Homebrew setup"
      return 1
    }
  fi
  
  # Then install brew packages
  if [ -f "$INSTALL_DIR/install/dependencies/brew.sh" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Homebrew packages..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/brew.sh" || {
      echo "❌ Error installing Homebrew packages"
      return 1
    }
    echo "✅ Homebrew packages installed successfully!"
  else
    echo "⚠️  Brew packages script not found at $INSTALL_DIR/install/dependencies/brew.sh"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Homebrew installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Installed packages can be viewed with: brew list"
  echo ""
}

function installSketchybarOnly() {
  echo "🚀 Starting SketchyBar configuration installation..."
  echo ""
  
  if [ -f "$INSTALL_DIR/install/dotfiles/sketchybar.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing SketchyBar configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/sketchybar.sh" || {
      echo "❌ Error installing SketchyBar configuration"
      return 1
    }
    echo "✅ SketchyBar configuration installed successfully!"
  else
    echo "⚠️  SketchyBar installation script not found"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 SketchyBar installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Configuration located at ~/.config/sketchybar"
  echo "  - Run 'brew services restart sketchybar' to apply changes"
  echo ""
}

function installGhosttyOnly() {
  echo "🚀 Starting Ghostty terminal configuration installation..."
  echo ""
  
  if [ -f "$INSTALL_DIR/install/dotfiles/ghostty.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Ghostty configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/ghostty.sh" || {
      echo "❌ Error installing Ghostty configuration"
      return 1
    }
    echo "✅ Ghostty configuration installed successfully!"
  else
    echo "⚠️  Ghostty installation script not found"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Ghostty installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Configuration located at ~/.config/ghostty"
  echo ""
}

function installScriptsOnly() {
  echo "🚀 Starting shell scripts and modules installation..."
  echo ""
  
  # Run all script-related installations
  local script_dirs=("scripts" "shell")
  for dir in "${script_dirs[@]}"; do
    if [ -f "$INSTALL_DIR/install/dotfiles/$dir.sh" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "🔄 Installing $dir..."
      echo "═══════════════════════════════════════════════════════════════"
      bash "$INSTALL_DIR/install/dotfiles/$dir.sh" || {
        echo "⚠️  Warning: Error installing $dir"
      }
    fi
  done
  
  echo "✅ Shell scripts and modules installed successfully!"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Scripts installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Shell Module System:"
  echo "  - Modules installed to ~/GitHub/matthewmyrick/dotfiles/scripts/shell/"
  echo "  - Run 'shell_modules' to see available modules"
  echo "  - Run 'shell_loaded' to see what's currently loaded"
  echo ""
}

function installHammerspoonOnly() {
  echo "🚀 Starting Hammerspoon configuration installation..."
  echo ""
  
  if [ -f "$INSTALL_DIR/install/dotfiles/hammerspoon.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Hammerspoon configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/hammerspoon.sh" || {
      echo "❌ Error installing Hammerspoon configuration"
      return 1
    }
    echo "✅ Hammerspoon configuration installed successfully!"
  else
    echo "⚠️  Hammerspoon installation script not found"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Hammerspoon installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Configuration located at ~/.hammerspoon"
  echo "  - Reload Hammerspoon config to apply changes"
  echo ""
}

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
case "$INSTALL_TARGET" in
  nvim)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   NEOVIM INSTALLER                           ║"
    echo "║                                                               ║"
    echo "║  This will install/update Neovim configuration               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installNvimOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  brew)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   HOMEBREW INSTALLER                         ║"
    echo "║                                                               ║"
    echo "║  This will install Homebrew and configured packages          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installBrewOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  sketchybar)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  SKETCHYBAR INSTALLER                        ║"
    echo "║                                                               ║"
    echo "║  This will install/update SketchyBar configuration           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installSketchybarOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  ghostty)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   GHOSTTY INSTALLER                          ║"
    echo "║                                                               ║"
    echo "║  This will install/update Ghostty terminal configuration     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installGhosttyOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  scripts)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   SCRIPTS INSTALLER                          ║"
    echo "║                                                               ║"
    echo "║  This will install shell scripts and modules                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installScriptsOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  hammerspoon)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                 HAMMERSPOON INSTALLER                        ║"
    echo "║                                                               ║"
    echo "║  This will install/update Hammerspoon configuration          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installHammerspoonOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  "")
    # No target specified, run full installation
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
    ;;
esac

# Cleanup
unset installDotfiles installNvimOnly installBrewOnly installSketchybarOnly installGhosttyOnly installScriptsOnly installHammerspoonOnly
