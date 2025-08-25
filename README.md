# 🏠 Matthew's Dotfiles

A comprehensive, modular dotfiles setup optimized for development productivity on macOS. This configuration includes everything from shell environments to development tools, with a focus on automation and ease of maintenance.

## ⚡ Quick Start

```bash
git clone https://github.com/matthewmyrick/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

That's it! The installer will handle everything automatically.

## 🚀 What's Included

### Core Components
- **🔧 [Modular Install System](install/README.md)** - Organized, maintainable installation scripts
- **⌨️ [Keyboard Configuration](keyboard/README.md)** - Karabiner-Elements setup for enhanced productivity
- **📝 [Neovim Configuration](nvim/README.md)** - Full-featured LazyVim setup with custom keybindings
- **📜 [Shell Scripts](scripts/README.md)** - Modular shell functions with lazy loading
- **📋 [Task Management](task/README.md)** - TaskWarrior hooks and configuration

### Terminal Applications
- **🖥️ [Ghostty Terminal](ghostty/README.md)** - Modern terminal emulator configuration
- **😸 [Kitty Terminal](kitty/README.md)** - Alternative terminal configuration

### Development Tools
- **Node.js & npm packages** - Latest versions with automatic updates
- **Python environment** - Virtual environments and development packages  
- **Go toolchain** - Latest Go with custom development tools
- **Rust environment** - Cargo and rust-analyzer setup
- **AI CLIs** - Claude Code and Gemini CLI integration
- **🧭 Zoxide** - Smart cd replacement with fuzzy directory jumping

## 🎯 Key Features

- **🔄 Automatic Updates** - Scripts handle version checking and updates
- **📦 Dependency Management** - Homebrew packages managed automatically
- **⚙️ macOS Optimization** - System settings tuned for development
- **🔍 Smart Discovery** - Dynamic script loading and execution
- **🛡️ Error Handling** - Robust error handling with detailed feedback
- **📚 Comprehensive Documentation** - Detailed docs for every component

## 📋 System Requirements

- macOS (tested on macOS Sonoma and newer)
- Admin privileges for some system modifications
- Internet connection for downloading dependencies

## 🔧 Installation Process

The installation is divided into logical phases:

1. **Dependencies** - Homebrew and core packages
2. **Dotfiles** - Configuration files and settings  
3. **SDKs** - Programming language environments
4. **CLIs** - Command line tools and utilities
5. **Development** - Custom development tools
6. **macOS** - System-specific configurations

## 📖 Detailed Documentation

Each component has its own comprehensive documentation:

| Component | Purpose | Documentation |
|-----------|---------|---------------|
| 🔧 Install System | Modular installation scripts | [install/README.md](install/README.md) |
| ⌨️ Keyboard | Karabiner key remapping | [keyboard/README.md](keyboard/README.md) |
| 📝 Neovim | Editor configuration | [nvim/README.md](nvim/README.md) |
| 📜 Scripts | Shell functions & utilities | [scripts/README.md](scripts/README.md) |
| 📋 Tasks | TaskWarrior setup | [task/README.md](task/README.md) |
| 🖥️ Ghostty | Terminal emulator | [ghostty/README.md](ghostty/README.md) |
| 😸 Kitty | Alternative terminal | [kitty/README.md](kitty/README.md) |

## 🛠️ Shell Module System

The shell configuration uses a modular, lazy-loading system for optimal performance:

### Available Modules
- **profiling/** - Performance monitoring and telemetry tools
- **git/** - Git utilities and GitHub integration  
- **navigation/** - File/directory finders and navigation
- **utilities/** - General utilities and terminal-specific features
- **network/** - API and network request tools
- **prompt/** - Custom prompt configuration

### Key Commands
```bash
# Module management
shell_modules    # List all available modules
shell_load all   # Force load all modules
shell_loaded     # Show currently loaded modules

# Navigation (lazy loaded)
ff               # Fuzzy find directories
ffn              # Fuzzy find and open in nvim
fch              # Fuzzy command history search

# Git (lazy loaded)
ghc <org>        # Clone GitHub repo interactively
ffgn             # Find and open GitHub repos
fpr              # Find and open your PRs

# Utilities (lazy loaded)
k_port 8080      # Kill process on port
brewf            # Interactive Homebrew UI

# Smart directory navigation (zoxide)
cd project       # Jump to any directory matching "project"
zi               # Interactive directory picker
```

### Performance
With lazy loading enabled:
- **Before**: ~300-500ms startup time
- **After**: ~50-100ms startup time  
- Functions load instantly on first use (<10ms per module)

## 🛠️ Customization

All configurations are designed to be easily customizable:

- **Scripts are modular** - Add new functionality by dropping scripts in appropriate directories
- **Settings are commented** - Each configuration file includes explanations
- **Override patterns** - Easy ways to override defaults without breaking updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## 🆘 Troubleshooting

Common issues and solutions:

- **Installation fails**: Check you have admin privileges and stable internet
- **Scripts don't work**: Ensure you've restarted your shell or sourced config files
- **Homebrew issues**: Run `brew doctor` to diagnose package manager issues
- **Permission errors**: Some scripts may need `sudo` access for system modifications

### Verify Installation
After installation, verify everything is set up correctly:
```bash
./scripts/verify_installation.sh
```

For detailed troubleshooting, see the individual component documentation linked above.