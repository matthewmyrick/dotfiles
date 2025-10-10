-- Catppuccin colorscheme with transparency
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = true,
    integrations = {
      blink_cmp = true,
      gitsigns = true,
      mason = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
      snacks = true,
      telescope = true,
      treesitter = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-mocha")

    -- Set picker highlights to be transparent
    vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "NONE" })

    -- Explorer title transparency
    vim.api.nvim_set_hl(0, "SnacksExplorerTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksWinTitle", { bg = "NONE" })

    -- Fix markdown code blocks
    vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "@markup.raw.block.markdown", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "markdownCode", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "markdownCodeBlock", { bg = "NONE" })

    -- Noice cmdline border - soft muted blue (not bright)
    vim.api.nvim_set_hl(0, "NoiceCmdlineBorder", { fg = "#5a7a9f", bg = "NONE" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#5a7a9f", bg = "NONE" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#5a7a9f", bg = "NONE" })

    -- Force explorer transparency and noice colors after a delay
    vim.defer_fn(function()
      -- Explorer transparency - all highlights
      vim.api.nvim_set_hl(0, "SnacksExplorerNormal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksWin", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksNormal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksExplorerList", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksExplorerItem", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksPickerNormalNC", { bg = "NONE", ctermbg = "NONE" })

      -- Noice cmdline colors - force after noice loads
      vim.api.nvim_set_hl(0, "NoiceCmdlineBorder", { fg = "#5a7a9f", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#5a7a9f", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#5a7a9f", bg = "NONE" })

      -- Also force any active explorer windows to update
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_is_valid(buf) then
          local ft = vim.bo[buf].filetype
          if ft == "snacks_explorer" or ft == "snacks_picker" or ft == "snacks_picker_list" then
            vim.wo[win].winhighlight = "Normal:Normal,NormalNC:Normal,NormalFloat:Normal,FloatBorder:Normal,EndOfBuffer:Normal,SignColumn:Normal,CursorLine:NONE,VertSplit:Normal"
            vim.wo[win].winblend = 0
          end
        end
      end
    end, 100)
  end,
}
