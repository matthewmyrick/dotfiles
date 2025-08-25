# ⌨️ Keyboard Configuration

Enhanced keyboard setup using Karabiner-Elements for improved productivity and ergonomics on macOS. This configuration transforms your typing experience with smart key remapping and shortcuts.

## 🎯 Overview

The keyboard configuration focuses on:
- **Productivity shortcuts** for common development tasks
- **Ergonomic improvements** to reduce strain
- **Consistency** across different applications
- **Muscle memory optimization** for faster workflows

## 📁 Structure

```
keyboard/
└── mac/
    └── karabiner/
        └── karabiner.json    # Karabiner-Elements configuration
```

## 🚀 Installation

The keyboard configuration is automatically installed via the main install script:

```bash
./install.sh
```

Or manually:

```bash
# Copy configuration
cp -R keyboard/mac/karabiner ~/.config/

# Reload Karabiner configuration
/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --reload-karabiner-config
```

## ⚙️ Configuration Details

### Karabiner-Elements Setup

**Location**: `~/.config/karabiner/karabiner.json`

The configuration includes:
- Complex modifications for enhanced functionality
- Application-specific rules
- Function key optimizations
- Modifier key improvements

### Key Features

1. **Smart Function Keys**
   - Context-aware F-key behavior
   - Application-specific overrides

2. **Enhanced Navigation**
   - Improved arrow key combinations
   - Better text selection shortcuts

3. **Developer Shortcuts**
   - Quick access to development tools
   - Terminal and editor optimizations

4. **System Integration**
   - macOS native shortcut enhancements
   - Spotlight and Mission Control improvements

## 🔧 System Keyboard Settings

In addition to Karabiner configuration, the installer sets optimal macOS keyboard settings:

### Key Repeat Settings
```bash
# Fastest key repeat rate (1 = fastest)
defaults write -g KeyRepeat -int 1

# Shortest delay before repeat starts (10 = shortest)
defaults write -g InitialKeyRepeat -int 10
```

### Benefits
- **Faster scrolling** in editors and browsers
- **Quicker navigation** through code and text
- **Improved efficiency** for repetitive tasks

## 🎮 Usage Examples

### Enhanced Text Navigation

**Before**: Slow, OS-default navigation
**After**: Blazing fast cursor movement with held arrow keys

### Quick Development Workflows

- **Fast scrolling** through long files
- **Rapid code navigation** with optimized key repeat
- **Efficient text selection** with improved shortcuts

### Application-Specific Enhancements

Different behaviors in:
- **Terminal applications** (iTerm, Ghostty)
- **Code editors** (Neovim, VS Code)
- **Browsers** and other applications

## 🔍 Troubleshooting

### Karabiner Not Loading Configuration

```bash
# Check if Karabiner-Elements is running
ps aux | grep karabiner

# Restart Karabiner-Elements
sudo launchctl stop org.pqrs.karabiner.karabiner_grabber
sudo launchctl start org.pqrs.karabiner.karabiner_grabber

# Reload configuration manually
/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --reload-karabiner-config
```

### Keyboard Settings Not Applied

```bash
# Verify settings were applied
defaults read -g KeyRepeat
defaults read -g InitialKeyRepeat

# Manually apply settings
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10

# Restart affected processes
killall SystemUIServer
killall Dock
```

### Permission Issues

```bash
# Grant necessary permissions to Karabiner-Elements
# Go to System Preferences > Security & Privacy > Input Monitoring
# Add Karabiner-Elements and related processes
```

## ⚡ Performance Impact

### Key Repeat Optimization
- **Default macOS**: ~250ms initial delay, ~33ms repeat
- **Optimized**: ~167ms initial delay, ~16ms repeat
- **Result**: ~3x faster navigation and scrolling

### Productivity Gains
- **Faster code navigation**: Navigate large files efficiently
- **Better editing flow**: Reduced friction in repetitive tasks
- **Enhanced muscle memory**: Consistent shortcuts across applications

## 🎨 Customization

### Modifying Key Repeat Speed

Adjust in `install/macos/keyboard.sh`:

```bash
# Faster (1 = fastest, 2 = very fast, etc.)
defaults write -g KeyRepeat -int 1

# Slower initial delay (lower = faster)
defaults write -g InitialKeyRepeat -int 10
```

### Adding Custom Karabiner Rules

1. **Open Karabiner-Elements app**
2. **Go to Complex Modifications tab**
3. **Add your custom rules**
4. **Export configuration** to update the dotfiles

### Application-Specific Shortcuts

Edit `keyboard/mac/karabiner/karabiner.json`:

```json
{
  "description": "Custom rule for specific app",
  "manipulators": [
    {
      "conditions": [
        {
          "bundle_identifiers": ["com.your.app"],
          "type": "frontmost_application_if"
        }
      ],
      "from": { "key_code": "your_key" },
      "to": [{ "key_code": "target_key" }],
      "type": "basic"
    }
  ]
}
```

## 🔄 Maintenance

### Backup Current Configuration

```bash
# Backup your current Karabiner config
cp ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.backup
```

### Update Configuration

```bash
# Pull latest dotfiles
git pull origin main

# Reinstall keyboard configuration
./install.sh
# Or manually:
cp -R keyboard/mac/karabiner ~/.config/
```

### Reset to Defaults

```bash
# Reset macOS keyboard settings to defaults
defaults delete -g KeyRepeat
defaults delete -g InitialKeyRepeat

# Reset Karabiner to defaults
rm -rf ~/.config/karabiner/
```

## 💡 Tips & Best Practices

### Adaptation Period
- **Week 1**: May feel fast initially
- **Week 2**: Muscle memory adaptation
- **Week 3+**: Significant productivity gains

### Fine-Tuning
- Start with provided settings
- Adjust `KeyRepeat` if too fast/slow
- Modify `InitialKeyRepeat` for initial delay preference

### Compatibility
- Works with all text editors
- Compatible with terminal applications
- Enhances browser navigation
- Improves system-wide text input

## 📊 Verification

### Test Key Repeat Settings
```bash
# Open any text editor and hold an arrow key
# Should see rapid, smooth movement

# Check current settings
defaults read -g KeyRepeat
defaults read -g InitialKeyRepeat
```

### Verify Karabiner is Active
- Check menubar for Karabiner-Elements icon
- Verify rules are loaded in Karabiner-Elements app
- Test custom shortcuts work as expected

This keyboard configuration dramatically improves the efficiency of text navigation, code editing, and general macOS usage through optimized key repeat rates and smart shortcuts.