# Configuration Comparison

## Old Config (nvim/) vs New Config (nvim-new/)

### Architecture

| Aspect | Old (LazyVim) | New (Minimal) |
|--------|---------------|---------------|
| Base Framework | Full LazyVim | Just Lazy.nvim |
| Config Loading | LazyVim → Your overrides | Direct configuration |
| Plugin Management | LazyVim + extras | Direct plugin specs |
| Defaults | LazyVim defaults | Your custom defaults |

### Plugin Count

**Old Config:** ~50+ plugins (LazyVim + extras)
- LazyVim core plugins
- All LazyVim extras enabled
- Your custom plugins

**New Config:** ~25 plugins (only what you need)
- Core utilities
- LSP & completion
- Your essential tools

### What's Kept

✅ **Everything you love:**
- Snacks.nvim (explorer, picker, dashboard, notifier)
- All LSP servers (Go, Python, TypeScript, Rust, YAML, JSON, SQL, Helm)
- Blink.cmp completion
- Toggleterm with ALL your custom terminal configs
- Telescope for buffer management
- Catppuccin theme with transparency
- All your custom keymaps
- Window management
- Git integration

### What's Removed

❌ **LazyVim bloat:**
- LazyVim framework overhead
- Yanky (clipboard manager) - rarely used
- Toml extras - can add back if needed
- Dot file extras
- Mini-diff - gitsigns handles this
- Omnisharp - C# support (can add back)
- LazyVim default keymaps that you override
- Unused integrations

### Startup Performance

**Old Config:**
- ~150-250ms startup (with LazyVim)
- Loads LazyVim core + extras
- Many lazy-loaded plugins

**New Config:**
- ~50-80ms startup (just Lazy.nvim)
- Only loads what you need
- Faster initial load

### File Structure

**Old Config:**
```
nvim/
├── init.lua (loads LazyVim)
├── lazyvim.json (extras config)
└── lua/
    ├── config/
    │   ├── lazy.lua (imports lazyvim.plugins)
    │   ├── options.lua (overrides)
    │   ├── keymaps.lua (overrides)
    │   └── autocmds.lua
    └── plugins/ (overrides LazyVim plugins)
```

**New Config:**
```
nvim-new/
├── init.lua (minimal bootstrap)
└── lua/
    ├── config/
    │   ├── lazy.lua (just lazy.nvim)
    │   ├── options.lua (your settings)
    │   ├── keymaps.lua (your keymaps)
    │   └── autocmds.lua (your autocmds)
    └── plugins/ (direct plugin specs)
```

### Plugin List Comparison

#### Core UI (Both)
- ✅ folke/snacks.nvim
- ✅ catppuccin/nvim
- ✅ nvim-lualine/lualine.nvim
- ✅ folke/which-key.nvim

#### Removed from Old
- ❌ LazyVim/LazyVim (framework)
- ❌ gbprod/yanky.nvim (clipboard)
- ❌ echasnovski/mini.diff (redundant with gitsigns)
- ❌ LazyVim extras overhead

#### LSP & Completion (Both)
- ✅ neovim/nvim-lspconfig
- ✅ williamboman/mason.nvim
- ✅ saghen/blink.cmp
- ✅ nvim-treesitter/nvim-treesitter

#### Tools (Both)
- ✅ akinsho/toggleterm.nvim
- ✅ nvim-telescope/telescope.nvim
- ✅ lewis6991/gitsigns.nvim

#### Languages (Both)
- ✅ ray-x/go.nvim
- ✅ simrat39/rust-tools.nvim
- ✅ b0o/schemastore.nvim

### Migration Path

1. **Backup current config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Test new config:**
   ```bash
   ln -s ~/GitHub/matthewmyrick/dotfiles/nvim-new ~/.config/nvim
   nvim
   ```

3. **If issues, rollback:**
   ```bash
   rm ~/.config/nvim
   mv ~/.config/nvim.backup ~/.config/nvim
   ```

### Adding Back Features

If you need something from the old config:

**Yanky (clipboard history):**
```lua
-- Add to plugins/extras.lua
{
  "gbprod/yanky.nvim",
  opts = {},
}
```

**C# support (omnisharp):**
```lua
-- Add to plugins/lsp.lua
lspconfig.omnisharp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
```

### Maintenance

**Old Config:**
- Update LazyVim: `:LazyExtras`
- Manage extras via lazyvim.json
- Override LazyVim defaults

**New Config:**
- Update plugins: `:Lazy sync`
- Direct plugin configuration
- No framework to update

### Recommended Approach

1. ✅ Use `nvim-new/` as primary config
2. ✅ Keep `nvim/` as backup for 1-2 weeks
3. ✅ If you find something missing, add it directly to `nvim-new/`
4. ✅ After comfortable, delete old config

The new config gives you **full control** without the **LazyVim overhead**.
