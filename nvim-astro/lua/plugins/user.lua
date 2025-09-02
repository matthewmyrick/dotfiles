---@type LazySpec
return {
  -- customize dashboard header
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
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
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠉⠀⠀⠀⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀]],
        },
      },
    },
  },
  -- Add schemastore.nvim for better JSON/YAML schemas
  {
    "b0o/schemastore.nvim",
    lazy = true,
    version = false, -- Use the latest version
  },
  -- Floating command line and UI improvements
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup", -- Use floating popup for command line
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5, -- Fixed position 5 lines from top
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8, -- Just below the command line
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      lsp = {
        -- Disable LSP hover override to prevent conflicts
        hover = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- Keep search at top
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        -- Route search to use the same position as cmdline
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  -- Pipeline.nvim for GitHub Actions CI/CD status
  {
    "topaxi/pipeline.nvim",
    lazy = true,
    keys = {
      { "<leader>gai", "<cmd>Pipeline<cr>", desc = "Open Pipeline (GitHub Actions)" },
    },
    cmd = { "Pipeline" },
    config = true, -- Use default configuration
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  -- Smooth scrolling animations
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
                    '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = "quadratic", -- Default easing function (can be "quadratic", "cubic", "quartic", "quintic", "circular", "sine")
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
        performance_mode = false,    -- Disable "Performance Mode" on all buffers.
      })
      
      -- Custom scroll speeds using correct function signature
      local neoscroll = require('neoscroll')
      local keymap = {
        ['<C-u>'] = function() neoscroll.ctrl_u({ duration = 150 }) end,
        ['<C-d>'] = function() neoscroll.ctrl_d({ duration = 150 }) end,
        ['<C-b>'] = function() neoscroll.ctrl_b({ duration = 250 }) end,
        ['<C-f>'] = function() neoscroll.ctrl_f({ duration = 250 }) end,
        ['<C-y>'] = function() neoscroll.scroll(-4, { move_cursor = false, duration = 100 }) end,
        ['<C-e>'] = function() neoscroll.scroll(4, { move_cursor = false, duration = 100 }) end,
        ['zt']    = function() neoscroll.zt({ half_win_duration = 150 }) end,
        ['zz']    = function() neoscroll.zz({ half_win_duration = 150 }) end,
        ['zb']    = function() neoscroll.zb({ half_win_duration = 150 }) end,
      }
      
      local modes = { 'n', 'v', 'x' }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end
    end,
  },
  -- Flash.nvim for better navigation with 's' key
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false, -- Don't override default search
        },
        char = {
          enabled = true,
          jump_labels = true,
          keys = { "f", "F", "t", "T", ";", "," },
        },
      },
      jump = {
        autojump = false, -- Don't auto-jump when there's only one match
      },
      label = {
        uppercase = false, -- Use lowercase labels
        rainbow = {
          enabled = true, -- Enable rainbow colors for labels
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  -- Configure neo-tree to show hidden files
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- Close neo-tree if it's the last window
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        filtered_items = {
          visible = true, -- This makes hidden files visible by default
          hide_dotfiles = false, -- Don't hide dotfiles
          hide_gitignored = false, -- Show gitignored files too
        },
        -- Enable fuzzy finder mode
        find_command = "fd",
        find_args = {
          fd = {
            "--type", "f",
            "--hidden",
            "--exclude", ".git",
          },
        },
        commands = {
          -- Override delete to use trash instead of rm
          delete = function(state)
            local inputs = require("neo-tree.ui.inputs")
            local path = state.tree:get_node().path
            local msg = "Are you sure you want to delete " .. path
            inputs.confirm(msg, function(confirmed)
              if confirmed then
                vim.fn.system({ "trash", path })
                require("neo-tree.sources.manager").refresh(state.name)
              end
            end)
          end,
        },
      },
      window = {
        mappings = {
          ["/"] = "fuzzy_finder",
          ["//"] = "filter_on_submit",
          ["<C-x>"] = "clear_filter",
          ["<Esc>"] = "clear_filter",
          -- Navigation
          ["e"] = "focus_preview",
          ["<Tab>"] = { 
            "toggle_preview",
            config = { use_float = true }
          },
          -- File operations (Neo-tree uses clipboard for multi-file operations)
          ["a"] = "add", -- Add file/folder
          ["A"] = "add_directory", -- Add directory
          ["d"] = "delete", -- Delete
          ["r"] = "rename", -- Rename
          ["y"] = "copy_to_clipboard", -- Copy to clipboard (for multiple files, navigate and press y on each)
          ["x"] = "cut_to_clipboard", -- Cut to clipboard (for multiple files, navigate and press x on each)
          ["p"] = "paste_from_clipboard", -- Paste all clipboard items
          ["c"] = "copy", -- Copy (duplicate) - different from clipboard
          ["m"] = "move", -- Move
          ["dd"] = "delete", -- Alternative delete
          ["P"] = "toggle_preview", -- Toggle preview
          ["q"] = "close_window", -- Quit
          ["R"] = "refresh", -- Refresh
          ["?"] = "show_help", -- Help
          ["<"] = "prev_source", -- Previous source
          [">"] = "next_source", -- Next source
          -- Opening files
          ["<cr>"] = "open",
          ["<2-LeftMouse>"] = "open",
          ["o"] = "open",
          ["s"] = "open_split",
          ["S"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          -- Expand/collapse
          ["z"] = "close_all_nodes",
          ["Z"] = "expand_all_nodes",
        },
      },
      -- Source selector (the tabs at the top)
      source_selector = {
        winbar = true, -- Show source selector as winbar
        statusline = false,
        sources = {
          { source = "filesystem", display_name = " 󰉓 Files " },
          { source = "buffers", display_name = " 󰈙 Buffers " },
          { source = "git_status", display_name = " 󰊢 Git " },
        },
        content_layout = "center",
        tabs_layout = "equal",
        truncation_character = "…",
        separator = { left = "", right = "" },
        separator_active = nil,
        show_separator_on_edge = false,
        highlight_tab = "NeoTreeTabInactive",
        highlight_tab_active = "NeoTreeTabActive",
        highlight_background = "NeoTreeTabBarBackground",
        highlight_separator = "NeoTreeTabSeparatorInactive",
        highlight_separator_active = "NeoTreeTabSeparatorActive",
      },
      -- Enable sorting options
      sort_case_insensitive = false,
      default_component_configs = {
        indent = {
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "*",
          highlight = "NeoTreeFileIcon"
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added     = "", -- or "✚", but this is redundant info if you use git_status_colors
            modified  = "", -- or "", but this is redundant info if you use git_status_colors
            deleted   = "✖",-- this can only be used in the git_status source
            renamed   = "󰁕",-- this can only be used in the git_status source
            -- Status type
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          }
        },
        -- Add selection indicator
        selection = {
          highlight = "NeoTreeFileNameOpened",
        },
      },
      -- Enable the filter UI at the top
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.opt_local.relativenumber = true
          end,
        },
        {
          event = "neo_tree_popup_input_ready",
          handler = function(args)
            -- Map escape to cancel the input popup
            vim.keymap.set("i", "<esc>", vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
          end,
        },
      },
    },
  },
  -- LazyDocker integration with floating terminal
  {
    "crnvl96/lazydocker.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      popup_window = {
        enter = true,
        focusable = true,
        zindex = 40,
        position = "50%",
        size = {
          width = "90%",
          height = "90%",
        },
        buf_options = {
          modifiable = false,
          readonly = false,
        },
        win_options = {
          winblend = 0,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
        border = {
          style = "rounded",
          text = {
            top = " LazyDocker ",
            top_align = "center",
          },
        },
      },
    },
    config = function(_, opts)
      require("lazydocker").setup(opts)
    end,
  },
}
