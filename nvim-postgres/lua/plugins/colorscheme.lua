-- Catppuccin colorscheme (matching main nvim config)
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          treesitter = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")

      -- Yank highlight - orange flash
      vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#b07a3b", blend = 99 })
    end,
  },
}
