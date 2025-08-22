return {
  -- Override LazyVim's bufferline configuration
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    opts = function(_, opts)
      -- Merge with LazyVim's default options if they exist
      opts = vim.tbl_deep_extend("force", opts or {}, {
        options = {
          mode = "buffers",
          separator_style = "slant",
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = true,
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "snacks_explorer",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
      return opts
    end,
  },
}