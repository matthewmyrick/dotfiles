-- Claude Project Context Manager
return {
  "claude-project-manager",
  dir = vim.fn.stdpath("config") .. "/lua/plugins/claude-project-manager.lua",
  event = "VeryLazy",
  config = function()
    local M = {}

    -- Configuration
    local config = {
      claude_dir = vim.fn.expand("~/.claude/projects"),
      float_opts = {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.8)) / 2),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
        style = "minimal",
        border = "rounded",
      },
      confirm_opts = {
        relative = "editor",
        width = 50,
        height = 5,
        row = math.floor(vim.o.lines / 2) - 2,
        col = math.floor((vim.o.columns - 50) / 2),
        style = "minimal",
        border = "rounded",
      }
    }

    -- State
    local state = {
      projects = {},
      current_index = 1,
      main_win = nil,
      main_buf = nil,
      confirm_win = nil,
      confirm_buf = nil,
    }

    -- Function to read project metadata
    local function read_project_metadata(project_file)
      local metadata = {
        name = vim.fn.fnamemodify(project_file, ":t:r"), -- filename without extension
        path = project_file,
        size = "Unknown",
        modified = "Unknown",
        project_path = "Unknown",
        description = "No description",
      }

      -- Get file stats
      local stat = vim.loop.fs_stat(project_file)
      if stat then
        metadata.size = string.format("%.1f KB", stat.size / 1024)
        metadata.modified = os.date("%Y-%m-%d %H:%M", stat.mtime.sec)
      end

      -- Try to read JSON content for additional metadata
      local file = io.open(project_file, "r")
      if file then
        local content = file:read("*a")
        file:close()
        
        -- Basic JSON parsing for project info
        local project_path = content:match('"project_path"%s*:%s*"([^"]*)"')
        local description = content:match('"description"%s*:%s*"([^"]*)"')
        
        if project_path then
          metadata.project_path = project_path
        end
        if description then
          metadata.description = description
        end
      end

      return metadata
    end

    -- Function to scan Claude projects
    local function scan_claude_projects()
      state.projects = {}
      
      if vim.fn.isdirectory(config.claude_dir) == 0 then
        return
      end

      local files = vim.fn.glob(config.claude_dir .. "/*.json", false, true)
      for _, file in ipairs(files) do
        local metadata = read_project_metadata(file)
        table.insert(state.projects, metadata)
      end

      -- Sort by modified date (newest first)
      table.sort(state.projects, function(a, b)
        return a.modified > b.modified
      end)
    end

    -- Function to render project list
    local function render_projects()
      if not state.main_buf then return end
      
      local lines = {}
      
      -- Header
      table.insert(lines, "┌─ Claude Project Context Manager ─┐")
      table.insert(lines, "│ Use ↑↓ to navigate, Enter to delete, q to quit │")
      table.insert(lines, "└─────────────────────────────────────────────────┘")
      table.insert(lines, "")

      if #state.projects == 0 then
        table.insert(lines, "No Claude projects found in " .. config.claude_dir)
      else
        for i, project in ipairs(state.projects) do
          local prefix = (i == state.current_index) and "► " or "  "
          local highlight = (i == state.current_index) and "Visual" or "Normal"
          
          table.insert(lines, string.format("%s%s", prefix, project.name))
          table.insert(lines, string.format("    Path: %s", project.project_path))
          table.insert(lines, string.format("    Size: %s | Modified: %s", project.size, project.modified))
          table.insert(lines, string.format("    Desc: %s", project.description))
          table.insert(lines, "")
        end
      end

      -- Set buffer content
      vim.api.nvim_buf_set_option(state.main_buf, "modifiable", true)
      vim.api.nvim_buf_set_lines(state.main_buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(state.main_buf, "modifiable", false)

      -- Apply highlighting for current selection
      if #state.projects > 0 then
        local current_line = 4 + (state.current_index - 1) * 5  -- Account for header and spacing
        vim.api.nvim_buf_add_highlight(state.main_buf, -1, "CursorLine", current_line, 0, -1)
      end
    end

    -- Function to show delete confirmation
    local function show_delete_confirmation()
      if state.current_index > #state.projects then return end
      
      local project = state.projects[state.current_index]
      
      -- Create confirmation buffer
      state.confirm_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(state.confirm_buf, "bufhidden", "wipe")
      
      -- Create confirmation window
      state.confirm_win = vim.api.nvim_open_win(state.confirm_buf, true, config.confirm_opts)
      
      -- Set transparent background
      vim.api.nvim_win_set_option(state.confirm_win, "winblend", 20)
      
      -- Set confirmation content
      local confirm_lines = {
        "┌─ Confirm Deletion ─┐",
        "│ Delete project:    │",
        string.format("│ %s", string.sub(project.name .. string.rep(" ", 17), 1, 17) .. "│"),
        "│ y = Yes, n = No    │",
        "└────────────────────┘"
      }
      
      vim.api.nvim_buf_set_lines(state.confirm_buf, 0, -1, false, confirm_lines)
      vim.api.nvim_buf_set_option(state.confirm_buf, "modifiable", false)
      
      -- Set up confirmation keymaps
      local function close_confirmation()
        if state.confirm_win then
          vim.api.nvim_win_close(state.confirm_win, true)
          state.confirm_win = nil
          state.confirm_buf = nil
        end
        vim.api.nvim_set_current_win(state.main_win)
      end
      
      local function delete_project()
        local success = pcall(vim.fn.delete, project.path)
        if success then
          vim.notify("Deleted project: " .. project.name, vim.log.levels.INFO)
          close_confirmation()
          scan_claude_projects()
          if state.current_index > #state.projects then
            state.current_index = math.max(1, #state.projects)
          end
          render_projects()
        else
          vim.notify("Failed to delete project: " .. project.name, vim.log.levels.ERROR)
          close_confirmation()
        end
      end
      
      vim.keymap.set("n", "y", delete_project, { buffer = state.confirm_buf, nowait = true })
      vim.keymap.set("n", "Y", delete_project, { buffer = state.confirm_buf, nowait = true })
      vim.keymap.set("n", "n", close_confirmation, { buffer = state.confirm_buf, nowait = true })
      vim.keymap.set("n", "N", close_confirmation, { buffer = state.confirm_buf, nowait = true })
      vim.keymap.set("n", "<Esc>", close_confirmation, { buffer = state.confirm_buf, nowait = true })
    end

    -- Function to close the manager
    local function close_manager()
      if state.confirm_win then
        vim.api.nvim_win_close(state.confirm_win, true)
      end
      if state.main_win then
        vim.api.nvim_win_close(state.main_win, true)
      end
      state.main_win = nil
      state.main_buf = nil
      state.confirm_win = nil
      state.confirm_buf = nil
    end

    -- Function to open the manager
    function M.open_manager()
      -- Scan for projects
      scan_claude_projects()
      state.current_index = 1
      
      -- Create main buffer
      state.main_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(state.main_buf, "bufhidden", "wipe")
      vim.api.nvim_buf_set_option(state.main_buf, "filetype", "claude-projects")
      
      -- Create main window
      state.main_win = vim.api.nvim_open_win(state.main_buf, true, config.float_opts)
      
      -- Set transparent background
      vim.api.nvim_win_set_option(state.main_win, "winblend", 20)
      
      -- Render initial content
      render_projects()
      
      -- Set up keymaps
      local function move_up()
        if state.current_index > 1 then
          state.current_index = state.current_index - 1
          render_projects()
        end
      end
      
      local function move_down()
        if state.current_index < #state.projects then
          state.current_index = state.current_index + 1
          render_projects()
        end
      end
      
      vim.keymap.set("n", "<Up>", move_up, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "k", move_up, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "<Down>", move_down, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "j", move_down, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "<Enter>", show_delete_confirmation, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "<CR>", show_delete_confirmation, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "d", show_delete_confirmation, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "q", close_manager, { buffer = state.main_buf, nowait = true })
      vim.keymap.set("n", "<Esc>", close_manager, { buffer = state.main_buf, nowait = true })
      
      -- Refresh keybind
      vim.keymap.set("n", "r", function()
        scan_claude_projects()
        state.current_index = math.min(state.current_index, math.max(1, #state.projects))
        render_projects()
        vim.notify("Refreshed project list", vim.log.levels.INFO)
      end, { buffer = state.main_buf, nowait = true })
    end

    -- Register the command
    vim.api.nvim_create_user_command("ClaudeProjectManager", M.open_manager, {
      desc = "Open Claude Project Context Manager"
    })

    -- Add keybinding
    vim.keymap.set("n", "<leader>mcp", M.open_manager, { desc = "Claude Project Manager" })

    return M
  end,
}