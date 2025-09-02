-- Standalone bufferline configuration (separate from LazyVim)
return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    },
    config = function()
      -- Simple, standalone setup
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          always_show_bufferline = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "snacks_explorer",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
              separator = true,
            },
          },
        },
        highlights = {
          -- Simple highlighting without LazyVim interference
          background = {
            fg = "#6c7086", -- Dimmed text color
          },
          buffer_visible = {
            fg = "#6c7086", -- Dimmed text color
          },
          buffer_selected = {
            fg = "#cdd6f4", -- Bright text for selected
            bold = true,
          },
          modified = {
            fg = "#6c7086",
          },
          modified_selected = {
            fg = "#f9e2af", -- Bright yellow for modified
          },
          duplicate = {
            fg = "#6c7086",
          },
          duplicate_selected = {
            fg = "#cdd6f4",
          },
        },
      })
    end,
  },
}