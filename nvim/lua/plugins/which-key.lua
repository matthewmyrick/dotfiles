-- Which-key for keymap hints
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    icons = {
      group = "",
    },
    win = {
      border = "rounded",
      wo = {
        winblend = 0, -- No transparency blending
        winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:WhichKeyBorder",
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Get the current FloatBorder foreground color to keep border visible
    local float_border = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
    local border_fg = float_border.fg or "#89b4fa" -- Default to catppuccin blue if not set

    -- Force transparent background with border after setup - all possible highlight groups
    vim.api.nvim_set_hl(0, "WhichKey", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = border_fg, bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeperator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeparator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyValue", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIcon", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconAzure", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconBlue", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconCyan", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconGreen", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconGrey", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconOrange", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconPurple", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconRed", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyIconYellow", { bg = "NONE" })

    -- Delay to ensure which-key has fully loaded
    vim.defer_fn(function()
      vim.api.nvim_set_hl(0, "WhichKey", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = border_fg, bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
    end, 100)
    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "terminal" },
      { "<leader>tf", group = "floating terminal" },
      { "<leader>th", group = "horizontal terminal" },
      { "<leader>tv", group = "vertical terminal" },
      { "<leader>u", group = "ui" },
      { "<leader>w", group = "windows" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
    })
  end,
}
