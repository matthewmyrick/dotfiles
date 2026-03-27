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
      echo "                            nvim-dbee   - Database client (nvim-dbee)"
      echo "                            nvim-postgres - PostgreSQL client (nvim-postgres)"
      echo "                            nvim-aws-s3   - AWS S3 browser (nvim-aws-s3)"
      echo "                            nvim-aws-secrets - AWS Secrets Manager viewer"
      echo "                            sketchybar  - SketchyBar configuration"
      echo "                            ghostty     - Ghostty terminal configuration"
      echo "                            scripts     - Shell scripts and modules"
      echo "                            hammerspoon - Hammerspoon configuration"
      echo "                            claude      - Claude commands"
      echo "                            prompt      - Terminal prompt configuration"
      echo "                            ssm         - SSH Manager (interactive SSH)"
      echo "                            procrastinate - Procrastinate CLI tool"
      echo "                            git         - Git tools (gh, git, lazygit, auto-fetch)"
      echo "                            zshrc       - Zsh configuration (.zshrc, .aliases)"
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
    brew|nvim|nvim-dbee|nvim-postgres|nvim-aws-s3|nvim-aws-secrets|sketchybar|ghostty|scripts|hammerspoon|claude|prompt|ssm|procrastinate|git|zshrc)
      # Valid target
      ;;
    *)
      echo "Error: Invalid install target '$INSTALL_TARGET'"
      echo "Valid targets: brew, nvim, nvim-dbee, nvim-postgres, nvim-aws-s3, nvim-aws-secrets, sketchybar, ghostty, scripts, hammerspoon, claude, prompt, ssm, procrastinate, git, zshrc"
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

function installNvimDbeeOnly() {
  echo "🚀 Starting nvim-dbee (database client) installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing nvim-dbee configuration..."
  echo "═══════════════════════════════════════════════════════════════"

  # Install nvim-dbee config
  rm -rf ~/.config/nvim-dbee
  cp -R "$INSTALL_DIR/nvim-dbee" ~/.config/

  echo "✅ nvim-dbee configuration installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 nvim-dbee installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Usage:"
  echo "  - Run 'dbc' to open the database client"
  echo "  - First run will install plugins and compile Go backend"
  echo "  - Use <leader>db to toggle database explorer"
  echo "  - Configuration at ~/.config/nvim-dbee"
  echo ""
}

function installNvimPostgresOnly() {
  echo "🚀 Starting nvim-postgres (PostgreSQL client) installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing nvim-postgres configuration..."
  echo "═══════════════════════════════════════════════════════════════"

  # Install nvim-postgres config
  rm -rf ~/.config/nvim-postgres
  cp -R "$INSTALL_DIR/nvim-postgres" ~/.config/

  # Seed default connection if no connections file exists
  local CONN_DIR="$HOME/.local/share/nvim-postgres/postgres"
  local CONN_FILE="$CONN_DIR/connections.json"
  if [ ! -f "$CONN_FILE" ]; then
    mkdir -p "$CONN_DIR"
    cat > "$CONN_FILE" << 'CONN_EOF'
{
  "connections": [
    {
      "id": "localhost-postgres",
      "name": "localhost",
      "host": "localhost",
      "port": "5438",
      "database": "postgres",
      "user": "postgres",
      "password": "postgres",
      "ssl": false
    }
  ]
}
CONN_EOF
    echo "  Created default connection (localhost/postgres)"
  else
    echo "  Preserved existing connections.json"
  fi

  # Install sql-formatter for <leader>ff
  if ! command -v sql-formatter &>/dev/null; then
    echo "  Installing sql-formatter..."
    npm install -g sql-formatter
  else
    echo "  sql-formatter already installed"
  fi

  echo "✅ nvim-postgres configuration installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 nvim-postgres installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Usage:"
  echo "  - Run 'NVIM_APPNAME=nvim-postgres nvim' to open"
  echo "  - First run will install plugins via lazy.nvim"
  echo "  - Press / to search tables, <leader><leader> for quick queries"
  echo "  - Configuration at ~/.config/nvim-postgres"
  echo ""
}

function installNvimAwsS3Only() {
  echo "🚀 Starting nvim-aws-s3 (S3 Browser) installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing nvim-aws-s3 configuration..."
  echo "═══════════════════════════════════════════════════════════════"

  # Install nvim-aws-s3 config
  rm -rf ~/.config/nvim-aws-s3
  cp -R "$INSTALL_DIR/nvim-aws-s3" ~/.config/

  echo "✅ nvim-aws-s3 configuration installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 nvim-aws-s3 installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Prerequisites:"
  echo "  - AWS CLI must be configured (run 'aws configure')"
  echo "  - Valid AWS credentials with S3 read access"
  echo ""
  echo "📋 Usage:"
  echo "  - Run 'NVIM_APPNAME=nvim-aws-s3 nvim' to open"
  echo "  - On startup, enter your AWS region (e.g., us-east-1)"
  echo "  - Press Enter on a bucket to expand, Enter on a file to preview"
  echo "  - Press / to fuzzy search files, ? for help"
  echo "  - Configuration at ~/.config/nvim-aws-s3"
  echo ""
}

function installNvimAwsSecretsOnly() {
  echo "🚀 Starting nvim-aws-secrets (AWS Secrets Manager Viewer) installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing nvim-aws-secrets configuration..."
  echo "═══════════════════════════════════════════════════════════════"

  # Install nvim-aws-secrets config
  rm -rf ~/.config/nvim-aws-secrets
  cp -R "$INSTALL_DIR/nvim-aws-secrets" ~/.config/

  echo "✅ nvim-aws-secrets configuration installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 nvim-aws-secrets installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Prerequisites:"
  echo "  - AWS CLI must be configured (run 'aws configure')"
  echo "  - Valid AWS credentials with Secrets Manager read access"
  echo ""
  echo "📋 Usage:"
  echo "  - Run 'aws-secrets' to open (alias for NVIM_APPNAME=nvim-aws-secrets nvim)"
  echo "  - On startup, enter your AWS region (e.g., us-east-1)"
  echo "  - Press Enter on a secret to view its value"
  echo "  - Press / to fuzzy search secrets, ? for help"
  echo "  - Press y to copy secret value to clipboard"
  echo "  - Configuration at ~/.config/nvim-aws-secrets"
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
  if [ -f "$INSTALL_DIR/install/dependencies/brew-packages.sh" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Homebrew packages..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/brew-packages.sh" || {
      echo "❌ Error installing Homebrew packages"
      return 1
    }
    echo "✅ Homebrew packages installed successfully!"
  else
    echo "⚠️  Brew packages script not found at $INSTALL_DIR/install/dependencies/brew-packages.sh"
    return 1
  fi

  # Then install brew casks
  if [ -f "$INSTALL_DIR/install/dependencies/brew-casks.sh" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Homebrew casks..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/brew-casks.sh" || {
      echo "❌ Error installing Homebrew casks"
      return 1
    }
    echo "✅ Homebrew casks installed successfully!"
  else
    echo "⚠️  Brew casks script not found at $INSTALL_DIR/install/dependencies/brew-casks.sh"
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

function installClaudeCommandsOnly() {
  echo "🚀 Starting Claude commands installation..."
  echo ""
  
  if [ -f "$INSTALL_DIR/install/ai/claude-commands.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Claude commands..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/ai/claude-commands.sh" || {
      echo "❌ Error installing Claude commands"
      return 1
    }
    echo "✅ Claude commands installed successfully!"
  else
    echo "⚠️  Claude commands installation script not found"
    return 1
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Claude commands installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Commands installed to ~/.claude/commands"
  echo "  - Use /update-context in Claude Code to update CLAUDE.md"
  echo ""
}

function installPromptOnly() {
  echo "🚀 Starting terminal prompt installation..."
  echo ""

  if [ -f "$INSTALL_DIR/install/dotfiles/prompt.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing terminal prompt configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/prompt.sh" || {
      echo "❌ Error installing prompt configuration"
      return 1
    }
    echo "✅ Prompt configuration installed successfully!"
  else
    echo "⚠️  Prompt installation script not found"
    return 1
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Prompt installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Cool two-line prompt with:"
  echo "  • Icons for user, folder, and git"
  echo "  • Git branch and status display"
  echo "  • Colorful modern design"
  echo ""
  echo "🔄 Run 'source ~/.zshrc' to apply changes"
  echo ""
}

function installSsmOnly() {
  echo "🚀 Starting SSH Manager (ssm) installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing SSH Manager..."
  echo "═══════════════════════════════════════════════════════════════"

  # Create directories
  mkdir -p ~/.config/ssh-manager/keys

  # Copy ssm script
  cp "$INSTALL_DIR/ssh-manager/ssm" ~/.config/ssh-manager/
  chmod +x ~/.config/ssh-manager/ssm

  # Only copy config if it doesn't exist (preserve user's connections)
  if [ ! -f ~/.config/ssh-manager/config.yaml ]; then
    cp "$INSTALL_DIR/ssh-manager/config.yaml" ~/.config/ssh-manager/
    echo "  Created default config.yaml"
  else
    echo "  Preserved existing config.yaml"
  fi

  echo "✅ SSH Manager installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 SSH Manager installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Usage:"
  echo "  • ssm              - Interactive SSH connection picker"
  echo "  • ssm --add        - Add a new connection"
  echo "  • ssm --list       - List all connections"
  echo "  • ssm --keys       - List available PEM keys"
  echo "  • ssm --add-key    - Add a new PEM key"
  echo ""
  echo "📁 Configuration:"
  echo "  • Config: ~/.config/ssh-manager/config.yaml"
  echo "  • Keys:   ~/.config/ssh-manager/keys/"
  echo ""
}

function installProcrastinateOnly() {
  echo "🚀 Starting Procrastinate CLI installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing Procrastinate CLI..."
  echo "═══════════════════════════════════════════════════════════════"

  # Requires Go to be installed
  if ! command -v go &>/dev/null; then
    echo "❌ Go is not installed. Install Go first: ./install.sh --install brew"
    return 1
  fi

  go install github.com/matthewmyrick/procrastinate-cli@latest || {
    echo "❌ Error installing procrastinate-cli"
    return 1
  }

  echo "✅ Procrastinate CLI installed successfully!"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Procrastinate CLI installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Usage:"
  echo "  • procrastinate-cli    - Run the CLI tool"
  echo ""
}

function installGitOnly() {
  echo "🚀 Starting Git tools installation..."
  echo ""

  if [ -f "$INSTALL_DIR/install/dotfiles/git.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔄 Installing Git tools (gh, git, lazygit, auto-fetch)..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/git.sh" || {
      echo "❌ Error installing Git tools"
      return 1
    }
    echo "✅ Git tools installed successfully!"
  else
    echo "⚠️  Git installation script not found"
    return 1
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Git tools installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

function installZshrcOnly() {
  local DOTFILES_DIR="$HOME/GitHub/matthewmyrick/dotfiles"
  echo "🚀 Starting Zsh configuration installation..."
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo "🔄 Installing .zshrc and .aliases..."
  echo "═══════════════════════════════════════════════════════════════"

  # Backup existing files
  if [ -f "$HOME/.zshrc" ]; then
    local backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.zshrc" "$backup"
    echo "📦 Backed up existing .zshrc to $backup"
  fi

  if [ -f "$HOME/.aliases" ]; then
    local backup="$HOME/.aliases.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOME/.aliases" "$backup"
    echo "📦 Backed up existing .aliases to $backup"
  fi

  # Copy files
  cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  echo "✅ Installed .zshrc"

  if [ -f "$DOTFILES_DIR/.aliases" ]; then
    cp "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
    echo "✅ Installed .aliases"
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "🎉 Zsh configuration installation completed!"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Run 'source ~/.zshrc' or open a new terminal to apply changes."
  echo ""
}

function installDotfiles() {
  echo "🚀 Starting complete dotfiles installation..."
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "📋 Installation Plan (20 Steps):"
  echo ""
  echo "PHASE 1: Core Dependencies (Steps 1-10)"
  echo "  1. Homebrew (package manager)"
  echo "  2. Python"
  echo "  3. Go"
  echo "  4. Node.js/npm"
  echo "  5. Terraform"
  echo "  6. Zoxide"
  echo "  7. Global gitignore"
  echo "  8. Homebrew packages"
  echo "  9. CLI tools (AWS, Claude)"
  echo "  10. Custom tools"
  echo ""
  echo "PHASE 2: SDKs & Config (Steps 11-15)"
  echo "  11. SDKs (Node, Python, Rust)"
  echo "  12. macOS settings"
  echo "  13. AI/Claude commands"
  echo "  14. Brew casks (GUI apps)"
  echo "  15. Shell scripts & modules"
  echo ""
  echo "PHASE 3: Applications (Steps 16-20)"
  echo "  16. Neovim"
  echo "  17. Ghostty terminal"
  echo "  18. Hammerspoon"
  echo "  19. Karabiner (keyboard)"
  echo "  20. SketchyBar"
  echo "════════════════════════════════════════════════════════════════"
  echo ""

  local total_steps=20
  local current_step=0

  # PHASE 1: Core Dependencies
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║              PHASE 1: Core Dependencies                   ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  # Step 1: Homebrew
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dependencies/homebrew.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🍺 Step $current_step/$total_steps: Installing Homebrew..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/homebrew.sh" || {
      echo "❌ Error installing Homebrew"
      return 1
    }
    echo "✅ Homebrew installed successfully!"
    echo ""
  fi

  # Steps 2-6: Core development tools
  local CORE_TOOLS=("python" "golang" "node" "terraform" "zoxide")
  for tool in "${CORE_TOOLS[@]}"; do
    ((current_step++))
    if [ -f "$INSTALL_DIR/install/core/$tool.sh" ]; then
      echo "═══════════════════════════════════════════════════════════════"
      echo "🚀 Step $current_step/$total_steps: Installing $tool..."
      echo "═══════════════════════════════════════════════════════════════"
      bash "$INSTALL_DIR/install/core/$tool.sh" || {
        echo "⚠️  Warning: Error installing $tool"
      }
      echo ""
    fi
  done

  # Step 7: Global gitignore
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/core/gitignore.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔧 Step $current_step/$total_steps: Setting up global gitignore..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/core/gitignore.sh" || {
      echo "⚠️  Warning: Error setting up global gitignore"
    }
    echo ""
  fi

  # Step 8: Homebrew packages
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dependencies/brew-packages.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "📦 Step $current_step/$total_steps: Installing Homebrew packages..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/brew-packages.sh" || {
      echo "⚠️  Warning: Error installing Homebrew packages"
    }
    echo ""
  fi

  # Step 9: CLI tools
  ((current_step++))
  echo "═══════════════════════════════════════════════════════════════"
  echo "🖥️  Step $current_step/$total_steps: Installing CLI tools..."
  echo "═══════════════════════════════════════════════════════════════"
  if [ -d "$INSTALL_DIR/install/clis" ]; then
    for cli_script in "$INSTALL_DIR/install/clis"/*.sh; do
      if [ -f "$cli_script" ]; then
        echo "  Installing $(basename "$cli_script" .sh)..."
        bash "$cli_script" || {
          echo "  ⚠️  Warning: Error installing $(basename "$cli_script")"
        }
      fi
    done
  fi
  echo ""

  # Step 10: Custom development tools
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/development/custom-tools.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🛠️  Step $current_step/$total_steps: Installing custom development tools..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/development/custom-tools.sh" || {
      echo "⚠️  Warning: Error installing custom development tools"
    }
    echo ""
  fi

  # PHASE 2: SDKs & Configuration
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║              PHASE 2: SDKs & Configuration                ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  # Step 11: SDKs
  ((current_step++))
  echo "═══════════════════════════════════════════════════════════════"
  echo "📚 Step $current_step/$total_steps: Installing SDKs..."
  echo "═══════════════════════════════════════════════════════════════"
  if [ -d "$INSTALL_DIR/install/sdks" ]; then
    for sdk_script in "$INSTALL_DIR/install/sdks"/*.sh; do
      if [ -f "$sdk_script" ]; then
        echo "  Installing $(basename "$sdk_script" .sh) SDK..."
        bash "$sdk_script" || {
          echo "  ⚠️  Warning: Error installing $(basename "$sdk_script")"
        }
      fi
    done
  fi
  echo ""

  # Step 12: macOS settings
  ((current_step++))
  echo "═══════════════════════════════════════════════════════════════"
  echo "🍎 Step $current_step/$total_steps: Configuring macOS settings..."
  echo "═══════════════════════════════════════════════════════════════"
  if [ -d "$INSTALL_DIR/install/macos" ]; then
    for macos_script in "$INSTALL_DIR/install/macos"/*.sh; do
      if [ -f "$macos_script" ]; then
        echo "  Configuring $(basename "$macos_script" .sh)..."
        bash "$macos_script" || {
          echo "  ⚠️  Warning: Error configuring $(basename "$macos_script")"
        }
      fi
    done
  fi
  echo ""

  # Step 13: AI/Claude commands
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/ai/claude-commands.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🤖 Step $current_step/$total_steps: Installing AI/Claude commands..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/ai/claude-commands.sh" || {
      echo "⚠️  Warning: Error installing Claude commands"
    }
    echo ""
  fi

  # Step 14: Brew casks
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dependencies/brew-casks.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🖥️  Step $current_step/$total_steps: Installing GUI applications (Brew casks)..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dependencies/brew-casks.sh" || {
      echo "⚠️  Warning: Error installing Brew casks"
    }
    echo ""
  fi

  # Step 15: Shell scripts and modules
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/scripts.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "📜 Step $current_step/$total_steps: Installing shell scripts & modules..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/scripts.sh" || {
      echo "⚠️  Warning: Error installing shell scripts"
    }
    echo ""
  fi

  # Also install prompt configuration here
  if [ -f "$INSTALL_DIR/install/dotfiles/prompt.sh" ]; then
    echo "  Installing terminal prompt configuration..."
    bash "$INSTALL_DIR/install/dotfiles/prompt.sh" || {
      echo "  ⚠️  Warning: Error installing prompt"
    }
  fi

  # PHASE 3: Applications
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║              PHASE 3: Applications                        ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  # Step 16: Neovim
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/nvim.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "📝 Step $current_step/$total_steps: Installing Neovim configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/nvim.sh" || {
      echo "⚠️  Warning: Error installing Neovim"
    }
    echo ""
  fi

  # Step 17: Ghostty
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/ghostty.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "👻 Step $current_step/$total_steps: Installing Ghostty terminal..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/ghostty.sh" || {
      echo "⚠️  Warning: Error installing Ghostty"
    }
    echo ""
  fi

  # Step 18: Hammerspoon
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/hammerspoon.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "🔨 Step $current_step/$total_steps: Installing Hammerspoon..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/hammerspoon.sh" || {
      echo "⚠️  Warning: Error installing Hammerspoon"
    }
    echo ""
  fi

  # Step 19: Karabiner
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/karabiner.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "⌨️  Step $current_step/$total_steps: Installing Karabiner keyboard configuration..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/karabiner.sh" || {
      echo "⚠️  Warning: Error installing Karabiner"
    }
    echo ""
  fi

  # Step 20: SketchyBar
  ((current_step++))
  if [ -f "$INSTALL_DIR/install/dotfiles/sketchybar.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "📊 Step $current_step/$total_steps: Installing SketchyBar..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/sketchybar.sh" || {
      echo "⚠️  Warning: Error installing SketchyBar"
    }
    echo ""
  fi

  # Any additional config files
  if [ -f "$INSTALL_DIR/install/dotfiles/config-files.sh" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "📁 Installing additional configuration files..."
    echo "═══════════════════════════════════════════════════════════════"
    bash "$INSTALL_DIR/install/dotfiles/config-files.sh" || {
      echo "⚠️  Warning: Error installing config files"
    }
    echo ""
  fi

  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "🎉 DOTFILES INSTALLATION COMPLETED!"
  echo "════════════════════════════════════════════════════════════════"
  echo ""
  echo "📋 Installation Summary:"
  echo ""
  echo "✅ PHASE 1: Core Dependencies"
  echo "  • Homebrew & packages"
  echo "  • Python, Go, Node.js, Terraform"
  echo "  • Zoxide, CLI tools, Custom tools"
  echo ""
  echo "✅ PHASE 2: SDKs & Configuration"
  echo "  • Node, Python, Rust SDKs"
  echo "  • macOS settings"
  echo "  • Claude AI commands"
  echo "  • GUI applications"
  echo "  • Shell scripts & modules"
  echo ""
  echo "✅ PHASE 3: Applications"
  echo "  • Neovim"
  echo "  • Ghostty terminal"
  echo "  • Hammerspoon"
  echo "  • Karabiner keyboard"
  echo "  • SketchyBar"
  echo ""
  echo "🔄 Next Steps:"
  echo "  1. Restart your shell or run: source ~/.zshrc"
  echo "  2. Open Neovim and run: :Lazy sync"
  echo "  3. Restart any GUI applications that were updated"
  echo ""
  echo "📚 Documentation:"
  echo "  • Shell modules: Run 'shell_modules' to see available modules"
  echo "  • Claude commands: Use /update-context in Claude Code"
  echo "  • README files in each configuration directory"
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
  nvim-dbee)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   NVIM-DBEE INSTALLER                        ║"
    echo "║                                                               ║"
    echo "║  This will install the database client (nvim-dbee)           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installNvimDbeeOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  nvim-postgres)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                NVIM-POSTGRES INSTALLER                       ║"
    echo "║                                                               ║"
    echo "║  This will install the PostgreSQL client (nvim-postgres)     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installNvimPostgresOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  nvim-aws-s3)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                 NVIM-AWS-S3 INSTALLER                        ║"
    echo "║                                                               ║"
    echo "║  This will install the S3 browser (nvim-aws-s3)              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installNvimAwsS3Only
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  nvim-aws-secrets)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              NVIM-AWS-SECRETS INSTALLER                      ║"
    echo "║                                                               ║"
    echo "║  This will install the AWS Secrets Manager viewer            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installNvimAwsSecretsOnly
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
  claude)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   CLAUDE COMMANDS INSTALLER                  ║"
    echo "║                                                               ║"
    echo "║  This will install Claude commands to ~/.claude/commands     ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installClaudeCommandsOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  prompt)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  PROMPT CONFIGURATION INSTALLER              ║"
    echo "║                                                               ║"
    echo "║  This will install the cool terminal prompt configuration    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installPromptOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  ssm)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   SSH MANAGER INSTALLER                       ║"
    echo "║                                                               ║"
    echo "║  This will install the SSH Manager (ssm) tool                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installSsmOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  procrastinate)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                PROCRASTINATE CLI INSTALLER                   ║"
    echo "║                                                               ║"
    echo "║  This will install procrastinate-cli via go install          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installProcrastinateOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  git)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   GIT TOOLS INSTALLER                        ║"
    echo "║                                                               ║"
    echo "║  This will install/upgrade gh, git, lazygit and set up       ║"
    echo "║  auto-fetch cron jobs for selected repositories              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installGitOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
  zshrc)
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  ZSHRC INSTALLER                             ║"
    echo "║                                                               ║"
    echo "║  This will install .zshrc and .aliases from dotfiles         ║"
    echo "║  Existing files will be backed up                            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Are you sure you want to proceed? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      installZshrcOnly
    else
      echo "Installation cancelled."
      exit 0
    fi
    ;;
esac

# Cleanup
unset installDotfiles installNvimOnly installNvimDbeeOnly installNvimPostgresOnly installNvimAwsS3Only installNvimAwsSecretsOnly installBrewOnly installSketchybarOnly installGhosttyOnly installScriptsOnly installHammerspoonOnly installClaudeCommandsOnly installPromptOnly installSsmOnly installProcrastinateOnly installGitOnly installZshrcOnly