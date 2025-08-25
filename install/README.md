# 🔧 Install System Documentation

The modular install system provides a maintainable, organized approach to setting up the entire dotfiles environment. Each component is separated into logical categories for easy maintenance and customization.

## 📁 Directory Structure

```
install/
├── dependencies/     # Core system dependencies
│   ├── homebrew.sh           # Install/setup Homebrew package manager
│   ├── brew-packages.sh      # Install CLI tools and utilities
│   └── brew-casks.sh         # Install GUI applications
├── dotfiles/        # Configuration files and settings
│   ├── config-files.sh       # Copy basic dotfiles to home directory
│   ├── task-hooks.sh         # Setup TaskWarrior hooks
│   ├── karabiner.sh          # Configure keyboard remapping
│   └── scripts.sh            # Install shell scripts and utilities
├── sdks/           # Programming language environments
│   ├── python.sh             # Python virtual environment setup
│   ├── node.sh               # Node.js version management
│   ├── go.sh                 # Go environment configuration
│   └── rust.sh               # Rust toolchain setup
├── clis/           # Command line tools
│   ├── claude.sh             # Claude AI CLI installation
│   └── gemini.sh             # Google Gemini CLI setup
├── development/    # Custom development tools
│   └── custom-tools.sh       # Install personal development utilities
└── macos/         # macOS system configurations
    └── keyboard.sh           # System keyboard settings optimization
```

## 🚀 How It Works

### Main Install Script

The root `install.sh` script orchestrates the entire installation process:

1. **Discovery**: Automatically finds all `.sh` files in each category directory
2. **Execution Order**: Runs categories in a logical sequence:
   - `dependencies` → `dotfiles` → `sdks` → `clis` → `development` → `macos`
3. **Error Handling**: Each script can fail independently without breaking the entire process
4. **Progress Feedback**: Clear visual indicators show installation progress

### Execution Flow

```bash
./install.sh
├── dependencies/
│   ├── homebrew.sh          # Install package manager
│   ├── brew-packages.sh     # Install core CLI tools
│   └── brew-casks.sh        # Install GUI applications
├── dotfiles/
│   ├── config-files.sh      # Copy configuration files
│   ├── task-hooks.sh        # Setup task management
│   ├── karabiner.sh         # Configure keyboard
│   └── scripts.sh           # Install shell utilities
├── sdks/
│   ├── python.sh            # Setup Python environment
│   ├── node.sh              # Configure Node.js
│   ├── go.sh                # Setup Go toolchain
│   └── rust.sh              # Configure Rust environment
├── clis/
│   ├── claude.sh            # Install AI CLI tools
│   └── gemini.sh            # Install Google CLI tools
├── development/
│   └── custom-tools.sh      # Install personal tools
└── macos/
    └── keyboard.sh          # Optimize system settings
```

## 📋 Installation Categories

### 1. Dependencies
**Purpose**: Install core system dependencies and package managers

- **Homebrew**: Package manager installation and setup
- **Brew Packages**: Essential CLI tools (git, fzf, ripgrep, etc.)
- **Brew Casks**: GUI applications (Ghostty, Karabiner, etc.)

### 2. Dotfiles
**Purpose**: Deploy configuration files and custom settings

- **Config Files**: Shell configs, terminal configs, editor settings
- **Task Hooks**: TaskWarrior automation and hooks
- **Karabiner**: Keyboard remapping configuration
- **Scripts**: Shell functions and utility scripts

### 3. SDKs
**Purpose**: Setup programming language environments

- **Python**: Virtual environments, packages for development
- **Node.js**: Version management and global packages
- **Go**: Toolchain setup and environment configuration
- **Rust**: Compiler and development tools

### 4. CLIs
**Purpose**: Install command-line interface tools

- **Claude**: Anthropic's AI assistant CLI
- **Gemini**: Google's AI CLI tools
- **Version Management**: Automatic updates and conflict resolution

### 5. Development
**Purpose**: Install custom development utilities

- **Personal Tools**: Custom Rust and Go applications
- **GitHub Tools**: Repository management utilities
- **Build Tools**: Development workflow automation

### 6. macOS
**Purpose**: Optimize macOS system settings

- **Keyboard Settings**: Fast key repeat for better navigation
- **System Preferences**: Development-optimized configurations

## 🔧 Adding New Components

### Adding a New Script

1. **Choose Category**: Decide which directory fits your new component
2. **Create Script**: Add a new `.sh` file in the appropriate directory
3. **Make Executable**: Run `chmod +x your-script.sh`
4. **Test**: Run `./install.sh` to test the new component

### Example New Script

```bash
# install/development/my-tool.sh
#!/bin/bash

echo "🛠️ Installing My Custom Tool..."

if ! command -v my-tool &>/dev/null; then
  echo "  Installing my-tool..."
  # Installation commands here
  echo "  ✓ my-tool installed successfully"
else
  echo "  ✓ my-tool already installed"
fi

echo "✓ My Custom Tool ready."
```

### Script Guidelines

- **Echo Progress**: Always show what's happening
- **Check Existence**: Verify if tools are already installed
- **Handle Errors**: Use `|| true` for non-critical commands
- **Consistent Format**: Follow the established pattern
- **Exit Codes**: Return appropriate codes for success/failure

## 🔍 Troubleshooting

### Common Issues

**Scripts don't run**:
```bash
# Make scripts executable
chmod +x install/category/*.sh
```

**Homebrew not found**:
```bash
# Check if Homebrew is in PATH
echo $PATH
# Manually source Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Permission errors**:
```bash
# Some scripts need sudo for system modifications
# Check script output for specific requirements
```

### Debugging

**Verbose output**:
```bash
# Run with debug output
bash -x ./install.sh
```

**Individual script testing**:
```bash
# Test specific category
bash install/dependencies/homebrew.sh
```

**Check script execution order**:
```bash
# See what scripts will run
find install/ -name "*.sh" -type f | sort
```

## 🎯 Customization

### Override Installation Order

Modify the `INSTALL_ORDER` array in `install.sh`:

```bash
local INSTALL_ORDER=(
  "dependencies"
  "my-custom-category"  # Add your category
  "dotfiles"
  # ... rest of categories
)
```

### Skip Categories

Comment out categories in the main script:

```bash
local INSTALL_ORDER=(
  "dependencies"
  "dotfiles"
  # "sdks"              # Skip SDKs installation
  "clis"
  "development"
  "macos"
)
```

### Environment-Specific Scripts

Create environment-specific versions:

```bash
install/
├── dependencies/
│   ├── homebrew.sh
│   ├── homebrew-work.sh    # Work environment specific
│   └── homebrew-home.sh    # Personal environment specific
```

## 📊 Installation Analytics

The installer provides detailed feedback:

- **Progress Indicators**: Visual progress for each phase
- **Success/Failure Tracking**: Clear indicators for each component  
- **Execution Time**: Duration tracking for optimization
- **Dependency Verification**: Confirms successful installations

## 🔄 Maintenance

### Updating Scripts

1. **Pull Latest**: `git pull origin main`
2. **Review Changes**: Check updated scripts
3. **Test**: Run on non-production environment first
4. **Deploy**: Run `./install.sh` to apply updates

### Adding Dependencies

When adding new Homebrew packages:

1. Add to appropriate array in `brew-packages.sh` or `brew-casks.sh`
2. Test installation
3. Update documentation

The modular system makes maintenance straightforward - each component is isolated and can be updated independently.