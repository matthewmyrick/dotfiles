# 😸 Kitty Terminal Configuration

Alternative terminal emulator configuration providing a fast, feature-rich terminal experience with GPU acceleration and extensive customization options. Kitty serves as a backup option or alternative to Ghostty for users who prefer different terminal features.

## 🎯 Overview

Kitty offers:
- **⚡ GPU acceleration** for smooth rendering and performance
- **🔧 Extensive customization** with powerful configuration options
- **📱 Modern features** like tabs, splits, and image support
- **🎨 Rich theming** with full color support
- **🔌 Extensibility** through plugins and scripting

## 📁 Structure

```
kitty/
└── kitty.conf         # Main Kitty configuration file
```

## 🚀 Installation

The Kitty configuration is automatically installed via the main install script:

```bash
./install.sh
```

Or manually:

```bash
# Copy configuration to user config directory
cp -R kitty ~/.config/

# Verify installation (if Kitty is installed)
kitty --version
```

**Note**: Kitty installation is commented out in the main installer but the configuration is preserved for optional use.

## ⚙️ Configuration Highlights

### Font Configuration
```conf
# Font settings optimized for development
font_family      JetBrains Mono
font_size        14.0
bold_font        auto
italic_font      auto
bold_italic_font auto
```

### Color Scheme
```conf
# Dark theme optimized for coding
foreground #f8f8f2
background #282a36
selection_foreground #ffffff
selection_background #44475a

# Cursor styling
cursor #f8f8f2
cursor_text_color #282a36
```

### Performance Settings
```conf
# GPU acceleration and performance
repaint_delay 10
input_delay 3
sync_to_monitor yes
```

### Window & Layout
```conf
# Window appearance
window_padding_width 8
hide_window_decorations titlebar-only
tab_bar_edge bottom
tab_bar_style powerline
```

### Key Bindings
```conf
# Custom key bindings for productivity
map cmd+t new_tab
map cmd+w close_tab
map cmd+1 goto_tab 1
map cmd+2 goto_tab 2
# ... additional bindings
```

## 🎮 Key Features

### Multi-Tab Support
- Create new tabs with `Cmd+T`
- Switch between tabs with `Cmd+1-9`
- Close tabs with `Cmd+W`
- Tab titles update automatically based on running commands

### Split Windows
- Horizontal splits for side-by-side terminals
- Vertical splits for stacked layouts
- Easy navigation between splits
- Resize splits dynamically

### Image Support
- Display images directly in terminal
- Support for various image formats
- Useful for viewing screenshots, diagrams, and graphics in development workflows

## 🔧 Usage Scenarios

### When to Use Kitty Over Ghostty

1. **Split Windows**: If you need advanced window splitting
2. **Image Display**: For workflows requiring inline image viewing
3. **Legacy Compatibility**: Better compatibility with older systems
4. **Plugin Ecosystem**: Access to Kitty's plugin system
5. **Specific Features**: Features not available in Ghostty

### Development Workflow
```bash
# Multi-window development session
# Terminal 1: Main development
cd ~/projects/my-app && nvim

# Terminal 2 (split): Server logs  
npm run dev

# Terminal 3 (tab): Git operations
git status
```

## 🎨 Customization

### Alternative Color Schemes
The configuration can be easily modified for different themes:

```conf
# Light theme variant
foreground #4d4d4c
background #fafafa

# High contrast theme
foreground #ffffff
background #000000
```

### Font Adjustments
```conf
# Larger fonts for accessibility
font_size 16.0

# Alternative programming fonts
font_family Source Code Pro
font_family Fira Code  # Supports ligatures
```

## 🔍 Comparison with Ghostty

| Feature | Kitty | Ghostty | Winner |
|---------|-------|---------|---------|
| **Performance** | Fast | Faster | Ghostty |
| **Memory Usage** | Moderate | Lower | Ghostty |
| **Split Windows** | Excellent | Basic | Kitty |
| **Image Support** | Yes | Limited | Kitty |
| **Startup Time** | Good | Better | Ghostty |
| **Configuration** | Complex | Simpler | Depends |
| **Ecosystem** | Mature | Growing | Kitty |

## 🔧 Maintenance

### Updating Configuration
```bash
# Update from dotfiles
./install.sh

# Test configuration
kitty --check-config
```

### Installation (Optional)
If you want to install Kitty:

```bash
# Install via Homebrew
brew install --cask kitty

# Or uncomment in install script
# Edit install/dependencies/brew-casks.sh
# Uncomment: kitty
```

## 💡 Tips

### Quick Setup
1. The configuration is maintained for compatibility
2. Ghostty is the primary terminal in this dotfiles setup
3. Kitty config serves as a fallback or alternative option
4. Both terminals can coexist on the same system

### Migration from Kitty to Ghostty
If migrating from Kitty to Ghostty:
1. Most key bindings translate directly
2. Color schemes are compatible
3. Font settings work the same way
4. Split windows may need different workflow in Ghostty

This Kitty configuration provides a solid alternative terminal experience while the primary focus remains on Ghostty for optimal performance and modern terminal features.