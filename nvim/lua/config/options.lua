-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- Ensure the tabline (buffer tabs) is always shown
opt.showtabline = 2

-- Window focus highlighting
opt.winhl = "Normal:ActiveWindow,NormalNC:InactiveWindow"
opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
