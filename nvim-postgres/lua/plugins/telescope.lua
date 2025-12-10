-- Telescope for fuzzy finding
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      -- Set up transparent highlights for Telescope
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE", fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "NONE", fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "NONE", fg = "#89b4fa", bold = true })
      vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "NONE", fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "NONE", fg = "#89b4fa", bold = true })
      vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "NONE", fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "NONE", fg = "#89b4fa", bold = true })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#313244", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = "#a6e3a1" })
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = "#89b4fa" })

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.5,
              results_width = 0.5,
            },
            width = 0.8,
            height = 0.8,
          },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },
      })
    end,
  },
}
