-- Neovim options
local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Python provider
g.python3_host_prog = '/opt/homebrew/bin/python3'

-- General settings
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.mouse = "a" -- Enable mouse
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.undofile = true -- Persistent undo
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Unless search has uppercase
opt.termguicolors = true -- True color support
opt.signcolumn = "yes" -- Always show signcolumn
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Time to wait for mapped sequence
opt.splitright = true -- Vertical splits to the right
opt.splitbelow = true -- Horizontal splits below
opt.scrolloff = 8 -- Lines to keep above/below cursor
opt.wrap = false -- Don't wrap lines
opt.cursorline = true -- Highlight current line
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Indent width
opt.tabstop = 2 -- Tab width
opt.smartindent = true -- Smart auto-indent
opt.showtabline = 2 -- Always show tabline
opt.laststatus = 3 -- Global statusline
opt.cmdheight = 0 -- No command line space at bottom

-- Window focus highlighting
opt.winhl = "Normal:ActiveWindow,NormalNC:InactiveWindow"
opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"

-- Window separators
opt.fillchars = {
  vert = "┃",
  horiz = "━",
  verthoriz = "╋",
  horizup = "┻",
  horizdown = "┳",
  vertleft = "┫",
  vertright = "┣",
}

-- Set window separator colors
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6e7681", bg = "NONE" })
    vim.api.nvim_set_hl(0, "VertSplit", { fg = "#6e7681", bg = "NONE" })
  end,
})

-- Apply separator colors immediately
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6e7681", bg = "NONE" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#6e7681", bg = "NONE" })

-- Disable netrw (we use snacks explorer)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
