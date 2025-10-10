-- Snacks.nvim - UI components (explorer, picker, dashboard, notifier)
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Dashboard
    dashboard = {
      enabled = true,
      preset = {
        header = [[
  _____                   _             _       _             _    _
 |_   _|__ _ __ _ __ ___ (_)_ __   __ _| |     | |_   _ _ __ | | _(_) ___
   | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | |  _  | | | | | '_ \| |/ / |/ _ \
   | |  __/ |  | | | | | | | | | | (_| | | | |_| | |_| | | | |   <| |  __/
   |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_|  \___/ \__,_|_| |_|_|\_\_|\___|


        ⠀⠀⠀⠀⠀⠀⢀⣀⠤⡤⣠⣄⣀⠠⠔⡱⠉⡀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⢀⠔⠈⠀⠀⠀⠀⠀⠁⠈⠢⢀⠃⢀⡇⠀⠀⣀⠤⠤⡀
        ⠀⢀⢴⡷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣀⠜⠁⡴⠊⠀⠀⡠⠇
        ⢠⠁⣈⢀⢔⣊⣉⡉⠑⡄⠀⠀⠀⠀⢈⡃⠔⡺⠁⠀⠀⠸⢤⠀
        ⠈⠦⡿⣿⣿⣯⣼⡇⠀⠇⠀⠀⣠⠔⢁⣠⡞⠁⠀⠀⢀⡴⠁⠀
        ⠀⠀⠙⠻⢯⡍⠥⠤⠊⠀⠀⠀⢧⣶⣿⠟⠁⠀⣀⠔⠋⠀⠀⠀
        ⠀⠀⠀⠀⠀⣸⡍⢀⡖⠉⠀⠈⠀⠈⠹⣍⠉⠁⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⢰⠉⣾⡠⠀⠀⡜⠀⠀⠀⠈⠣⡀⠀⠀⠀⠀⠀⠀
        ⠀⢠⢲⣲⣍⡉⡰⠃⠀⣀⠤⠧⠤⡀⠀⠀⠀⢹⡀⠀⠀⠀⠀⠀
        ⠀⠀⢿⣧⣸⢿⡇⠠⡾⢄⠁⡂⠀⠀⠀⠀⠀⠀⡅⠀⠀⠀⠀⠀
        ⠀⠀⠀⠉⢛⣿⡮⠥⢇⢀⢗⣇⣀⣀⣀⣀⣤⣾⡧⠀⠀⠀⠀⠀
]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    -- File Explorer
    explorer = {
      layout = {
        backdrop = false,
      },
      git = {
        enable = true,
        icons = {
          untracked = "?",
          added = "+",
          modified = "~",
          deleted = "-",
          renamed = "→",
          ignored = "!",
        },
        hl = {
          untracked = "DiagnosticWarn",
          added = "DiagnosticInfo",
          modified = "DiagnosticHint",
          deleted = "DiagnosticError",
          renamed = "DiagnosticInfo",
          ignored = "Comment",
        },
      },
      filters = {
        dotfiles = true, -- Hide dotfiles by default (toggle with 'H')
        git_ignored = true, -- Hide git ignored files by default (toggle with 'I')
        custom = {},
      },
      follow_symlinks = true,
      show_hidden = false, -- Hide hidden files by default
      close_on_select = false,
      auto_close = false,
      replace_netrw = true,
      hijack_netrw = true,
      actions = {
        ["<CR>"] = function(self, item)
          if item.is_file then
            vim.cmd("wincmd p")
            vim.cmd("edit " .. item.path)
          else
            self:toggle_expand(item)
          end
        end,
        ["<C-CR>"] = function(self, item)
          if item.is_file then
            vim.cmd("edit " .. item.path)
          else
            self:toggle_expand(item)
          end
        end,
      },
    },
    -- Notifier
    notifier = {
      enabled = true,
      timeout = 3000,
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
      style = "compact",
      top_down = false,
      date_format = "%I:%M %p EST",
    },
    -- Picker (fuzzy finder)
    picker = {
      enabled = true,
      layout = {
        backdrop = false,
      },
      win = {
        input = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Normal,SignColumn:Normal",
          },
        },
        list = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Normal,SignColumn:Normal",
          },
        },
        preview = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Normal,SignColumn:Normal",
          },
        },
      },
    },
    -- Lazygit integration
    lazygit = { enabled = true },
    -- Git browse
    gitbrowse = { enabled = true },
    -- Big file handling
    bigfile = { enabled = true },
    -- Quickfile
    quickfile = { enabled = true },
    -- Status column
    statuscolumn = { enabled = false },
    -- Words
    words = { enabled = false },
  },
  keys = {
    { "<leader>e", function() Snacks.explorer() end, desc = "Open/Focus File Explorer" },
    { "<leader><leader>", function() Snacks.explorer() end, desc = "Focus/Open File Explorer" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for easier access
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create vim.ui.select and vim.ui.input wrappers
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
      end,
    })
  end,
}
