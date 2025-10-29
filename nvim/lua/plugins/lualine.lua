-- Lualine statusline
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
    }

    return {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "snacks_dashboard", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      -- Move statusline to top using tabline (always visible, even in Snacks UI)
      tabline = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 3, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          -- Python interpreter path
          {
            function()
              -- Get Python interpreter from Pyright LSP
              local clients = vim.lsp.get_clients({ name = "pyright", bufnr = 0 })
              for _, client in ipairs(clients) do
                if client.config.settings and client.config.settings.python and client.config.settings.python.pythonPath then
                  return "  " .. client.config.settings.python.pythonPath
                end
              end
              return ""
            end,
            cond = function()
              return vim.bo.filetype == "python"
            end,
            color = { fg = "#89b4fa" }, -- Blue color for Python
          },
        },
        lualine_x = {
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = { fg = "#ff9e64" },
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = { fg = "#ff9e64" },
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = { fg = "#ff9e64" },
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%I:%M %p EST")
          end,
        },
      },
      sections = {},
      extensions = { "lazy" },
    }
  end,
}
