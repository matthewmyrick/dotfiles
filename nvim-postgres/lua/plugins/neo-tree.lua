-- Neo-tree for SQL file browser
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Set up highlights for transparency
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })

      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = false,
        enable_diagnostics = false,

        sources = { "filesystem" },
        source_selector = {
          winbar = false,
          statusline = false,
        },

        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = false,
          },
        },

        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = false,
            hide_by_name = {
              ".gitkeep",
            },
            hide_by_pattern = {},
            always_show = {},
            never_show = {
              ".gitkeep",
              ".DS_Store",
            },
            never_show_by_pattern = {},
          },
          scan_mode = "shallow",
          bind_to_cwd = true,
          follow_current_file = {
            enabled = false,
          },
          use_libuv_file_watcher = true,

          window = {
            position = "current",
            mappings = {
              -- Open file in the main editor (right pane), keep neo-tree open
              ["<CR>"] = function(state)
                local node = state.tree:get_node()
                if node.type == "directory" then
                  -- Toggle directory
                  require("neo-tree.sources.filesystem").toggle_directory(state, node)
                else
                  -- Open file in the main editor window (not side panels or terminals)
                  local wins = vim.api.nvim_list_wins()
                  local target_win = nil
                  local neo_tree_win = vim.api.nvim_get_current_win()

                  -- Find the main editor window
                  for _, win in ipairs(wins) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local buf_name = vim.api.nvim_buf_get_name(buf)
                    local ft = vim.bo[buf].filetype
                    local buftype = vim.bo[buf].buftype

                    -- Skip neo-tree, postgres-drawer, results, and terminal buffers (like Claude)
                    if ft ~= "neo-tree" and ft ~= "postgres-drawer" and ft ~= "postgres-results"
                       and buftype ~= "terminal" and not buf_name:match("postgres://") then
                      target_win = win
                    end
                  end

                  if target_win then
                    vim.api.nvim_set_current_win(target_win)
                    vim.cmd("edit " .. vim.fn.fnameescape(node.path))
                  else
                    -- No suitable window - create one to the right of neo-tree
                    vim.api.nvim_set_current_win(neo_tree_win)
                    vim.cmd("vertical rightbelow split " .. vim.fn.fnameescape(node.path))
                  end
                end
              end,
              ["o"] = function(state)
                local node = state.tree:get_node()
                if node.type == "directory" then
                  require("neo-tree.sources.filesystem").toggle_directory(state, node)
                end
              end,
              ["<C-v>"] = "open_vsplit",
              ["<C-x>"] = "open_split",
              ["a"] = {
                "add",
                config = {
                  show_path = "relative",
                },
              },
              ["d"] = "delete",
              ["r"] = "rename",
              ["y"] = "copy_to_clipboard",
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
              ["c"] = "copy",
              ["m"] = "move",
              ["R"] = "refresh",
              ["?"] = "show_help",
              ["/"] = function(state)
                -- Use Telescope to fuzzy find files in the SQL directory
                local sql_dir = require("postgres").config.sql_directory
                local has_telescope, builtin = pcall(require, "telescope.builtin")
                if has_telescope then
                  builtin.find_files({
                    cwd = sql_dir,
                    prompt_title = "Search SQL Files",
                    find_command = { "find", ".", "-type", "f", "-name", "*.sql", "-o", "-name", "*.md" },
                  })
                else
                  -- Fallback to neo-tree's built-in fuzzy finder
                  require("neo-tree.sources.filesystem.commands").fuzzy_finder(state)
                end
              end,
              ["f"] = "filter_on_submit",
              ["<C-c>"] = "clear_filter",
            },
          },
        },
      })
    end,
  },
}
