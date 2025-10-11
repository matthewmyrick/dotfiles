-- Catppuccin colorscheme with transparency
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = true,
    custom_highlights = function(colors)
      return {
        EndOfBuffer = { fg = colors.crust, bg = colors.none },
      }
    end,
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
      which_key = false, -- Disable to prevent catppuccin from adding background
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-mocha")

    -- Snacks picker transparency
    vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreviewNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerPreviewBorder", { bg = "NONE" })

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

    -- Which-key transparency - force all highlight groups
    vim.api.nvim_set_hl(0, "WhichKey", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeperator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeySeparator", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WhichKeyValue", { bg = "NONE" })

    -- Yank highlight - 99% transparent, essentially invisible
    vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#b07a3b", blend = 99 })

    -- Hide EndOfBuffer tildes completely by making them invisible
    local colors_palette = require("catppuccin.palettes").get_palette("mocha")
    vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = colors_palette.base, bg = colors_palette.base })

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
      vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksPickerPreviewNormal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksPickerPreviewBorder", { bg = "NONE", ctermbg = "NONE" })

      -- Noice cmdline colors - force after noice loads
      vim.api.nvim_set_hl(0, "NoiceCmdlineBorder", { fg = "#5a7a9f", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#5a7a9f", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#5a7a9f", bg = "NONE" })

      -- Which-key transparency - force after which-key loads
      vim.api.nvim_set_hl(0, "WhichKey", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeySeperator", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeySeparator", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "WhichKeyValue", { bg = "NONE" })

      -- Hide EndOfBuffer tildes - force after colorscheme loads
      local colors_deferred = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = colors_deferred.base, bg = colors_deferred.base })

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
