return {
  -- Custom bufferline configuration
  {
    "akinsho/bufferline.nvim",
    event = "BufReadPost", -- Load earlier
    priority = 100, -- High priority
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    },
    opts = {
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
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' }
        },
      },
      highlights = {
        -- Darken inactive buffers
        background = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        buffer_visible = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        buffer_selected = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
          bold = true,
          italic = false,
        },
        -- Darken non-selected buffer text and icons
        duplicate = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
          italic = false,
        },
        duplicate_visible = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
          italic = false,
        },
        duplicate_selected = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
          italic = false,
        },
        -- Darken modified indicators for inactive buffers
        modified = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        modified_visible = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        modified_selected = {
          fg = { attribute = "fg", highlight = "String" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        -- Darken close buttons for inactive buffers
        close_button = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        close_button_visible = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        close_button_selected = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        -- Separator colors
        separator = {
          fg = { attribute = "bg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        separator_visible = {
          fg = { attribute = "bg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        separator_selected = {
          fg = { attribute = "bg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        -- Diagnostic colors for inactive buffers (dimmed)
        diagnostic = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        diagnostic_visible = {
          fg = { attribute = "fg", highlight = "Comment" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
        diagnostic_selected = {
          fg = { attribute = "fg", highlight = "DiagnosticError" },
          bg = { attribute = "bg", highlight = "Normal" },
          bold = true,
        },
      },
    },
    config = function(_, opts)
      -- Ensure bufferline loads properly
      local bufferline = require("bufferline")
      bufferline.setup(opts)
      
      -- Debug: Check if setup worked
      vim.schedule(function()
        vim.notify("Bufferline setup completed", vim.log.levels.INFO)
      end)
    end,
  },
}