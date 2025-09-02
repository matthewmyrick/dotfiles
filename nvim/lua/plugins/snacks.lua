return {
  "folke/snacks.nvim",
  opts = {
    -- Enable dashboard with tabs
    dashboard = { 
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = {
      filters = {
        dotfiles = false, -- Show dotfiles
        git_ignored = false, -- Show git ignored files
        custom = {}, -- No custom filters
      },
      follow_symlinks = true, -- Follow symbolic links
      show_hidden = true, -- Explicitly show hidden files
      close_on_select = false, -- Keep explorer open when selecting files
      auto_close = false, -- Don't auto-close when it's the last window
      replace_netrw = true, -- Replace netrw with Snacks explorer
      hijack_netrw = true, -- Hijack netrw file exploration
      actions = {
        -- Override the default action to keep the explorer open
        ["<CR>"] = function(self, item)
          if item.is_file then
            -- Open file but keep explorer open
            vim.cmd("wincmd p") -- Go to previous window
            vim.cmd("edit " .. item.path)
          else
            -- For directories, use default behavior
            self:toggle_expand(item)
          end
        end,
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000, -- default timeout in ms
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "compact", -- "compact" or "fancy"
      top_down = false, -- place notifications from top to bottom
      date_format = "%R", -- time format
    },
  },
}