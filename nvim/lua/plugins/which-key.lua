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
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Force transparent background with border after setup
    vim.api.nvim_set_hl(0, "WhichKey", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeperator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeparator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyValue", { bg = "NONE" })
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
