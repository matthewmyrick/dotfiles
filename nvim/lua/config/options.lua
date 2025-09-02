-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- Ensure the tabline (buffer tabs) is always shown
opt.showtabline = 2

-- Window focus highlighting
opt.winhl = "Normal:ActiveWindow,NormalNC:InactiveWindow"
opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"

-- Make window separators more visible
opt.fillchars = {
  vert = "┃",     -- Vertical separator
  horiz = "━",    -- Horizontal separator  
  verthoriz = "╋", -- Both vertical and horizontal
  horizup = "┻",   -- Horizontal and up
  horizdown = "┳", -- Horizontal and down
  vertleft = "┫",  -- Vertical and left
  vertright = "┣", -- Vertical and right
}

-- Set window separator colors to soft gray
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6e7681", bg = "NONE" })
    vim.api.nvim_set_hl(0, "VertSplit", { fg = "#6e7681", bg = "NONE" })
  end,
})

-- Apply immediately for current colorscheme
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6e7681", bg = "NONE" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#6e7681", bg = "NONE" })
