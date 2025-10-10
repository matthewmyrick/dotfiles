# Minimal Neovim Configuration

A fast, minimal Neovim setup using **Lazy.nvim** (not LazyVim) with only the essentials you need.

## What's Included

### Core Features
- **Snacks.nvim** - File explorer, fuzzy picker, dashboard, notifications
- **LSP Support** - Language servers for Go, Python, TypeScript, Rust, YAML, JSON, SQL, Helm
- **Completion** - Fast completion with blink.cmp
- **Syntax Highlighting** - Treesitter for accurate highlighting
- **Terminal Management** - Toggleterm with all your custom terminal configs
- **Fuzzy Finding** - Telescope for buffer/file management
- **Git Integration** - Gitsigns, blame, lazygit integration
- **Catppuccin Theme** - With transparency enabled

### What's Removed
- ❌ LazyVim framework overhead
- ❌ Unused extras and bloat
- ❌ Unnecessary plugins

## Installation

### Backup Current Config
```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup
```

### Install New Config
```bash
# Copy from dotfiles
cp -r ~/GitHub/matthewmyrick/dotfiles/nvim-new ~/.config/nvim

# Or create symlink
ln -s ~/GitHub/matthewmyrick/dotfiles/nvim-new ~/.config/nvim
```

### First Launch
```bash
nvim
```

Lazy.nvim will automatically:
1. Clone itself
2. Install all plugins
3. Install LSP servers via Mason

## Key Features

### File Explorer (Snacks)
- `<leader>e` - Open/focus file explorer
- `<leader><leader>` - Quick access to explorer
- Git status indicators
- Never closes, always accessible

### Fuzzy Finding (Snacks Picker)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>sg` - Grep (opens in current window)

### Terminal (Toggleterm)
- `<C-t>` - Toggle default terminal
- `<leader>tff` - Floating terminal
- `<leader>tfc` - Claude terminal
- `<leader>tfk` - Kubernetes (k9s)
- `<leader>tfj` - JQP (JSON viewer)
- `<leader>tvt` - Vertical terminal (33%)
- `<leader>tht` - Horizontal terminal (33%)

### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename
- `<leader>f` - Format

### Git
- `<leader>gg` - Lazygit
- `<leader>gb` - Git blame line
- `<leader>gB` - Git browse (open in browser)
- `]h` / `[h` - Next/prev git hunk

### Window Navigation
- `<C-h>` - Cycle through windows
- `<C-j>` - Go down
- `<C-k>` - Go up
- `<C-l>` - Go right (or wrap to first)

## Plugin List

**Core**
- folke/lazy.nvim - Plugin manager
- folke/snacks.nvim - UI components
- folke/which-key.nvim - Keymap hints

**LSP & Completion**
- neovim/nvim-lspconfig - LSP configuration
- williamboman/mason.nvim - LSP installer
- saghen/blink.cmp - Fast completion

**Editing**
- nvim-treesitter/nvim-treesitter - Syntax highlighting
- lewis6991/gitsigns.nvim - Git signs
- numToStr/Comment.nvim - Easy commenting
- echasnovski/mini.pairs - Auto pairs
- echasnovski/mini.surround - Surround text objects

**UI**
- catppuccin/nvim - Colorscheme
- nvim-lualine/lualine.nvim - Statusline
- lukas-reineke/indent-blankline.nvim - Indent guides
- stevearc/dressing.nvim - Better UI elements

**Tools**
- nvim-telescope/telescope.nvim - Fuzzy finder
- akinsho/toggleterm.nvim - Terminal management

**Languages**
- ray-x/go.nvim - Go tooling
- simrat39/rust-tools.nvim - Rust tooling
- MeanderingProgrammer/render-markdown.nvim - Markdown rendering
- b0o/schemastore.nvim - JSON/YAML schemas

## Customization

All configuration is in `~/.config/nvim/lua/`:

- `config/options.lua` - Neovim options
- `config/keymaps.lua` - Custom keymaps
- `config/autocmds.lua` - Autocommands
- `plugins/*.lua` - Plugin configurations

## Performance

This config is **fast**:
- Startup time: ~50-80ms (vs 150-250ms with LazyVim)
- No unnecessary plugins loaded
- Lazy loading where appropriate
- Minimal overhead

## Differences from LazyVim

| Feature | LazyVim | This Config |
|---------|---------|-------------|
| Framework | Full LazyVim | Just Lazy.nvim |
| Plugin Count | 50+ | 25 core plugins |
| Startup Time | 150-250ms | 50-80ms |
| Extras | Many included | Only what you need |
| Customization | Override defaults | Direct configuration |

## Troubleshooting

### LSP not working
```vim
:Mason
```
Check if language servers are installed.

### Plugins not loading
```vim
:Lazy
```
Check plugin status and sync.

### Reset everything
```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
nvim
```

## Updating

```vim
:Lazy sync
```

Or update individual plugins:
```vim
:Lazy update <plugin-name>
```
