# 📝 Neovim Configuration

A comprehensive Neovim setup built on LazyVim with custom plugins, keybindings, and optimizations for modern development workflows. This configuration transforms Neovim into a powerful IDE while maintaining the speed and efficiency of a text editor.

## 🎯 Overview

This Neovim configuration provides:
- **Modern plugin ecosystem** with lazy loading for fast startup
- **Custom keybindings** optimized for productivity
- **Language Server Protocol (LSP)** support for multiple languages
- **Integrated terminal** and file management
- **Git integration** with advanced workflows
- **AI assistance** with GitHub Copilot integration

## 📁 Structure

```
nvim/
├── init.lua                 # Main configuration entry point
├── lazyvim.json            # LazyVim configuration
├── stylua.toml             # Lua formatter configuration
└── lua/
    ├── config/             # Core configuration
    │   ├── autocmds.lua        # Auto commands
    │   ├── keymaps.lua         # Custom key mappings
    │   ├── lazy.lua            # Plugin manager setup
    │   └── options.lua         # Editor options
    └── plugins/            # Plugin configurations
        ├── colorscheme.lua     # Theme configuration
        ├── copilot.lua         # AI assistance setup
        ├── dashboard.lua       # Start screen
        ├── go.lua              # Go development setup
        ├── obsidian.lua        # Note-taking integration
        ├── render-markdown.lua # Markdown rendering
        ├── snacks.lua          # UI enhancements
        ├── toggleterm.lua      # Terminal integration
        ├── toggleterm/         # Terminal configurations
        │   ├── buffer.lua          # Buffer terminal
        │   ├── floating.lua        # Floating terminal
        │   ├── horizontal.lua      # Horizontal split terminal
        │   ├── python-utils.lua    # Python development tools
        │   └── vertical.lua        # Vertical split terminal
        └── ui.lua              # User interface enhancements
```

## 🚀 Installation

The Neovim configuration is automatically installed via the main install script:

```bash
./install.sh
```

Or manually:

```bash
# Remove existing Neovim configuration
rm -rf ~/.config/nvim

# Copy new configuration
cp -R nvim ~/.config/

# Install Python virtual environment for Neovim
python3 -m venv ~/.local/share/nvim/venv
source ~/.local/share/nvim/venv/bin/activate
pip install xlrd pylightxl
```

## ✨ Key Features

### 🎨 LazyVim Foundation
Built on [LazyVim](https://lazyvim.github.io/), providing:
- **Lazy loading** for fast startup times
- **Sensible defaults** for modern development
- **Easy customization** with override patterns
- **Active maintenance** and community support

### 🔧 Custom Enhancements

#### Text Object Navigation
Revolutionary `gt` (go to) keybindings for moving to the beginning of text objects:

```lua
-- Move cursor to beginning of text objects
gtib    -- Go to beginning inside brackets ()
gtiB    -- Go to beginning inside braces {}
gti'    -- Go to beginning inside single quotes
gti"    -- Go to beginning inside double quotes
gtiq    -- Go to beginning inside quotes (shortcut)
gtit    -- Go to beginning inside HTML/XML tags
gtiw    -- Go to beginning of word
gtis    -- Go to beginning of sentence
gtip    -- Go to beginning of paragraph

-- Include delimiter versions
gtab, gtaB, gta', etc. -- Include the delimiter
```

#### Enhanced Navigation Keybindings
```lua
-- Swap 0 and ^ for better line navigation
0       -- Go to first non-blank character (was ^)
^       -- Go to beginning of line (was 0)

-- File and project navigation
<leader><leader>  -- Find files (current window)
<leader>sg        -- Live grep (current window)
<leader>sG        -- Grep string (current window)
```

#### Terminal Integration
Multiple terminal configurations for different workflows:
- **Floating terminal**: Quick command execution
- **Horizontal split**: Side-by-side with code
- **Vertical split**: Bottom panel for logs
- **Buffer terminal**: Full-screen terminal mode

### 🎯 Language Support

#### Go Development (`lua/plugins/go.lua`)
Comprehensive Go development environment:
- **LSP Configuration**: Full gopls setup with all analyses
- **Enhanced Diagnostics**: Inline hints and error detection
- **Code Actions**: Import management, refactoring
- **Testing Integration**: Built-in test runners
- **Formatting**: gofumpt and goimports on save

```lua
-- Go-specific keybindings
<leader>gt  -- Run tests
<leader>gT  -- Run test function
<leader>gc  -- Show coverage
<leader>gl  -- Run linter
<leader>gi  -- Organize imports
<leader>gv  -- Run go vet
```

#### Python Integration
- **Virtual environment support** for isolated package management
- **Excel file support** with xlrd and pylightxl
- **Debugging integration** with DAP
- **Linting and formatting** with ruff and black

### 🤖 AI Integration

#### GitHub Copilot (`lua/plugins/copilot.lua`)
Intelligent code completion and generation:
- **Context-aware suggestions** based on current code
- **Multi-language support** for various programming languages
- **Inline completions** that don't interrupt workflow
- **Chat integration** for code explanation and refactoring

### 🎨 User Interface

#### Dashboard (`lua/plugins/dashboard.lua`)
Beautiful start screen with:
- **Recent files** quick access
- **Project shortcuts** for common workflows
- **Session management** for workspace restoration
- **Custom actions** for frequent tasks

#### Colorscheme (`lua/plugins/colorscheme.lua`)
Carefully selected theme optimized for:
- **Long coding sessions** with reduced eye strain
- **Syntax highlighting** that improves code readability
- **Consistent theming** across all plugins
- **Terminal integration** for unified appearance

### 📝 Note-Taking (`lua/plugins/obsidian.lua`)
Integrated note-taking with Obsidian compatibility:
- **Markdown enhancements** with live preview
- **Wiki-style linking** between notes
- **Tag management** for organization
- **Search integration** across all notes

## ⌨️ Key Mappings Reference

### Core Navigation
| Shortcut | Action | Description |
|----------|---------|-------------|
| `0` | `^` | Go to first non-blank character |
| `^` | `0` | Go to beginning of line |
| `<leader><leader>` | Find files | Open file picker in current window |
| `<leader>sg` | Live grep | Search across project files |
| `<leader>sG` | Grep string | Search for word under cursor |

### Text Object Navigation (gt prefix)
| Shortcut | Action | Description |
|----------|---------|-------------|
| `gtib` | Inside brackets | Move to start inside () |
| `gtiB` | Inside braces | Move to start inside {} |
| `gti'` | Inside single quotes | Move to start inside '' |
| `gti"` | Inside double quotes | Move to start inside "" |
| `gtiq` | Inside quotes | Move to start inside quotes (any) |
| `gtit` | Inside tags | Move to start inside HTML/XML tags |
| `gtiw` | Inside word | Move to start of current word |
| `gtis` | Inside sentence | Move to start of sentence |
| `gtip` | Inside paragraph | Move to start of paragraph |

### Buffer Management
| Shortcut | Action | Description |
|----------|---------|-------------|
| `<leader>bd` | Delete buffer | Smart buffer deletion |
| `<leader>bf` | Find buffers | Search open buffers |
| `<leader>fBd` | Multi-delete buffers | Delete multiple buffers with selection |

### Terminal Integration
| Shortcut | Action | Description |
|----------|---------|-------------|
| `<Esc><Esc>` | Exit terminal mode | Return to normal mode in terminal |

### Go Development
| Shortcut | Action | Description |
|----------|---------|-------------|
| `<leader>gt` | Go test | Run tests in current package |
| `<leader>gT` | Go test function | Run test under cursor |
| `<leader>gc` | Go coverage | Show test coverage |
| `<leader>gl` | Go lint | Run golangci-lint |
| `<leader>gi` | Go imports | Organize imports |
| `<leader>gv` | Go vet | Run go vet |

### LSP (Language Server)
| Shortcut | Action | Description |
|----------|---------|-------------|
| `gd` | Go to definition | Jump to symbol definition |
| `gr` | Go to references | Find all references |
| `gi` | Go to implementation | Jump to implementation |
| `gt` | Go to type definition | Jump to type definition |
| `K` | Hover documentation | Show symbol documentation |
| `<leader>ca` | Code actions | Show available code actions |
| `<leader>rn` | Rename symbol | Rename symbol under cursor |

### Diagnostics
| Shortcut | Action | Description |
|----------|---------|-------------|
| `<leader>d` | Open diagnostic float | Show diagnostic details |
| `[d` | Previous diagnostic | Jump to previous diagnostic |
| `]d` | Next diagnostic | Jump to next diagnostic |
| `<leader>q` | Diagnostic list | Open diagnostics quickfix list |

## 🔧 Configuration Details

### Plugin Manager (Lazy.nvim)
```lua
-- Lazy loading configuration
{
  "plugin-name",
  lazy = true,           -- Load only when needed
  event = "VeryLazy",   -- Load after startup
  keys = { "<leader>x" }, -- Load when key is pressed
  ft = { "lua", "vim" }, -- Load for specific filetypes
}
```

### LSP Configuration
Advanced Language Server Protocol setup:
```lua
-- Enhanced capabilities
capabilities = {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
        resolveSupport = true,
      }
    }
  }
}
```

### Auto Commands
Smart automation for common tasks:
```lua
-- Format on save for Go files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
```

## 🚀 Performance Optimizations

### Startup Time
- **Lazy loading**: Plugins load only when needed
- **Optimized startup**: ~50-100ms typical startup time
- **Async loading**: Non-blocking plugin initialization
- **Smart caching**: Compiled configurations for speed

### Memory Usage
- **Efficient plugins**: Carefully selected for minimal footprint
- **Tree-sitter**: Incremental parsing for large files
- **LSP optimization**: Smart server management
- **Buffer management**: Automatic cleanup of unused buffers

### File Handling
- **Large file support**: Optimizations for files >1MB
- **Incremental search**: Fast searching in large codebases
- **Async operations**: Non-blocking file operations
- **Smart detection**: Automatic filetype detection

## 🔍 Troubleshooting

### Plugin Issues
```bash
# Reset plugin state
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# Reinstall plugins
nvim --headless -c 'Lazy! restore' -c 'qa'
```

### LSP Problems
```bash
# Check LSP status
:LspInfo

# Restart LSP servers
:LspRestart

# Check Mason installations
:Mason
```

### Python Environment Issues
```bash
# Recreate virtual environment
rm -rf ~/.local/share/nvim/venv
python3 -m venv ~/.local/share/nvim/venv
source ~/.local/share/nvim/venv/bin/activate
pip install xlrd pylightxl
```

### Performance Issues
```lua
-- Profile startup time
nvim --startuptime startup.log

-- Check plugin loading
:Lazy profile
```

## 🎨 Customization

### Adding New Plugins
Create a new file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- Plugin configuration here
  end,
}
```

### Custom Keybindings
Add to `lua/config/keymaps.lua`:
```lua
vim.keymap.set("n", "<leader>x", function()
  -- Your custom function here
end, { desc = "Description of what this does" })
```

### Language Server Setup
Add to appropriate plugin file:
```lua
{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      your_lsp = {
        -- LSP configuration here
      },
    },
  },
}
```

## 📊 Features Summary

| Feature | Status | Description |
|---------|--------|-------------|
| ✅ LSP Integration | Active | Full language server support |
| ✅ Tree-sitter | Active | Advanced syntax highlighting |
| ✅ Git Integration | Active | Fugitive and Gitsigns |
| ✅ File Explorer | Active | Neo-tree file manager |
| ✅ Fuzzy Finding | Active | Telescope integration |
| ✅ Terminal | Active | Toggleterm integration |
| ✅ AI Copilot | Active | GitHub Copilot support |
| ✅ Diagnostics | Active | Inline error detection |
| ✅ Formatting | Active | Automatic code formatting |
| ✅ Debugging | Active | DAP integration |
| ✅ Testing | Active | Built-in test runners |
| ✅ Snippets | Active | LuaSnip integration |

This Neovim configuration provides a complete development environment that rivals modern IDEs while maintaining the speed and efficiency that makes Neovim special.