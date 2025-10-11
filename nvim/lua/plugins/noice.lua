-- Noice.nvim - Better UI for messages, cmdline and popupmenu
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline", -- Simple cmdline at bottom (not popup)
      opts = {},
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
      },
    },
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = false,
    },
    popupmenu = {
      enabled = false, -- Disable cmdline completion/suggestions
    },
    notify = {
      enabled = false, -- Use Snacks notifier instead
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      progress = {
        enabled = false, -- Disable LSP progress (can be noisy)
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
      },
      hover = {
        enabled = true,
        silent = false,
      },
    },
    presets = {
      bottom_search = false, -- Use centered search
      command_palette = true, -- Centered command palette
      long_message_to_split = true, -- Long messages to split
      inc_rename = false,
      lsp_doc_border = true, -- Add border to hover and signature
    },
    views = {
      cmdline = {
        position = {
          row = "100%", -- At the bottom
          col = 0,
        },
        size = {
          width = "100%",
          height = "auto",
        },
        border = {
          style = "none",
        },
        win_options = {
          winblend = 0,
          winhighlight = "Normal:Normal,NormalFloat:Normal",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = "55%",
          col = "50%",
        },
        size = {
          width = "70%",
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winblend = 0,
          winhighlight = "Normal:Normal,FloatBorder:NoiceCmdlineBorder",
        },
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
  },
}
