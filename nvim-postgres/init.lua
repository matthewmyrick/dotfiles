-- nvim-postgres: PostgreSQL client for Neovim
-- Custom plugin for managing PostgreSQL connections and queries

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.swapfile = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  checker = {
    enabled = false,
  },
})

-- Load postgres plugin
require("postgres").setup()

-- Highlight on yank (orange)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "YankHighlight",
      timeout = 200,
    })
  end,
})

-- Select entire buffer (vag) and yank entire buffer (yag)
vim.keymap.set("n", "vag", "ggVG", { desc = "Select entire buffer" })
vim.keymap.set("n", "yag", "ggyG", { desc = "Yank entire buffer" })

-- Set the initial buffer to SQL so you can start writing queries immediately
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- Find the main editor buffer (not drawer, not results, not terminal)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        local buftype = vim.bo[buf].buftype
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if ft ~= "postgres-drawer" and ft ~= "postgres-results"
           and buftype ~= "terminal" and not buf_name:match("postgres://")
           and buf_name == "" and ft == "" then
          vim.bo[buf].filetype = "sql"
          vim.api.nvim_buf_set_name(buf, "scratch.sql")
          break
        end
      end
    end)
  end,
})

-- Clean up psql processes, query files, and swap files on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local pid = vim.fn.getpid()
    vim.fn.system("pkill -P " .. pid .. " psql 2>/dev/null")
    pcall(function() require("postgres.connections").set_active(nil) end)
    local sql_dir = require("postgres").config.sql_directory
    vim.fn.system("rm -f " .. vim.fn.shellescape(sql_dir) .. "/query_*.sql")
    vim.fn.system("rm -f " .. vim.fn.shellescape(sql_dir) .. "/.query_*.sw*")
  end,
})

-- Keymaps
vim.keymap.set("n", "<leader>po", function()
  require("postgres.drawer").open()
end, { desc = "Open Postgres drawer" })

vim.keymap.set("n", "<leader>pc", function()
  require("postgres.drawer").close()
end, { desc = "Close Postgres drawer" })

vim.keymap.set("n", "<leader>pt", function()
  require("postgres.drawer").toggle()
end, { desc = "Toggle Postgres drawer" })

vim.keymap.set("n", "<leader>pa", function()
  require("postgres.connections").add()
end, { desc = "Add new connection" })

-- Jump to scratch.sql buffer
vim.keymap.set("n", "<leader>s", function()
  -- Find the scratch buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("scratch%.sql$") then
      -- Find the editor window to show it in
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
        local buftype = vim.bo[vim.api.nvim_win_get_buf(win)].buftype
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if ft ~= "postgres-drawer" and ft ~= "postgres-results"
           and buftype ~= "terminal" and not name:match("postgres://") then
          vim.api.nvim_set_current_win(win)
          vim.api.nvim_set_current_buf(buf)
          return
        end
      end
    end
  end
end, { desc = "Go to scratch.sql" })

-- Ctrl+l - Telescope table picker, pastes schema.table at cursor
vim.keymap.set("n", "<C-l>", function()
  local drawer = require("postgres.drawer")
  local state = drawer.get_state()
  local conn_mod = require("postgres.connections")
  local items = {}

  for schema_key, tables in pairs(state.tables or {}) do
    local conn_id, schema = schema_key:match("^(.+):(.+)$")
    if conn_id and schema then
      for _, tbl in ipairs(tables) do
        local qualified = schema .. "." .. tbl.name
        table.insert(items, { display = qualified, schema = schema, name = tbl.name, type = tbl.type })
      end
    end
  end

  if #items == 0 then
    vim.notify("No tables loaded. Expand a schema in the drawer first.", vim.log.levels.WARN)
    return
  end

  table.sort(items, function(a, b) return a.display < b.display end)

  local has_telescope, telescope_pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local multi_token_sorter = sorters.new({
    scoring_function = function(_, prompt, ordinal)
      if not prompt or prompt == "" then return 0 end
      local lower_ordinal = ordinal:lower()
      for token in prompt:gmatch("%S+") do
        if not lower_ordinal:find(token:lower(), 1, true) then return -1 end
      end
      return 0
    end,
  })

  telescope_pickers.new({}, {
    prompt_title = "Insert Table Name",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        local icon = entry.type == "VIEW" and "" or ""
        return {
          value = entry,
          display = icon .. " " .. entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = multi_token_sorter,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Paste table name at cursor position
          local pos = vim.api.nvim_win_get_cursor(0)
          local line = vim.api.nvim_get_current_line()
          local before = line:sub(1, pos[2])
          local after = line:sub(pos[2] + 1)
          vim.api.nvim_set_current_line(before .. selection.value.display .. after)
          -- Move cursor to end of inserted text
          vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #selection.value.display })
        end
      end)
      return true
    end,
  }):find()
end, { desc = "Insert table name" })

-- Ctrl+k - Find table from FROM line, fetch columns, replace * with column names, then format
vim.keymap.set("n", "<C-k>", function()
  local conn_mod = require("postgres.connections")
  local query_mod = require("postgres.query")
  local active_conn = conn_mod.get_active()

  if not active_conn then
    vim.notify("No active connection. Select one in the drawer first.", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Find the FROM line and extract the table name (formatted SQL has FROM on its own line, table on next)
  local from_table = nil
  for i, line in ipairs(lines) do
    -- Check if this line is "FROM" and next line has the table
    if line:match("^%s*[Ff][Rr][Oo][Mm]%s*$") and lines[i + 1] then
      from_table = vim.trim(lines[i + 1])
      break
    end
    -- Also handle "FROM schema.table" on same line
    local match = line:match("[Ff][Rr][Oo][Mm]%s+([%w_]+%.[%w_]+)")
      or line:match("[Ff][Rr][Oo][Mm]%s+([%w_]+)")
    if match then
      from_table = match
      break
    end
  end

  if not from_table then
    vim.notify("No FROM clause found.", vim.log.levels.WARN)
    return
  end

  -- Clean trailing semicolons, commas, etc.
  from_table = from_table:gsub("[;,]$", "")

  -- Split into schema and table
  local schema, tbl_name = from_table:match("^([%w_]+)%.([%w_]+)$")
  if not schema then
    schema = "public"
    tbl_name = from_table
  end

  -- Fetch columns
  local cols, err = query_mod.get_columns(active_conn, schema, tbl_name)
  if not cols or #cols == 0 then
    vim.notify("Could not fetch columns for " .. from_table .. ": " .. (err or "no columns"), vim.log.levels.WARN)
    return
  end

  -- Build column names (quoted to prevent sql-formatter treating reserved words as keywords)
  local col_names = {}
  local col_lines = {}
  for idx, col in ipairs(cols) do
    local quoted = '"' .. col.name .. '"'
    table.insert(col_names, quoted)
    local suffix = idx < #cols and "," or ""
    table.insert(col_lines, "  " .. quoted .. suffix)
  end

  -- Find the line with * and replace it
  local replaced = false
  for i, line in ipairs(lines) do
    if line:match("^%s*%*%s*$") then
      -- Standalone * line (formatted output)
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, col_lines)
      replaced = true
      break
    end
    if line:match("[Ss][Ee][Ll][Ee][Cc][Tt]%s+%*") then
      -- SELECT * on same line - replace * with columns, keep everything after
      local before_star = line:match("^(.-%s+)%*")
      local after_star = line:match("%*(.*)")
      local col_str = table.concat(col_names, ", ")
      local new_line = before_star .. col_str .. after_star
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })
      replaced = true
      break
    end
  end

  if replaced then
    -- Re-format the buffer
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local sql = table.concat(buf_lines, "\n")
    local formatted = vim.fn.system("sql-formatter --language postgresql", sql)
    if vim.v.shell_error == 0 then
      local fmt_lines = vim.split(formatted, "\n")
      if fmt_lines[#fmt_lines] == "" then
        table.remove(fmt_lines)
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, fmt_lines)
    end
    vim.notify("Expanded columns for " .. schema .. "." .. tbl_name, vim.log.levels.INFO)
  else
    vim.notify("No * found to expand.", vim.log.levels.WARN)
  end
end, { desc = "Expand * to column names" })

vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qq", function()
  -- Kill any stray psql processes spawned by this neovim instance
  local pid = vim.fn.getpid()
  vim.fn.system("pkill -P " .. pid .. " psql 2>/dev/null")
  -- Clear active connection state
  pcall(function() require("postgres.connections").set_active(nil) end)
  -- Delete any query files and swap files from the sql directory
  local sql_dir = require("postgres").config.sql_directory
  vim.fn.system("rm -f " .. vim.fn.shellescape(sql_dir) .. "/query_*.sql")
  vim.fn.system("rm -f " .. vim.fn.shellescape(sql_dir) .. "/.query_*.sw*")
  vim.cmd("qa!")
end, { desc = "Force Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation (cycle through all windows)
local function cycle_windows()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  local normal_wins = {}

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      table.insert(normal_wins, win)
    end
  end

  if #normal_wins > 1 then
    local current_idx = 1
    for i, win in ipairs(normal_wins) do
      if win == current_win then
        current_idx = i
        break
      end
    end
    local next_idx = (current_idx % #normal_wins) + 1
    vim.api.nvim_set_current_win(normal_wins[next_idx])
  end
end

local function cycle_windows_backward()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  local normal_wins = {}

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      table.insert(normal_wins, win)
    end
  end

  if #normal_wins > 1 then
    local current_idx = 1
    for i, win in ipairs(normal_wins) do
      if win == current_win then
        current_idx = i
        break
      end
    end
    local prev_idx = current_idx - 1
    if prev_idx < 1 then
      prev_idx = #normal_wins
    end
    vim.api.nvim_set_current_win(normal_wins[prev_idx])
  end
end

vim.keymap.set("n", "<C-h>", cycle_windows, { desc = "Cycle windows forward" })
vim.keymap.set("n", "<C-g>", cycle_windows_backward, { desc = "Cycle windows backward" })

-- Format SQL
vim.keymap.set("n", "<leader>ff", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "sql" then
    vim.notify("Not an SQL buffer", vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local sql = table.concat(lines, "\n")
  local formatted = vim.fn.system("sql-formatter --language postgresql", sql)
  if vim.v.shell_error ~= 0 then
    vim.notify("sql-formatter error: " .. formatted, vim.log.levels.ERROR)
    return
  end
  local new_lines = vim.split(formatted, "\n")
  -- Remove trailing empty line if present
  if new_lines[#new_lines] == "" then
    table.remove(new_lines)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
  vim.notify("Formatted SQL", vim.log.levels.INFO)
end, { desc = "Format SQL" })

-- Global fuzzy search for tables with /
vim.keymap.set("n", "/", function()
  require("postgres.drawer").fuzzy_search_tables()
end, { desc = "Search tables" })

-- Fuzzy search lines in current buffer with backslash
vim.keymap.set("n", "\\", function()
  local builtin = require("telescope.builtin")
  local filename = vim.fn.expand("%:t")

  builtin.current_buffer_fuzzy_find({
    prompt_title = "Search Lines in Current Buffer",
    results_title = "Matches in " .. filename,
    preview_title = "Context Preview",
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.6,
      width = 0.95,
      height = 0.85,
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    default_text = "",
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)
      return true
    end,
    preview = {
      treesitter = false,
    },
  })
end, { desc = "Fuzzy search in current buffer" })

-- Quick queries picker with <leader><leader>
vim.keymap.set("n", "<leader><leader>", function()
  local pg_config = require("postgres").config
  local has_telescope, telescope_pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- Scan multiple query directories
  local query_sources = {
    { dir = pg_config.queries_directory, group = "PostgreSQL" },
    { dir = pg_config.procrastinate_queries_directory, group = "Procrastinate" },
  }

  local items = {}
  for _, source in ipairs(query_sources) do
    local files = vim.fn.globpath(source.dir, "*.sql", false, true)
    for _, filepath in ipairs(files) do
      local filename = vim.fn.fnamemodify(filepath, ":t:r")
      -- Strip leading numbers and underscores (e.g. "01_queue_overview" -> "queue overview")
      local clean = filename:gsub("^%d+_", "")
      -- Convert kebab-case and underscores to Title Case
      local display_name = clean:gsub("[_-]", " "):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest
      end)
      table.insert(items, {
        display = display_name,
        path = filepath,
        group = source.group,
      })
    end
  end

  if #items == 0 then
    vim.notify("No query files found", vim.log.levels.WARN)
    return
  end

  table.sort(items, function(a, b)
    if a.group ~= b.group then return a.group < b.group end
    return a.display < b.display
  end)

  telescope_pickers.new({}, {
    prompt_title = "Quick Queries",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("[%s]  %s", entry.group, entry.display),
          ordinal = entry.group .. " " .. entry.display,
          path = entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "SQL Preview",
      define_preview = function(self, entry)
        local lines = vim.fn.readfile(entry.path)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.bo[self.state.bufnr].filetype = "sql"
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Find or create an editor window
          local wins = vim.api.nvim_list_wins()
          local target_win = nil
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            local buftype = vim.bo[buf].buftype
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if ft ~= "postgres-drawer" and ft ~= "postgres-results"
               and buftype ~= "terminal" and not buf_name:match("postgres://") then
              target_win = win
            end
          end

          local buf_name = selection.value.display .. ".sql"

          -- Check if a buffer with this name already exists
          local existing_buf = nil
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b):match("[^/]+$") == buf_name then
              existing_buf = b
              break
            end
          end

          -- Format SQL and load into buffer
          local function set_buf_content(buf, sql_content)
            -- Format with sql-formatter
            local formatted = vim.fn.system("sql-formatter --language postgresql", sql_content)
            if vim.v.shell_error ~= 0 then
              formatted = sql_content
            end
            local lines = vim.split(formatted, "\n")
            if lines[#lines] == "" then
              table.remove(lines)
            end
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].filetype = "sql"
            vim.bo[buf].modified = false
            if target_win then
              vim.api.nvim_set_current_win(target_win)
            end
            vim.api.nvim_set_current_buf(buf)
          end

          local function load_query(buf)
            local raw_lines = vim.fn.readfile(selection.path)
            local content = table.concat(raw_lines, "\n")

            -- Find all <PLACEHOLDER> patterns
            local placeholders = {}
            local seen_ph = {}
            for ph in content:gmatch("<([%w_]+)>") do
              if not seen_ph[ph] then
                seen_ph[ph] = true
                table.insert(placeholders, ph)
              end
            end

            -- If there are placeholders, prompt for each one
            if #placeholders > 0 then
              local idx = 1
              local function prompt_next()
                if idx > #placeholders then
                  set_buf_content(buf, content)
                  return
                end
                local ph = placeholders[idx]
                local display_ph = ph:gsub("_", " ")
                local value = vim.fn.input(display_ph .. ": ")
                if value and value ~= "" then
                  content = content:gsub("<" .. ph .. ">", value)
                end
                idx = idx + 1
                vim.schedule(prompt_next)
              end
              prompt_next()
            else
              set_buf_content(buf, content)
            end
          end

          if existing_buf then
            -- Buffer exists - check if it has unsaved changes
            if vim.bo[existing_buf].modified then
              local function prompt_overwrite()
                local answer = vim.fn.input("'" .. buf_name .. "' has unsaved changes. Overwrite? (1=Yes, 2=No): ")
                if answer == "1" then
                  load_query(existing_buf)
                elseif answer == "2" then
                  -- Just switch to the existing buffer without overwriting
                  if target_win then
                    vim.api.nvim_set_current_win(target_win)
                  end
                  vim.api.nvim_set_current_buf(existing_buf)
                else
                  -- Invalid input, re-prompt
                  vim.notify("Invalid input. Please enter 1 or 2.", vim.log.levels.WARN)
                  vim.schedule(prompt_overwrite)
                end
              end
              prompt_overwrite()
            else
              -- No unsaved changes, just reload
              load_query(existing_buf)
            end
          else
            -- Create new buffer
            local buf = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf, buf_name)
            load_query(buf)
          end
        end
      end)
      return true
    end,
  }):find()
end, { desc = "Quick queries" })

-- Claude terminal helper functions
local function set_terminal_name(name)
  if name == "" or name == nil then
    name = "terminal"
  end
  local base_name = name
  local counter = 1
  local full_name = "$ " .. name

  local existing_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" then
        local filename = vim.fn.fnamemodify(buf_name, ":t")
        existing_buffers[filename] = true
      end
    end
  end

  while existing_buffers[full_name] do
    counter = counter + 1
    full_name = "$ " .. base_name .. " " .. counter
  end

  vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

local function create_claude_terminal(use_continue)
  local nvm_dir = vim.fn.expand("$HOME/.nvm")
  local node_version = vim.fn.system("source " .. nvm_dir .. "/nvm.sh && nvm current"):gsub("%s+", "")
  local claude_path = nvm_dir .. "/versions/node/" .. node_version .. "/bin/claude"

  local claude_cmd
  if vim.fn.filereadable(claude_path) == 1 then
    claude_cmd = claude_path .. (use_continue and " --continue" or "")
  else
    claude_cmd = "claude" .. (use_continue and " --continue" or "")
  end

  vim.cmd("terminal " .. claude_cmd)

  vim.schedule(function()
    set_terminal_name("claude")
  end)

  if use_continue then
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for _, line in ipairs(lines) do
              if line:match("No conversation found") then
                vim.cmd("terminal " .. (vim.fn.filereadable(claude_path) == 1 and claude_path or "claude"))
                vim.schedule(function()
                  set_terminal_name("claude")
                end)
                vim.notify("No previous conversation found, started new Claude session", vim.log.levels.INFO)
                return
              end
            end
          end)
        end
      })
    end)
  end
end

local function find_claude_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" then
        local filename = vim.fn.fnamemodify(buf_name, ":t")
        if filename == "$ claude" then
          return buf
        end
      end
    end
  end
  return nil
end

-- Claude vertical terminal command (toggle)
vim.api.nvim_create_user_command("ClaudeVerticalTerm", function()
  local claude_buf = find_claude_buffer()

  -- Check if Claude window is currently open
  if claude_buf then
    local claude_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == claude_buf then
        claude_win = win
        break
      end
    end

    if claude_win then
      -- Claude window is open - close it
      vim.api.nvim_win_close(claude_win, false)
      return
    end
  end

  -- Calculate 33% of total editor width (not current window)
  local total_width = vim.o.columns
  local third_width = math.floor(total_width * 0.33)

  -- Find the main editor window (not postgres-drawer, not results)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if ft ~= "postgres-drawer" and ft ~= "postgres-results" and not buf_name:match("postgres://") then
      target_win = win
      break
    end
  end

  if claude_buf then
    -- Claude buffer exists but window is closed - reopen it
    if target_win then
      vim.api.nvim_set_current_win(target_win)
    end
    vim.cmd("botright vsplit")
    vim.cmd("vertical resize " .. third_width)
    vim.api.nvim_set_current_buf(claude_buf)
    return
  end

  -- No Claude buffer - create new one
  if target_win then
    vim.api.nvim_set_current_win(target_win)
  end
  vim.cmd("botright vsplit")
  vim.cmd("vertical resize " .. third_width)
  -- Start fresh Claude session (no --continue)
  create_claude_terminal(false)
end, { nargs = 0, desc = "Toggle Claude in 33% Vertical Split" })

-- Claude close-only command (for <leader>wq - only closes, never opens)
vim.api.nvim_create_user_command("ClaudeCloseTerm", function()
  local claude_buf = find_claude_buffer()

  if claude_buf then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == claude_buf then
        vim.api.nvim_win_close(win, false)
        return
      end
    end
  end
  -- If Claude window is not open, do nothing (don't reopen it)
end, { nargs = 0, desc = "Close Claude panel (if open)" })

-- Claude terminal keymaps
vim.keymap.set("n", "<leader>tc", "<cmd>ClaudeVerticalTerm<CR>", { desc = "Toggle Claude (33% split)" })
vim.keymap.set("n", "<leader>wq", "<cmd>ClaudeCloseTerm<CR>", { desc = "Close Claude panel" })

-- Run SQL query (format first, then execute)
vim.keymap.set("n", "<leader>rr", function()
  -- Format before running
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "sql" then
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local sql = table.concat(lines, "\n")
    local formatted = vim.fn.system("sql-formatter --language postgresql", sql)
    if vim.v.shell_error == 0 then
      local new_lines = vim.split(formatted, "\n")
      if new_lines[#new_lines] == "" then
        table.remove(new_lines)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
    end
  end

  local query = require("postgres.query")
  local results_pane = require("postgres.results")

  local results, err, conn_name = query.run_buffer_sql()
  if err then
    results_pane.display(nil, err, nil)
  else
    results_pane.display(results, nil, conn_name)
  end
end, { desc = "Run SQL query" })

-- Toggle results pane
vim.keymap.set("n", "<leader>rt", function()
  require("postgres.results").toggle()
end, { desc = "Toggle results pane" })
