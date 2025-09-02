# SketchyBar Configuration

A customizable macOS status bar replacement configuration.

## Prerequisites

1. **Install SketchyBar:**
   ```bash
   brew tap FelixKratz/formulae
   brew install sketchybar
   ```

2. **Install SF Pro Font** (recommended):
   - Download from Apple Developer Resources
   - Or use system default fonts by modifying `FONT` variable in `sketchybarrc`

## Setup

1. **Make the configuration executable:**
   ```bash
   chmod +x sketchybarrc
   chmod +x items/*.sh
   chmod +x plugins/*.sh
   ```

2. **Set the CONFIG_DIR environment variable:**
   Add this to your shell profile (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export CONFIG_DIR="$HOME/GitHub/matthewmyrick/dotfiles/sketchybar"
   ```

3. **Reload your shell:**
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

## Starting SketchyBar

1. **Start SketchyBar with your config:**
   ```bash
   sketchybar --config $CONFIG_DIR/sketchybarrc
   ```

2. **To start automatically on login:**
   ```bash
   brew services start sketchybar
   ```

3. **To restart SketchyBar:**
   ```bash
   sketchybar --reload
   ```

## Configuration Structure

```
sketchybar/
├── sketchybarrc        # Main configuration file
├── colors.sh          # Color definitions
├── icons.sh           # Icon definitions
├── items/             # Individual item configurations
│   ├── apple.sh
│   └── battery.sh
├── plugins/           # Plugin scripts
│   └── battery.sh
└── helper/            # Helper process (if needed)
```

## Customization

- **Colors**: Edit `colors.sh` to change the color scheme
- **Icons**: Modify `icons.sh` to use different SF Symbols
- **Items**: Add new items in the `items/` directory
- **Plugins**: Create scripts in `plugins/` directory for dynamic content

## Troubleshooting

- **Permission denied**: Make sure all scripts are executable
- **Command not found**: Ensure SketchyBar is installed and in PATH
- **Config not loading**: Verify CONFIG_DIR environment variable is set correctly
- **Items not showing**: Check that all required plugins exist and are executable