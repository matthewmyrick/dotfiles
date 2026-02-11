-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Simple circular window navigation using wincmd (skip explorer)
local function cycle_windows()
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    local normal_wins = {}
    
    -- Get all non-floating, non-explorer windows
    for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        
        -- Skip floating windows and explorer
        if config.relative == "" and ft ~= "snacks_explorer" then
            table.insert(normal_wins, win)
        end
    end
    
    -- If we have multiple windows, cycle through them
    if #normal_wins > 1 then
        -- Find current window index
        local current_idx = 1
        for i, win in ipairs(normal_wins) do
            if win == current_win then
                current_idx = i
                break
            end
        end
        
        -- Move to next window (with wrapping)
        local next_idx = (current_idx % #normal_wins) + 1
        vim.api.nvim_set_current_win(normal_wins[next_idx])
    end
end

-- Simple circular window navigation backward (skip explorer)
local function cycle_windows_backward()
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    local normal_wins = {}
    
    -- Get all non-floating, non-explorer windows
    for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        
        -- Skip floating windows and explorer
        if config.relative == "" and ft ~= "snacks_explorer" then
            table.insert(normal_wins, win)
        end
    end
    
    -- If we have multiple windows, cycle through them backward
    if #normal_wins > 1 then
        -- Find current window index
        local current_idx = 1
        for i, win in ipairs(normal_wins) do
            if win == current_win then
                current_idx = i
                break
            end
        end
        
        -- Move to previous window (with wrapping)
        local prev_idx = current_idx - 1
        if prev_idx < 1 then
            prev_idx = #normal_wins
        end
        vim.api.nvim_set_current_win(normal_wins[prev_idx])
    end
end

-- Override Ctrl+H to cycle through ALL windows in order (forward)
vim.keymap.set("n", "<C-h>", cycle_windows, { desc = "Cycle through all windows (forward)" })

-- Override Ctrl+G to cycle through ALL windows in reverse order (backward)
vim.keymap.set("n", "<C-g>", cycle_windows_backward, { desc = "Cycle through all windows (backward)" })

-- Alternative: Use standard vim directional navigation but with fallback
vim.keymap.set("n", "<C-l>", function()
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd l")
    -- If we didn't move, wrap around
    if vim.api.nvim_get_current_win() == current_win then
        vim.cmd("wincmd t")  -- Go to top-left window
    end
end, { desc = "Go right or wrap to first window" })

-- Keep vertical navigation as standard
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {})

-- Disable number + gt tab switching (1gt, 2gt, etc.)
for i = 1, 9 do
  vim.keymap.set("n", i .. "gt", "<Nop>", { desc = "Disabled" })
  vim.keymap.set("n", i .. "gT", "<Nop>", { desc = "Disabled" })
end

-- File Explorer keybindings (never closes, only opens or focuses)
vim.keymap.set("n", "<leader>e", function()
    -- Check if explorer is already open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "snacks_explorer" then
            -- Explorer is open, just focus it
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    
    -- Explorer not open, open it
    if Snacks and Snacks.explorer then
        Snacks.explorer()
    else
        vim.notify("Snacks explorer not available", vim.log.levels.WARN)
    end
end, { desc = "Open/Focus File Explorer" })

-- Save file with <leader>ww
vim.keymap.set("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save file" })

-- Close/quit current window with <leader>wq
vim.keymap.set("n", "<leader>wq", "<cmd>q<CR>", { desc = "Close window" })

-- Equalize window sizes with <leader>we
vim.keymap.set("n", "<leader>we", "<cmd>wincmd =<CR>", { desc = "Equalize window sizes" })

-- Quit Neovim entirely with <leader>qq
vim.keymap.set("n", "<leader>qq", function()
  -- Check if there are any modified buffers
  local modified_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_get_option(buf, "modified")
  end, vim.api.nvim_list_bufs())

  if #modified_buffers > 0 then
    -- Ask user what to do
    local choice = vim.fn.confirm(
      "You have unsaved changes. What would you like to do?",
      "&Save all and quit\n&Discard changes and quit\n&Cancel",
      1
    )

    if choice == 1 then
      -- Save all and quit
      vim.cmd("wa")
      vim.cmd("qa")
    elseif choice == 2 then
      -- Force quit without saving
      vim.cmd("qa!")
    end
    -- If choice == 3 or 0 (canceled), do nothing
  else
    -- No modified buffers, quit normally
    vim.cmd("qa")
  end
end, { desc = "Quit Neovim" })

-- Split current window vertically with buffer picker (includes files and terminal buffers)
vim.keymap.set("n", "<leader>wv", function()
    vim.cmd("vsplit")
    vim.schedule(function()
        if Snacks and Snacks.picker then
            -- Use buffer picker which shows all buffers including terminals
            local current_win = vim.api.nvim_get_current_win()
            Snacks.picker.buffers({
                confirm = function(picker, item)
                    picker:close()
                    vim.schedule(function()
                        vim.api.nvim_set_current_win(current_win)
                        vim.cmd("buffer " .. item.buf)
                    end)
                end
            })
        else
            vim.notify("No picker available", vim.log.levels.WARN)
        end
    end)
end, { desc = "Split window vertically with picker (buffers + terminals)" })

-- Split current window horizontally with file picker
vim.keymap.set("n", "<leader>wh", function()
    vim.cmd("split")
    vim.schedule(function()
        if Snacks and Snacks.picker then
            Snacks.picker.files()
        else
            vim.notify("No file picker available", vim.log.levels.WARN)
        end
    end)
end, { desc = "Split window horizontally with picker" })

-- Focus/jump to file explorer if it's open
vim.keymap.set("n", "<leader>fe", function()
    -- Look for explorer window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "snacks_explorer" then
            -- Explorer found, focus it
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    -- Explorer not open, notify user
    vim.notify("Explorer is not open. Use <leader>e to open it.", vim.log.levels.INFO)
end, { desc = "Focus File Explorer" })

-- Swap 0 and ^ keybindings
vim.keymap.set({ "n", "v" }, "0", "^", { desc = "Go to first non-blank character" })
vim.keymap.set({ "n", "v" }, "^", "0", { desc = "Go to beginning of line" })

-- Make dd delete without copying to clipboard (use black hole register)
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without copying" })
vim.keymap.set("v", "d", '"_d', { desc = "Delete selection without copying" })

-- Select entire buffer (vag) and yank entire buffer (yag)
vim.keymap.set("n", "vag", "ggVG", { desc = "Select entire buffer" })
vim.keymap.set("n", "yag", "ggyG", { desc = "Yank entire buffer" })

-- Override <leader>sg to use current window for live grep
vim.keymap.set("n", "<leader>sg", function()
    if Snacks and Snacks.picker then
        local current_win = vim.api.nvim_get_current_win()
        Snacks.picker.grep({
            confirm = function(picker, item)
                picker:close()
                vim.schedule(function()
                    vim.api.nvim_set_current_win(current_win)
                    -- Use item.pos if available (standard Snacks picker format)
                    if item.pos then
                        vim.cmd("edit +" .. item.pos[1] .. " " .. vim.fn.fnameescape(item.file))
                    else
                        vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                        -- Try multiple field name possibilities
                        local line = item.lnum or item.line or item.pos and item.pos[1] or 1
                        local col = (item.col or item.column or item.pos and item.pos[2] or 1) - 1
                        vim.api.nvim_win_set_cursor(0, {line, col})
                    end
                end)
            end
        })
    else
        vim.notify("No grep picker available", vim.log.levels.WARN)
    end
end, { desc = "Grep (current window)" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Helper function to check if buffer is a Claude terminal
local function is_claude_terminal(bufnr)
    if vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "terminal" then
        return false
    end
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    return string.find(string.lower(buf_name), "claude") ~= nil
end

-- Helper function to check if currently in file explorer
local function is_in_explorer()
    local current_ft = vim.bo.filetype
    return current_ft == "snacks_explorer"
end

-- Helper function to open buffer with smart split logic
local function open_buffer_smart(bufnr)
    if is_claude_terminal(bufnr) then
        -- Open Claude terminal in vertical split on the right
        vim.cmd("vertical rightbelow split")
        vim.api.nvim_set_current_buf(bufnr)
    else
        -- Open normally in current window
        vim.api.nvim_set_current_buf(bufnr)
    end
end

-- Buffer search keymaps (using Snacks picker)
vim.keymap.set("n", "<leader>bf", function()
    -- Don't work in file explorer
    if is_in_explorer() then
        vim.notify("Buffer search disabled in file explorer", vim.log.levels.INFO)
        return
    end

    if Snacks and Snacks.picker then
        Snacks.picker.buffers()
    else
        vim.notify("No buffer picker available", vim.log.levels.WARN)
    end
end, { desc = "Search open buffers" })

-- Quick buffer delete current buffer
vim.keymap.set("n", "<leader>bd", function()
    local buf = vim.api.nvim_get_current_buf()
    local wins = vim.fn.getbufinfo(buf)[1].windows

    -- Check if this is the last window
    if #vim.api.nvim_list_wins() == 1 and #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.notify("Cannot delete the last buffer", vim.log.levels.WARN)
        return
    end

    -- Check if this is a Claude terminal and delete without confirmation
    if is_claude_terminal(buf) then
        -- Try to switch to alternate buffer or previous buffer before deleting
        if #wins > 0 then
            for _, win in ipairs(wins) do
                vim.api.nvim_set_current_win(win)
                vim.cmd("bprevious")
            end
        end
        -- Force delete for terminals
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.notify("Claude terminal deleted", vim.log.levels.INFO)
        return
    end

    -- For non-Claude terminals and regular buffers, delete without confirmation
    local is_terminal = vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"
    
    -- Try to switch to alternate buffer or previous buffer before deleting
    if #wins > 0 then
        for _, win in ipairs(wins) do
            vim.api.nvim_set_current_win(win)
            vim.cmd("bprevious")
        end
    end

    -- Use force for terminals, normal delete for regular buffers
    vim.api.nvim_buf_delete(buf, { force = is_terminal })
    vim.notify("Buffer deleted", vim.log.levels.INFO)
end, { desc = "Delete current buffer" })

-- Move to beginning of text objects (like vi but just moves cursor)
-- This uses a custom function to properly handle text object movements

-- Function to move cursor to beginning of text object
local function move_to_text_object_start(inside, text_obj)
    return function()
        -- Save current position
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Use visual mode to select the text object, then jump to start
        if inside then
            vim.cmd("normal! vi" .. text_obj .. "\x1b`<")
        else
            vim.cmd("normal! va" .. text_obj .. "\x1b`<")
        end
        
        -- If cursor didn't move (text object not found), restore position
        local new_pos = vim.api.nvim_win_get_cursor(0)
        if new_pos[1] == cur_pos[1] and new_pos[2] == cur_pos[2] then
            vim.api.nvim_win_set_cursor(0, cur_pos)
        end
    end
end

-- Define text objects to map
local text_objects = {
    ["b"] = "b", -- brackets/parentheses ()
    ["B"] = "B", -- curly braces {}
    ["]"] = "]", -- square brackets []
    [">"] = ">", -- angle brackets <>
    ["'"] = "'", -- single quotes
    ['"'] = '"', -- double quotes
    ["`"] = "`", -- backticks
    ["t"] = "t", -- tags (HTML/XML)
    ["w"] = "w", -- word
    ["W"] = "W", -- WORD
    ["s"] = "s", -- sentence
    ["p"] = "p", -- paragraph
    ["q"] = '"', -- quotes shortcut
    ["i"] = "i", -- general inside (for things like gii)
}

-- Create keymaps for all text objects using 'gt' prefix (go to beginning)
for key, obj in pairs(text_objects) do
    vim.keymap.set("n", "gti" .. key, move_to_text_object_start(true, obj), 
        { desc = "Move to beginning inside " .. key, silent = true })
    vim.keymap.set("n", "gta" .. key, move_to_text_object_start(false, obj), 
        { desc = "Move to beginning around " .. key, silent = true })
end

-- Git hunks (mini.diff)
vim.keymap.set("n", "]h", function()
  local ok, minidiff = pcall(require, "mini.diff")
  if ok then
    minidiff.goto_hunk("next")
  end
end, { desc = "Next Git Hunk" })

vim.keymap.set("n", "[h", function()
  local ok, minidiff = pcall(require, "mini.diff")
  if ok then
    minidiff.goto_hunk("prev")
  end
end, { desc = "Prev Git Hunk" })

-- Go specific keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        -- Go specific mappings
        vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", { buffer = true, desc = "Go Test" })
        vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { buffer = true, desc = "Go Test Function" })
        vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", { buffer = true, desc = "Go Coverage" })
        vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", { buffer = true, desc = "Go Lint" })
        vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<cr>", { buffer = true, desc = "Go Imports" })
        vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", { buffer = true, desc = "Go Vet" })
    end,
})

-- Python interpreter picker function
local function python_interpreter_picker()
  local telescope = require("telescope")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Function to get Python version from interpreter
  local function get_python_version(python_path)
    local handle = io.popen(python_path .. ' --version 2>&1')
    if handle then
      local result = handle:read("*a")
      handle:close()
      return result:match("Python ([%d%.]+)") or "Unknown"
    end
    return "Unknown"
  end

  -- Function to find Python interpreters (searches repos and workspace)
  local function find_python_interpreters()
    local interpreters = {}
    local cwd = vim.fn.resolve(vim.fn.getcwd())

    -- Find git root from cwd (resolve to canonical path)
    local git_root_cwd = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if git_root_cwd and git_root_cwd ~= "" then
      git_root_cwd = vim.fn.resolve(git_root_cwd)
    end

    -- Also check git root from current buffer's directory (in case file is from different repo)
    local buf_dir = vim.fn.expand("%:p:h")
    local git_root_buf = vim.fn.systemlist("git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
    if git_root_buf and git_root_buf ~= "" then
      git_root_buf = vim.fn.resolve(git_root_buf)
    end

    -- Collect unique search roots (use resolved paths for consistency)
    local search_roots = {}
    if git_root_cwd and git_root_cwd ~= "" then
      search_roots[git_root_cwd] = true
    end
    if git_root_buf and git_root_buf ~= "" and git_root_buf ~= git_root_cwd then
      search_roots[git_root_buf] = true
    end

    -- Also add cwd itself in case git root detection failed
    if not next(search_roots) then
      search_roots[cwd] = true
    end

    -- Debug: show detected paths
    vim.notify("CWD: " .. cwd, vim.log.levels.INFO)
    vim.notify("Git root (cwd): " .. (git_root_cwd or "none"), vim.log.levels.INFO)
    vim.notify("Git root (buf): " .. (git_root_buf or "none"), vim.log.levels.INFO)

    -- 0. Check VIRTUAL_ENV environment variable (currently activated venv)
    local virtual_env = vim.env.VIRTUAL_ENV
    if virtual_env and vim.fn.isdirectory(virtual_env .. "/bin") == 1 then
      local python_path = virtual_env .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        local version = get_python_version(python_path)
        local env_name = vim.fn.fnamemodify(virtual_env, ":t")
        table.insert(interpreters, {
          path = python_path,
          version = version,
          env_name = "ACTIVE: " .. env_name,
          display = string.format("🟢 ACTIVE: %s (Python %s) - %s", env_name, version, python_path),
        })
      end
    end

    -- 1. Homebrew Python installations (python@3.x versions)
    local homebrew_pattern = "/opt/homebrew/Cellar/python@*/*/bin/python3.*"
    local homebrew_matches = vim.fn.glob(homebrew_pattern, false, true)
    for _, path in ipairs(homebrew_matches) do
      if vim.fn.executable(path) == 1 and not path:match("config$") then
        local version = get_python_version(path)
        local python_version = path:match("python@([^/]+)")
        table.insert(interpreters, {
          path = path,
          version = version,
          env_name = "homebrew-" .. python_version,
          display = string.format("Homebrew Python %s (%s) - %s", python_version, version, path),
        })
      end
    end

    -- 2. Find ALL venv/.venv directories recursively within each search root
    for search_root, _ in pairs(search_roots) do
      -- No maxdepth limit - search everything in the repo
      local find_cmd = string.format(
        'find %s -type d \\( -name "venv" -o -name ".venv" \\) 2>/dev/null | head -50',
        vim.fn.shellescape(search_root)
      )

      local venv_dirs = vim.fn.systemlist(find_cmd)

      -- Debug: show what's being searched and found
      vim.notify("Searching: " .. search_root .. " | Found: " .. #venv_dirs .. " venvs", vim.log.levels.INFO)
      for _, vd in ipairs(venv_dirs) do
        vim.notify("  -> " .. vd, vim.log.levels.INFO)
      end

      for _, venv_path in ipairs(venv_dirs) do
        if vim.fn.isdirectory(venv_path .. "/bin") == 1 then
          -- Look for python executable
          local python_path = venv_path .. "/bin/python"
          if vim.fn.executable(python_path) == 1 then
            local version = get_python_version(python_path)
            -- Create relative path from search root for display
            local rel_path = venv_path:sub(#search_root + 2) -- Remove search_root and leading /
            if rel_path == "" then
              rel_path = vim.fn.fnamemodify(venv_path, ":t")
            end
            -- Add repo name prefix if multiple roots
            local repo_name = vim.fn.fnamemodify(search_root, ":t")
            local display_name = rel_path
            if vim.tbl_count(search_roots) > 1 then
              display_name = "[" .. repo_name .. "] " .. rel_path
            end
            table.insert(interpreters, {
              path = python_path,
              version = version,
              env_name = display_name,
              display = string.format("%s (Python %s) - %s", display_name, version, python_path),
            })
          end
        end
      end
    end

    -- 3. Check for poetry virtualenvs
    local poetry_cache = vim.fn.expand("~/Library/Caches/pypoetry/virtualenvs")
    if vim.fn.isdirectory(poetry_cache) == 1 then
      local poetry_envs = vim.fn.glob(poetry_cache .. "/*/bin/python", false, true)
      for _, path in ipairs(poetry_envs) do
        if vim.fn.executable(path) == 1 then
          local version = get_python_version(path)
          local env_name = path:match("virtualenvs/([^/]+)/")
          table.insert(interpreters, {
            path = path,
            version = version,
            env_name = "poetry: " .. (env_name or "unknown"),
            display = string.format("Poetry: %s (Python %s)", env_name or "unknown", version),
          })
        end
      end
    end

    -- Remove duplicates based on resolved path and sort
    local seen = {}
    local unique_interpreters = {}
    for _, interp in ipairs(interpreters) do
      local resolved_path = vim.fn.resolve(interp.path)
      local key = resolved_path
      if not seen[key] then
        seen[key] = true
        table.insert(unique_interpreters, interp)
      end
    end

    table.sort(unique_interpreters, function(a, b)
      -- Active venv first
      if a.env_name:match("^ACTIVE") then return true end
      if b.env_name:match("^ACTIVE") then return false end
      -- Then local venvs (not homebrew/poetry)
      local a_is_local = not a.env_name:match("homebrew") and not a.env_name:match("poetry")
      local b_is_local = not b.env_name:match("homebrew") and not b.env_name:match("poetry")
      if a_is_local and not b_is_local then return true end
      if not a_is_local and b_is_local then return false end
      return a.env_name < b.env_name
    end)

    return unique_interpreters
  end

  -- Function to set Python interpreter for LSP
  local function set_python_interpreter(python_path)
    -- Update Pyright settings
    local clients = vim.lsp.get_clients({ name = "pyright" })
    for _, client in ipairs(clients) do
      if client.config.settings then
        client.config.settings.python = client.config.settings.python or {}
        client.config.settings.python.pythonPath = python_path
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
    end
    
    -- Update global LSP config for future clients
    if vim.lsp.config and vim.lsp.config.pyright then
      vim.lsp.config.pyright.settings = vim.lsp.config.pyright.settings or {}
      vim.lsp.config.pyright.settings.python = vim.lsp.config.pyright.settings.python or {}
      vim.lsp.config.pyright.settings.python.pythonPath = python_path
    end
    
    vim.notify("Python interpreter set to: " .. python_path, vim.log.levels.INFO)
  end

  local interpreters = find_python_interpreters()
  
  if #interpreters == 0 then
    vim.notify("No Python interpreters found", vim.log.levels.WARN)
    return
  end
  
  pickers.new({}, {
    prompt_title = "Select Python Interpreter",
    finder = finders.new_table({
      results = interpreters,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          set_python_interpreter(selection.value.path)
        end
      end)
      return true
    end,
  }):find()
end

-- Python interpreter picker keybinding
vim.keymap.set("n", "<leader>lpp", python_interpreter_picker, { desc = "Pick Python Interpreter" })

-- Previous buffer keybinding
vim.keymap.set("n", "<leader>bb", "<cmd>b#<CR>", { desc = "Go to previous buffer" })

-- Window boilerplate - open terminal and Claude
vim.keymap.set("n", "<leader>wb", function()
    -- Ensure toggleterm is loaded
    local ok, _ = pcall(require, "toggleterm")
    if ok then
        -- Load the buffer module to ensure commands are available
        require("plugins.toggleterm.buffer").setup()
    end
    
    -- Check if commands exist before running them
    if vim.fn.exists(":EnhancedBufferTerm") == 2 then
        vim.cmd("EnhancedBufferTerm")
        vim.schedule(function()
            if vim.fn.exists(":ClaudeVerticalTerm") == 2 then
                vim.cmd("ClaudeVerticalTerm")
            else
                vim.notify("Claude command not available", vim.log.levels.WARN)
            end
        end)
    else
        -- Fallback to basic terminal commands
        vim.cmd("terminal")
        vim.schedule(function()
            vim.cmd("vsplit | terminal claude")
        end)
    end
end, { desc = "Window boilerplate (terminal + Claude)" })

-- Fuzzy search lines in current buffer using telescope (backslash key)
vim.keymap.set('n', '\\', function()
    local builtin = require('telescope.builtin')

    -- Get current buffer info
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.fn.expand('%:t')

    builtin.current_buffer_fuzzy_find({
        prompt_title = "🔍 Search Lines in Current Buffer",
        results_title = "Matches in " .. filename,
        preview_title = "Context Preview",
        layout_strategy = 'horizontal',
        layout_config = {
            preview_width = 0.6,
            width = 0.95,
            height = 0.85,
            prompt_position = "top",
        },
        sorting_strategy = "ascending",
        default_text = "",
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    -- Jump to the selected line and center it
                    vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
                    vim.cmd('normal! zz')
                end
            end)
            return true
        end,
        preview = {
            treesitter = false,  -- Disable treesitter for faster preview
        },
    })
end, { desc = "Fuzzy search in current buffer with context preview" })
