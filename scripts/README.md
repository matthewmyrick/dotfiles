# 📜 Shell Scripts Documentation

A modular, high-performance shell function system with lazy loading that dramatically improves shell startup time while providing powerful development utilities. This system organizes functions by category and loads them on-demand for optimal performance.

## 🎯 Overview

The shell script system provides:
- **⚡ 80-90% faster shell startup** through lazy loading
- **📦 Modular organization** with functions grouped by purpose
- **🎛️ Smart loading** based on terminal capabilities and environment
- **🔧 Easy management** with built-in commands for inspection and control
- **🚀 Instant access** to powerful development utilities

## 📁 Structure

```
scripts/
├── python/                  # Python utilities
│   └── telemetry.py            # Performance telemetry formatter
├── shell/                   # Modular shell functions
│   ├── README.md               # Shell system documentation
│   ├── loader.sh               # Core loading system
│   ├── git/                    # Git and GitHub utilities
│   │   └── functions.sh            # Git workflow functions
│   ├── navigation/             # File and directory navigation
│   │   └── finders.sh              # Fuzzy finding utilities
│   ├── network/               # Network and API tools
│   │   ├── api.sh                  # API interaction utilities
│   │   └── processes.sh            # Process management
│   ├── profiling/             # Performance monitoring
│   │   ├── telemetry.sh            # Shell performance tracking
│   │   └── zprof.sh                # Zsh profiling utilities
│   ├── prompt/                # Prompt customization
│   │   └── config.sh               # Prompt configuration
│   ├── telemetry/             # Telemetry and logging
│   │   ├── gotime.sh               # Go build time tracking
│   │   └── shell.sh                # Shell usage analytics
│   └── utilities/             # General utilities
│       ├── general.sh              # Miscellaneous utilities
│       └── terminal-tabs.sh        # Terminal tab management
└── verify_installation.sh   # Installation verification script
```

## 🚀 Installation & Setup

The scripts are automatically installed via the main install script:

```bash
./install.sh
```

This installs the modular system to `~/GitHub/matthewmyrick/dotfiles/scripts/shell/` and configures your shell to use lazy loading.

### Manual Installation

```bash
# Create destination directory
mkdir -p ~/GitHub/matthewmyrick/dotfiles

# Copy scripts directory
cp -R scripts ~/GitHub/matthewmyrick/dotfiles/

# Source the loader in your shell config
echo 'source ~/GitHub/matthewmyrick/dotfiles/scripts/shell/loader.sh' >> ~/.zshrc
```

## ⚡ Performance Benefits

### Startup Time Comparison
```bash
# Before (traditional loading)
time zsh -i -c exit  # ~300-500ms

# After (lazy loading)
time zsh -i -c exit  # ~50-100ms

# Function loading time
time ff              # <10ms on first use
```

### Lazy Loading System
- **Initial startup**: Only core loader (~5KB) is sourced
- **On-demand loading**: Functions load when first accessed
- **Smart caching**: Once loaded, functions remain in memory
- **Conditional loading**: Terminal-specific features load only when appropriate

## 🔧 Core Management Commands

### Module Discovery
```bash
shell_modules        # List all available modules and their functions
shell_loaded         # Show currently loaded modules
shell_load all       # Force load all modules immediately
shell_load git       # Load specific module
```

### Performance Monitoring
```bash
shell_startup_time   # Measure current shell startup time
shell_profile        # Profile shell performance
```

## 📦 Module Categories

### 🔍 Navigation (`navigation/finders.sh`)
Powerful fuzzy finding and navigation utilities:

```bash
# Directory navigation
ff                   # Fuzzy find directories with fzf
ff_nvim             # Fuzzy find and open in Neovim
ffn                 # Alias for ff_nvim

# File operations
fch                 # Fuzzy search command history
find_large_files    # Find files larger than specified size
```

**Features:**
- **fzf integration** for lightning-fast searching
- **Smart previews** with syntax highlighting
- **Multi-selection** for batch operations
- **Context-aware** behavior based on current directory

### 🐙 Git/GitHub (`git/functions.sh`)
Comprehensive Git workflow automation:

```bash
# GitHub repository management
ghc <organization>   # Interactive GitHub repository cloning
ffgn                 # Find and open GitHub repositories in Neovim
fpr                  # Find and open your GitHub pull requests

# Git workflow utilities
git_cleanup_branches # Remove merged branches
git_sync_fork       # Sync forked repository with upstream
quick_commit        # Smart commit with conventional messages
```

**Features:**
- **GitHub CLI integration** for seamless repository operations
- **Interactive selection** for repositories and pull requests
- **Smart defaults** based on current repository context
- **Conventional commit** support for better commit history

### 🌐 Network (`network/`)
API interaction and network utilities:

#### API Tools (`network/api.sh`)
```bash
# HTTP utilities
curlj <url>         # curl with JSON pretty-printing
api_test <endpoint> # Test API endpoint with common methods
http_status <url>   # Get HTTP status code
```

#### Process Management (`network/processes.sh`)
```bash
# Port management
k_port 8080         # Kill process running on specified port
find_port <process> # Find port used by process
list_open_ports     # List all open ports
```

**Features:**
- **JSON formatting** with syntax highlighting
- **Smart error handling** with detailed feedback
- **Port conflict resolution** for development servers
- **Process identification** by port or name

### 🍺 Utilities (`utilities/`)
General-purpose development utilities:

#### General Utilities (`utilities/general.sh`)
```bash
# Package management
brewf               # Interactive Homebrew package finder
pip_upgrade_all     # Upgrade all pip packages
npm_check_updates   # Check for npm package updates

# System utilities
disk_usage         # Show disk usage by directory
memory_usage       # Show memory usage by process
clean_downloads    # Clean up Downloads folder
```

#### Terminal Management (`utilities/terminal-tabs.sh`)
```bash
# Terminal workspace management
new_tab_with_cmd   # Open new terminal tab with command
split_terminal     # Smart terminal splitting
save_session       # Save current terminal session
restore_session    # Restore saved terminal session
```

**Features:**
- **Homebrew integration** with fuzzy search interface
- **Package manager utilities** for multiple ecosystems
- **System monitoring** with human-readable output
- **Session management** for complex development environments

### 📊 Profiling (`profiling/`)
Performance monitoring and optimization tools:

#### Shell Telemetry (`profiling/telemetry.sh`)
```bash
# Performance monitoring
shell_benchmark     # Benchmark shell operations
function_timing     # Time function execution
startup_analysis    # Analyze shell startup performance
```

#### Zsh Profiling (`profiling/zprof.sh`)
```bash
# Zsh-specific profiling
zprof_start        # Start Zsh profiling
zprof_stop         # Stop and display Zsh profile
zprof_reset        # Reset profiling data
```

### 🎨 Prompt (`prompt/config.sh`)
Advanced prompt customization:

```bash
# Prompt management
prompt_minimal     # Switch to minimal prompt
prompt_full        # Switch to full-featured prompt
prompt_git_info    # Show detailed git information in prompt
```

### 📈 Telemetry (`telemetry/`)
Development workflow analytics:

#### Go Development (`telemetry/gotime.sh`)
```bash
# Go build time tracking
go_build_time     # Time Go build operations
go_test_time      # Time Go test execution
go_benchmark      # Run and time Go benchmarks
```

#### Shell Analytics (`telemetry/shell.sh`)
```bash
# Usage analytics (opt-in)
enable_telemetry  # Enable shell usage tracking
disable_telemetry # Disable shell usage tracking
telemetry_report  # Generate usage report
```

## 🔍 Python Integration (`python/telemetry.py`)

Advanced telemetry formatting with Python:

```bash
# Telemetry with rich formatting
python_telemetry  # Format telemetry data with rich output
telemetry_json    # Export telemetry as JSON
telemetry_graph   # Generate telemetry graphs
```

**Features:**
- **Rich text formatting** with colors and tables
- **JSON export** for integration with other tools
- **Visual graphs** for performance trends
- **Configurable output** formats

## 🎛️ Configuration & Customization

### Environment Variables
```bash
# Performance settings
export SHELL_LAZY_LOADING=true    # Enable lazy loading (default: true)
export SHELL_PROFILING=false      # Enable function profiling
export SHELL_TELEMETRY=false      # Enable usage telemetry

# Feature toggles
export ENABLE_GIT_FUNCTIONS=true  # Load git utilities
export ENABLE_HOMEBREW_UTILS=true # Load Homebrew utilities
export ENABLE_PYTHON_TOOLS=true   # Load Python integration
```

### Custom Functions
Add your own functions by creating new files in the appropriate category:

```bash
# Create custom navigation function
cat > ~/GitHub/matthewmyrick/dotfiles/scripts/shell/navigation/custom.sh << 'EOF'
# Custom navigation function
my_custom_find() {
  find . -name "*$1*" -type f | head -20
}
EOF

# Reload shell to access new function
exec zsh
```

### Module-Specific Configuration
Each module can have its own configuration:

```bash
# Git module configuration
export GIT_DEFAULT_BRANCH=main
export GITHUB_DEFAULT_ORG=myorg

# Navigation module configuration  
export FZF_DEFAULT_OPTS="--height 40% --reverse"
export EDITOR=nvim
```

## 🔧 Advanced Usage

### Conditional Loading
Functions can be loaded based on environment:

```bash
# Only load Docker functions if Docker is installed
if command -v docker &> /dev/null; then
  shell_load docker
fi

# Load work-specific functions only in work directories
if [[ $PWD == /work/* ]]; then
  shell_load work_utils
fi
```

### Performance Optimization
Fine-tune loading behavior:

```bash
# Preload frequently used modules
shell_load navigation git utilities

# Defer loading of heavy modules
shell_defer_load network telemetry
```

### Integration with Other Tools
```bash
# Integrate with existing aliases
alias vim='ffn'  # Use fuzzy finding for vim
alias cd='ff'    # Use fuzzy finding for cd

# Chain with other functions
ghc_and_open() {
  ghc "$1" && ffn
}
```

## 🔍 Troubleshooting

### Functions Not Loading
```bash
# Check module status
shell_loaded

# Force reload specific module
unset -f problematic_function
shell_load module_name

# Debug loading issues
SHELL_DEBUG=true shell_load all
```

### Performance Issues
```bash
# Profile shell startup
shell_startup_time

# Find slow functions
shell_profile

# Check for conflicts
which function_name
type function_name
```

### Module Conflicts
```bash
# List all loaded functions
typeset -f | grep '^[a-zA-Z]'

# Unload specific module
shell_unload module_name

# Reset all modules
shell_reset
```

## 📊 Verification & Testing

### Installation Verification
```bash
# Run comprehensive verification
./scripts/verify_installation.sh

# Test specific modules
shell_test navigation
shell_test git
```

### Performance Testing
```bash
# Benchmark current configuration
shell_benchmark

# Compare with traditional loading
SHELL_LAZY_LOADING=false shell_benchmark
```

### Function Testing
```bash
# Test all functions in a module
for func in $(shell_list_functions navigation); do
  echo "Testing $func"
  type "$func" > /dev/null || echo "FAILED: $func"
done
```

## 💡 Best Practices

### Function Development
- **Keep functions focused** on a single responsibility
- **Use descriptive names** that indicate purpose
- **Include help text** with usage examples
- **Handle errors gracefully** with meaningful messages
- **Test in multiple environments** before committing

### Performance Considerations
- **Lazy load by default** unless function is used frequently
- **Minimize external dependencies** in core functions  
- **Cache expensive operations** when possible
- **Profile regularly** to identify bottlenecks
- **Use built-in utilities** over external tools when equivalent

### Module Organization
- **Group related functions** in the same module
- **Use consistent naming** within modules
- **Document dependencies** between functions
- **Provide module-level configuration** options
- **Include examples** for complex functions

This modular shell system transforms your command-line experience, providing powerful utilities while maintaining exceptional performance through intelligent lazy loading.