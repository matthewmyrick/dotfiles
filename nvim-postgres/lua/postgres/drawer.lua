-- Drawer UI module - tree view for connections
local M = {}

local connections = require("postgres.connections")
local query = require("postgres.query")

-- State
local state = {
  bufnr = nil,
  winid = nil,
  file_winid = nil, -- Window for file tree
  expanded = {}, -- Track expanded nodes: { [conn_id] = true, [conn_id..":schema"] = true, ... }
  schemas = {}, -- Cache: { [conn_id] = { "public", "other", ... } }
  tables = {}, -- Cache: { [conn_id..":schema"] = { {name, type}, ... } }
  loading = {}, -- Track loading state
}

-- Icons
local icons = {
  connection = "󱘲",
  connection_active = "󱘲",
  schema = "",
  table = "",
  view = "",
  collapsed = "",
  expanded = "",
  add = "",
  loading = "󰔟",
}

-- Highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "PgConnection", { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, "PgConnectionActive", { fg = "#a6e3a1", bold = true })
  vim.api.nvim_set_hl(0, "PgSchema", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "PgTable", { fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "PgView", { fg = "#cba6f7" })
  vim.api.nvim_set_hl(0, "PgAdd", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "PgHeader", { fg = "#cdd6f4", bold = true })
  vim.api.nvim_set_hl(0, "PgIcon", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "PgExpander", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "PgLoading", { fg = "#f9e2af", italic = true })
end

-- Get current line's node data
local function get_line_data(bufnr, line)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  local data = vim.b[bufnr].pg_line_data or {}
  return data[line]
end

-- Render the drawer content
local function render(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  local lines = {}
  local highlights = {}
  local line_data = {}

  -- Header
  table.insert(lines, " PostgreSQL")
  table.insert(highlights, { line = #lines, col = 0, end_col = 15, hl = "PgHeader" })
  table.insert(lines, "")

  -- Connections section
  table.insert(lines, " Connections")
  table.insert(highlights, { line = #lines, col = 0, end_col = 15, hl = "PgHeader" })

  local conns = connections.load()

  if #conns == 0 then
    table.insert(lines, "   No connections")
    table.insert(lines, "   Press 'a' to add one")
  else
    local active_id = connections.get_active_id()

    for _, conn in ipairs(conns) do
      local is_expanded = state.expanded[conn.id]
      local is_active = conn.id == active_id
      local expander = is_expanded and icons.expanded or icons.collapsed
      local icon = is_active and icons.connection_active or icons.connection

      local active_marker = is_active and " ●" or ""
      local line = string.format("  %s %s %s%s", expander, icon, conn.name, active_marker)
      table.insert(lines, line)
      line_data[#lines] = { type = "connection", id = conn.id, name = conn.name }
      table.insert(highlights, { line = #lines, col = 2, end_col = 2 + #expander, hl = "PgExpander" })
      local conn_hl = is_active and "PgConnectionActive" or "PgConnection"
      table.insert(highlights, { line = #lines, col = 2 + #expander + 1, end_col = 2 + #expander + 1 + #icon, hl = is_active and "PgConnectionActive" or "PgIcon" })
      table.insert(highlights, { line = #lines, col = 2 + #expander + 1 + #icon + 1, end_col = #line, hl = conn_hl })

      -- Show schemas if connection is expanded
      if is_expanded then
        local conn_schemas = state.schemas[conn.id]

        if state.loading[conn.id] then
          table.insert(lines, "      " .. icons.loading .. " Loading...")
          table.insert(highlights, { line = #lines, col = 0, end_col = 30, hl = "PgLoading" })
        elseif conn_schemas then
          for _, schema in ipairs(conn_schemas) do
            local schema_key = conn.id .. ":" .. schema
            local schema_expanded = state.expanded[schema_key]
            local schema_expander = schema_expanded and icons.expanded or icons.collapsed

            local schema_line = string.format("     %s %s %s", schema_expander, icons.schema, schema)
            table.insert(lines, schema_line)
            line_data[#lines] = { type = "schema", conn_id = conn.id, schema = schema }
            table.insert(highlights, { line = #lines, col = 5, end_col = 5 + #schema_expander, hl = "PgExpander" })
            table.insert(highlights, { line = #lines, col = 5 + #schema_expander + 1, end_col = 5 + #schema_expander + 1 + #icons.schema, hl = "PgSchema" })
            table.insert(highlights, { line = #lines, col = 5 + #schema_expander + 1 + #icons.schema + 1, end_col = #schema_line, hl = "PgSchema" })

            -- Show tables if schema is expanded
            if schema_expanded then
              local schema_tables = state.tables[schema_key]

              if state.loading[schema_key] then
                table.insert(lines, "         " .. icons.loading .. " Loading...")
                table.insert(highlights, { line = #lines, col = 0, end_col = 35, hl = "PgLoading" })
              elseif schema_tables then
                for _, tbl in ipairs(schema_tables) do
                  local tbl_icon = tbl.type == "VIEW" and icons.view or icons.table
                  local tbl_hl = tbl.type == "VIEW" and "PgView" or "PgTable"

                  local tbl_line = string.format("        %s %s", tbl_icon, tbl.name)
                  table.insert(lines, tbl_line)
                  line_data[#lines] = { type = "table", conn_id = conn.id, schema = schema, table = tbl.name, table_type = tbl.type }
                  table.insert(highlights, { line = #lines, col = 8, end_col = #tbl_line, hl = tbl_hl })
                end

                if #schema_tables == 0 then
                  table.insert(lines, "         (no tables)")
                  table.insert(highlights, { line = #lines, col = 0, end_col = 25, hl = "PgLoading" })
                end
              end
            end
          end

          if #conn_schemas == 0 then
            table.insert(lines, "      (no schemas)")
            table.insert(highlights, { line = #lines, col = 0, end_col = 25, hl = "PgLoading" })
          end
        end
      end
    end
  end

  table.insert(lines, "")

  -- Add connection option
  local add_line = string.format(" %s Add Connection", icons.add)
  table.insert(lines, add_line)
  line_data[#lines] = { type = "add" }
  table.insert(highlights, { line = #lines, col = 0, end_col = #add_line, hl = "PgAdd" })

  -- Help hint
  table.insert(lines, "")
  table.insert(lines, " Press ? for help")

  -- Set buffer content
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(bufnr, -1, hl.hl, hl.line - 1, hl.col, hl.end_col)
  end

  -- Store line data
  vim.b[bufnr].pg_line_data = line_data

  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Toggle expand/collapse for a node
local function toggle_node(data)
  if data.type == "connection" then
    local key = data.id
    if state.expanded[key] then
      -- Collapse
      state.expanded[key] = nil
    else
      -- Expand - fetch schemas if not cached
      state.expanded[key] = true

      if not state.schemas[key] then
        state.loading[key] = true
        M.refresh()

        -- Fetch schemas async
        vim.defer_fn(function()
          local conn = connections.get(data.id)
          if conn then
            local schemas, err = query.get_schemas(conn)
            if schemas then
              state.schemas[key] = schemas
            else
              vim.notify("Error fetching schemas: " .. (err or "unknown"), vim.log.levels.ERROR)
              state.schemas[key] = {}
            end
          end
          state.loading[key] = nil
          M.refresh()
        end, 10)
        return
      end
    end
  elseif data.type == "schema" then
    local key = data.conn_id .. ":" .. data.schema
    if state.expanded[key] then
      -- Collapse
      state.expanded[key] = nil
    else
      -- Expand - fetch tables if not cached
      state.expanded[key] = true

      if not state.tables[key] then
        state.loading[key] = true
        M.refresh()

        -- Fetch tables async
        vim.defer_fn(function()
          local conn = connections.get(data.conn_id)
          if conn then
            local tables, err = query.get_tables(conn, data.schema)
            if tables then
              state.tables[key] = tables
            else
              vim.notify("Error fetching tables: " .. (err or "unknown"), vim.log.levels.ERROR)
              state.tables[key] = {}
            end
          end
          state.loading[key] = nil
          M.refresh()
        end, 10)
        return
      end
    end
  end

  M.refresh()
end

-- Set up buffer keymaps
local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

  -- Disable problematic default keymaps
  vim.keymap.set("n", "<C-o>", "<Nop>", opts)
  vim.keymap.set("n", "<C-i>", "<Nop>", opts)

  -- Add connection
  vim.keymap.set("n", "a", function()
    connections.add()
  end, opts)

  -- Edit connection
  vim.keymap.set("n", "e", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local data = get_line_data(bufnr, line)
    if data and data.type == "connection" then
      connections.edit(data.id)
    end
  end, opts)

  -- Delete connection
  vim.keymap.set("n", "dd", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local data = get_line_data(bufnr, line)
    if data and data.type == "connection" then
      vim.ui.select({ "No", "Yes" }, { prompt = "Delete '" .. data.name .. "'?" }, function(choice)
        if choice == "Yes" then
          -- Clear cached data for this connection
          state.expanded[data.id] = nil
          state.schemas[data.id] = nil
          -- Clear all schema expansions for this connection
          for key, _ in pairs(state.expanded) do
            if key:match("^" .. data.id .. ":") then
              state.expanded[key] = nil
            end
          end
          for key, _ in pairs(state.tables) do
            if key:match("^" .. data.id .. ":") then
              state.tables[key] = nil
            end
          end
          connections.delete(data.id)
        end
      end)
    end
  end, opts)

  -- Enter - expand/collapse or add
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local data = get_line_data(bufnr, line)
    if data then
      if data.type == "add" then
        connections.add()
      elseif data.type == "connection" then
        -- Set as active connection and toggle expansion
        connections.set_active(data.id)
        toggle_node(data)
      elseif data.type == "schema" then
        toggle_node(data)
      elseif data.type == "table" then
        -- Set the connection as active and open query
        connections.set_active(data.conn_id)
        M.open_table_query(data)
      end
    end
  end, opts)

  -- 'o' also expands/collapses
  vim.keymap.set("n", "o", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local data = get_line_data(bufnr, line)
    if data then
      if data.type == "connection" or data.type == "schema" then
        toggle_node(data)
      end
    end
  end, opts)

  -- Refresh (also clears cache)
  vim.keymap.set("n", "r", function()
    -- Clear caches to force re-fetch
    state.schemas = {}
    state.tables = {}
    M.refresh()
    vim.notify("Refreshed", vim.log.levels.INFO)
  end, opts)

  -- Close drawer (can reopen with <leader>po)
  vim.keymap.set("n", "q", function()
    M.close()
  end, opts)

  -- Help
  vim.keymap.set("n", "?", function()
    M.show_help()
  end, opts)

  -- Fuzzy search tables with \
  vim.keymap.set("n", "\\", function()
    M.fuzzy_search_tables()
  end, opts)
end

-- Create the drawer buffer
local function create_buffer()
  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "postgres-drawer")
  vim.api.nvim_buf_set_name(bufnr, "postgres://drawer")

  setup_keymaps(bufnr)
  render(bufnr)

  return bufnr
end

-- Open the drawer
function M.open()
  setup_highlights()

  -- Check if already open
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_set_current_win(state.winid)
    return
  end

  -- Create buffer
  state.bufnr = create_buffer()

  -- Create window on the left
  local width = require("postgres").config.drawer_width
  vim.cmd("topleft " .. width .. "vsplit")
  state.winid = vim.api.nvim_get_current_win()

  -- Set buffer to window
  vim.api.nvim_win_set_buf(state.winid, state.bufnr)

  -- Window options
  vim.api.nvim_win_set_option(state.winid, "number", false)
  vim.api.nvim_win_set_option(state.winid, "relativenumber", false)
  vim.api.nvim_win_set_option(state.winid, "signcolumn", "no")
  vim.api.nvim_win_set_option(state.winid, "winfixwidth", true)
  vim.api.nvim_win_set_option(state.winid, "wrap", false)
  vim.api.nvim_win_set_option(state.winid, "cursorline", true)

  -- Split the drawer window horizontally for file tree (bottom half)
  vim.cmd("belowright split")
  state.file_winid = vim.api.nvim_get_current_win()

  -- Set height to roughly half
  local total_height = vim.o.lines - 4 -- Account for statusline, cmdline, etc.
  local conn_height = math.floor(total_height * 0.5)
  vim.api.nvim_win_set_height(state.winid, conn_height)

  -- Window options for file tree window
  vim.api.nvim_win_set_option(state.file_winid, "number", false)
  vim.api.nvim_win_set_option(state.file_winid, "relativenumber", false)
  vim.api.nvim_win_set_option(state.file_winid, "signcolumn", "no")
  vim.api.nvim_win_set_option(state.file_winid, "winfixwidth", true)

  -- Open neo-tree in the file window
  local sql_dir = require("postgres").config.sql_directory
  vim.cmd("Neotree position=current dir=" .. sql_dir)

  -- Go back to connections window
  vim.api.nvim_set_current_win(state.winid)
end

-- Close the drawer
function M.close()
  if state.file_winid and vim.api.nvim_win_is_valid(state.file_winid) then
    vim.api.nvim_win_close(state.file_winid, true)
  end
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  end
  state.winid = nil
  state.bufnr = nil
  state.file_winid = nil
end

-- Toggle the drawer
function M.toggle()
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    M.close()
  else
    M.open()
  end
end

-- Refresh the drawer
function M.refresh()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    render(state.bufnr)
  end
end

-- Get current state
function M.get_state()
  return state
end

-- Fuzzy search tables
function M.fuzzy_search_tables()
  -- Collect all tables from expanded schemas
  local items = {}

  for schema_key, tables in pairs(state.tables) do
    local conn_id, schema = schema_key:match("^(.+):(.+)$")
    if conn_id and schema then
      local conn = connections.get(conn_id)
      local conn_name = conn and conn.name or "unknown"

      for _, tbl in ipairs(tables) do
        -- Format: connection/schema/table
        local display_path = string.format("%s/%s/%s", conn_name, schema, tbl.name)
        table.insert(items, {
          display = display_path,
          schema = schema,
          table = tbl.name,
          conn_id = conn_id,
          conn_name = conn_name,
          type = tbl.type,
        })
      end
    end
  end

  if #items == 0 then
    vim.notify("No tables loaded. Expand a schema first.", vim.log.levels.WARN)
    return
  end

  -- Sort items alphabetically
  table.sort(items, function(a, b)
    return a.display < b.display
  end)

  -- Try to use Telescope if available
  local has_telescope, telescope_pickers = pcall(require, "telescope.pickers")
  if has_telescope then
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    telescope_pickers.new({}, {
      prompt_title = "Search Tables",
      finder = finders.new_table({
        results = items,
        entry_maker = function(entry)
          local icon = entry.type == "VIEW" and icons.view or icons.table
          return {
            value = entry,
            display = string.format("%s %s", icon, entry.display),
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
            M.open_table_query(selection.value)
          end
        end)
        return true
      end,
    }):find()
  else
    -- Fallback to vim.ui.select
    vim.ui.select(items, {
      prompt = "Search tables: ",
      format_item = function(item)
        local icon = item.type == "VIEW" and icons.view or icons.table
        return string.format("%s %s", icon, item.display)
      end,
    }, function(selected)
      if selected then
        M.open_table_query(selected)
      end
    end)
  end
end

-- Open a query file for a table
function M.open_table_query(table_info)
  -- Generate SELECT query for the table
  local sql = string.format("SELECT * FROM %s.%s LIMIT 100;", table_info.schema, table_info.table)

  -- Find or create a buffer for the query
  local sql_dir = require("postgres").config.sql_directory
  local filename = string.format("%s/query_%s_%s.sql", sql_dir, table_info.schema, table_info.table)

  -- Check if file exists, if not create it
  if vim.fn.filereadable(filename) == 0 then
    vim.fn.writefile({ sql }, filename)
  end

  -- Open in the editor pane
  local wins = vim.api.nvim_list_wins()
  local target_win = nil

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if ft ~= "neo-tree" and ft ~= "postgres-drawer" and not buf_name:match("postgres://") then
      target_win = win
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
  else
    vim.cmd("vsplit " .. vim.fn.fnameescape(filename))
  end

  vim.notify(string.format("Opened: %s.%s", table_info.schema, table_info.table), vim.log.levels.INFO)
end

-- Show help floating window
function M.show_help()
  local help_lines = {
    " PostgreSQL Client - Keymaps",
    "",
    " Navigation",
    "  j/k          Move up/down",
    "  <CR>         Expand/collapse or select",
    "  o            Expand/collapse node",
    "  Ctrl+h       Cycle windows forward",
    "  Ctrl+g       Cycle windows backward",
    "",
    " Connections",
    "  a            Add new connection",
    "  e            Edit connection",
    "  dd           Delete connection",
    "  r            Refresh (clear cache)",
    "",
    " Search (global)",
    "  /            Search SQL files",
    "  \\            Search tables",
    "",
    " Queries",
    "  <leader>rr   Run SQL query",
    "  <leader>rt   Toggle results pane",
    "",
    " Files",
    "  <leader>ww   Write file",
    "",
    " Claude",
    "  <leader>tc   Toggle Claude (33% split)",
    "  <leader>wq   Toggle Claude (33% split)",
    "  <Esc><Esc>   Exit terminal mode",
    "",
    " Window",
    "  q            Close drawer/results",
    "  <leader>po   Open drawer",
    "  <leader>pc   Close drawer",
    "  <leader>pt   Toggle drawer",
    "  <leader>q    Quit",
    "  <leader>qq   Force quit",
    "  ?            Show this help",
    "",
    " Press any key to close",
  }

  -- Calculate window size
  local width = 45
  local height = #help_lines

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Center the window
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Set up highlight groups for transparent floating window
  vim.api.nvim_set_hl(0, "PgHelpNormal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "PgHelpBorder", { bg = "NONE", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE", fg = "#89b4fa", bold = true })

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Help ",
    title_pos = "center",
  })

  -- Window options - set winhighlight to use our transparent groups
  vim.api.nvim_win_set_option(win, "winblend", 0)
  vim.api.nvim_win_set_option(win, "cursorline", false)
  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:PgHelpNormal,FloatBorder:PgHelpBorder")

  -- Highlight the header
  vim.api.nvim_buf_add_highlight(buf, -1, "PgHeader", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "PgSchema", 2, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "PgSchema", 7, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "PgSchema", 12, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "PgSchema", 15, 0, -1)

  -- Close on any key press
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  -- Close on any other key
  for _, key in ipairs({ "q", "<CR>", "?", "a", "e", "r", "o", "j", "k", "<Space>" }) do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, nowait = true })
  end
end

return M
