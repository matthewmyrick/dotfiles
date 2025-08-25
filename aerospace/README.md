# ✈️ AeroSpace Window Manager Configuration

Modern tiling window manager for macOS that brings the power of tiling window management to the Mac ecosystem. AeroSpace provides keyboard-driven window management with workspaces, automatic tiling, and extensive customization.

## 🎯 Overview

AeroSpace offers:
- **🎹 Keyboard-driven workflow** with Vim-style navigation
- **📱 Multiple workspaces** for organized window management  
- **⚙️ Automatic tiling** with intelligent layout algorithms
- **🎨 Customizable layouts** including tiles and accordion modes
- **🔧 Application-specific rules** for optimal window behavior
- **🚀 Native macOS integration** without system modifications

## 📁 Structure

```
aerospace/
├── aerospace.toml     # Main AeroSpace configuration
└── README.md          # This documentation
```

## 🚀 Installation

AeroSpace is automatically installed via the main install script:

```bash
./install.sh
```

The installation process:
1. **Installs AeroSpace** via Homebrew cask (`nikitabobko/tap/aerospace`)
2. **Copies configuration** to `~/.config/aerospace/aerospace.toml`
3. **Starts AeroSpace** automatically
4. **Reloads configuration** to apply settings

### Manual Installation

```bash
# Install AeroSpace
brew install --cask nikitabobko/tap/aerospace

# Copy configuration
cp aerospace/aerospace.toml ~/.config/aerospace/

# Start AeroSpace
open -a AeroSpace
```

## ⌨️ Key Bindings

### 🧭 Window Navigation
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+H` | Focus left | Move focus to window on the left |
| `Alt+J` | Focus down | Move focus to window below |
| `Alt+K` | Focus up | Move focus to window above |
| `Alt+L` | Focus right | Move focus to window on the right |

### 📦 Window Movement
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+Shift+H` | Move left | Move window to the left |
| `Alt+Shift+J` | Move down | Move window down |
| `Alt+Shift+K` | Move up | Move window up |
| `Alt+Shift+L` | Move right | Move window to the right |

### 🏠 Workspace Management
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+1-9` | Switch workspace | Go to workspace 1-9 |
| `Alt+0` | Switch to workspace 10 | Go to workspace 10 |
| `Alt+Shift+1-9` | Move to workspace | Move current window to workspace 1-9 |
| `Alt+Shift+0` | Move to workspace 10 | Move current window to workspace 10 |

### 📐 Layout Management
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+/` | Toggle tiles layout | Switch between horizontal/vertical tiles |
| `Alt+,` | Toggle accordion | Switch to accordion layout |
| `Alt+Shift+Space` | Toggle floating | Float/unfloat current window |
| `Alt+F` | Toggle fullscreen | Make window fullscreen |

### 📏 Window Resizing
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+Shift+-` | Shrink window | Make window smaller |
| `Alt+Shift+=` | Grow window | Make window larger |

### 🔧 System Commands
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Alt+;` | Service mode | Enter advanced operations mode |
| `Alt+Shift+C` | Reload config | Reload AeroSpace configuration |
| `Alt+Shift+R` | Reset layout | Flatten workspace tree |

### 🛠️ Service Mode (Alt+;)
| Shortcut | Action | Description |
|----------|---------|-------------|
| `Esc` | Exit service mode | Return to main mode |
| `R` | Reset layout | Flatten workspace and return to main |
| `F` | Toggle floating | Float/unfloat and return to main |
| `Backspace` | Close others | Close all windows except current |
| `Alt+Shift+H/J/K/L` | Join windows | Join with adjacent window |

## 🎨 Configuration Details

### Layout Settings
```toml
# Global appearance
accordion-padding = 30
default-root-container-layout = 'tiles'
default-root-container-orientation = 'auto'

# Window gaps for visual separation
[gaps]
inner.horizontal = 8
inner.vertical =   8
outer.left =       8
outer.bottom =     8
outer.top =        8
outer.right =      8
```

### Workspace Organization
```toml
# Multi-monitor workspace assignment
[workspace-to-monitor-force-assignment]
1 = 'main'      # Primary monitor: Development
2 = 'main'      # Primary monitor: Web browsing  
3 = 'main'      # Primary monitor: Communication
4 = 'main'      # Primary monitor: General tasks
5 = 'secondary' # Secondary monitor workspaces
6 = 'secondary'
7 = 'secondary'
8 = 'secondary'
9 = 'secondary'
```

### Application Rules
The configuration includes smart defaults for common applications:

#### Floating Windows (Always float)
- **System Preferences** - Better as floating dialogs
- **Calculator** - Small utility, better floating
- **Finder** - File dialogs work better floating
- **Activity Monitor** - Monitoring tool, better floating

#### Tiling Windows (Always tile)
- **Development tools** (VS Code, terminals, etc.)
- **Web browsers** (Chrome, Safari, Firefox)
- **Text editors** - Better in tiled layouts

#### Custom Rules Example
```toml
[[on-window-detected]]
if.app-id = 'com.microsoft.VSCode'
run = 'layout tiling'

[[on-window-detected]]  
if.app-id = 'com.apple.calculator'
run = 'layout floating'
```

## 🏗️ Workspace Workflow Examples

### Development Setup
```
Workspace 1: Code Editor (VS Code, Neovim)
Workspace 2: Terminal (Ghostty, iTerm)  
Workspace 3: Browser (Documentation, Stack Overflow)
Workspace 4: Communication (Slack, Email)
```

### Multi-Monitor Setup
```
Main Monitor:
- Workspace 1-4: Primary development tasks

Secondary Monitor:  
- Workspace 5: Monitoring (Activity Monitor, logs)
- Workspace 6: Reference (Documentation)
- Workspace 7: Communication
- Workspace 8-9: Scratch workspaces
```

## 🎮 Usage Scenarios

### Daily Development Workflow
1. **Start development session**:
   ```
   Alt+1          # Go to code workspace
   Alt+2          # Go to terminal workspace  
   Alt+3          # Go to browser workspace
   ```

2. **Organize windows**:
   ```
   Alt+Shift+H/L  # Move windows side by side
   Alt+/          # Toggle horizontal/vertical layout
   Alt+Shift+=/-  # Resize as needed
   ```

3. **Move between contexts**:
   ```
   Alt+4          # Switch to communication
   Alt+Shift+1    # Move important window to main workspace
   ```

### Window Management
```bash
# Quick window operations
Alt+F             # Make current window fullscreen for focus
Alt+Shift+Space   # Float a window temporarily
Alt+;, F          # Service mode: float and return to main mode
Alt+Shift+R       # Reset layout if things get messy
```

## 🔧 Customization

### Adding Custom Keybindings
Edit `aerospace.toml` in the `[mode.main.binding]` section:

```toml
[mode.main.binding]
# Custom application launchers
alt-return = 'exec-and-forget open -a "Ghostty"'
alt-shift-return = 'exec-and-forget open -a "Finder"'

# Custom window operations
alt-shift-q = 'close'
alt-m = 'layout accordion horizontal'
```

### Workspace Customization
```toml
# Add more workspaces
alt-grave = 'workspace 0'  # Backtick for workspace 0
alt-shift-grave = 'move-node-to-workspace 0'

# Named workspaces (AeroSpace 0.15+)
alt-d = 'workspace D'  # Development workspace
alt-w = 'workspace W'  # Web workspace
```

### Application-Specific Rules
```toml
# Make specific apps always open in certain workspaces
[[on-window-detected]]
if.app-id = 'com.microsoft.VSCode'
run = ['move-node-to-workspace 1', 'layout tiling']

[[on-window-detected]]
if.app-id = 'com.google.Chrome'
run = 'move-node-to-workspace 2'
```

### Layout Customization
```toml
# Adjust gaps
[gaps]
inner.horizontal = 12  # Larger gaps
inner.vertical =   12
outer.left =       12
outer.bottom =     12  
outer.top =        12
outer.right =      12

# Change default layout
default-root-container-layout = 'accordion'  # Start with accordion
accordion-padding = 50  # More padding in accordion mode
```

## 🔍 Troubleshooting

### AeroSpace Not Starting
```bash
# Check if AeroSpace is installed
which aerospace
ls -la /Applications/AeroSpace.app

# Start manually
open -a AeroSpace

# Check logs
log show --last 1h --predicate 'process == "AeroSpace"'
```

### Configuration Not Loading
```bash
# Check config file location
ls -la ~/.config/aerospace/aerospace.toml

# Validate configuration
aerospace --config-path ~/.config/aerospace/aerospace.toml --dry-run

# Reload configuration
Alt+Shift+C  # or
aerospace reload-config
```

### Key Bindings Not Working
```bash
# Check for conflicts with system shortcuts
# Go to System Preferences > Keyboard > Shortcuts
# Disable conflicting Mission Control shortcuts

# Check AeroSpace is receiving key events
# System Preferences > Security & Privacy > Accessibility
# Ensure AeroSpace has accessibility permissions
```

### Window Rules Not Applying
```bash
# Find app bundle identifier
osascript -e 'id of app "Application Name"'

# Check current window info
aerospace list-windows

# Test rule temporarily
aerospace move-node-to-workspace 1
```

## 📊 Performance & System Impact

### Resource Usage
- **Memory**: ~10-20MB typical usage
- **CPU**: <1% during normal operation
- **Battery**: Minimal impact on battery life
- **System**: No system modifications required

### Compatibility
- **macOS**: Requires macOS 13.0+
- **Applications**: Compatible with all macOS applications
- **System Integrity**: No system modifications, easily reversible

## 💡 Tips & Best Practices

### Getting Started
1. **Start simple**: Use basic navigation (Alt+H/J/K/L) first
2. **Learn workspaces**: Master Alt+1-9 workspace switching  
3. **Practice layouts**: Try Alt+/ and Alt+, for different layouts
4. **Use service mode**: Alt+; for advanced operations

### Productivity Tips
1. **Consistent workspace usage**: Always put similar apps in same workspaces
2. **Use floating sparingly**: Most productivity apps work better tiled
3. **Learn resizing**: Alt+Shift+=/- for quick size adjustments
4. **Reset when stuck**: Alt+Shift+R to reset messy layouts

### Advanced Usage
1. **Multi-monitor**: Use workspaces 5-9 for secondary monitor
2. **Service mode**: Quick window operations without leaving keyboard
3. **Application rules**: Automate window placement for consistent setup
4. **Custom shortcuts**: Add application launchers for common apps

## 📚 Additional Resources

- **Official Documentation**: https://github.com/nikitabobko/AeroSpace
- **Configuration Reference**: https://nikitabobko.github.io/AeroSpace/config-reference
- **Community Discussions**: https://github.com/nikitabobko/AeroSpace/discussions
- **Issue Tracking**: https://github.com/nikitabobko/AeroSpace/issues

AeroSpace transforms macOS into a keyboard-driven powerhouse, making window management effortless and dramatically improving development productivity through organized, distraction-free workspaces.