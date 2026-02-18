-- Results pane module - displays query results in a horizontal split
local M = {}

local connections = require("postgres.connections")
local query = require("postgres.query")

-- State
local state = {
  bufnr = nil,
  winid = nil,
  last_query = nil,
  last_results = nil,
  visible = false,
  data_start_line = nil, -- Line number where data rows start (after header + separator)
}

-- Setup highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "PgResultsHeader", { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, "PgResultsRow", { fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "PgResultsRowAlt", { fg = "#bac2de" })
  vim.api.nvim_set_hl(0, "PgResultsNull", { fg = "#6c7086", italic = true })
  vim.api.nvim_set_hl(0, "PgResultsBorder", { fg = "#45475a" })
  vim.api.nvim_set_hl(0, "PgResultsInfo", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "PgResultsError", { fg = "#f38ba8" })
end

-- Format results as a table
local function format_results(columns, rows)
  if not columns or #columns == 0 then
    return { "No results" }
  end

  local lines = {}
  local col_widths = {}

  -- Calculate column widths
  for i, col in ipairs(columns) do
    col_widths[i] = #col
  end

  for _, row in ipairs(rows) do
    for i, val in ipairs(row) do
      local str_val = val == nil and "NULL" or tostring(val)
      col_widths[i] = math.max(col_widths[i] or 0, #str_val)
    end
  end

  -- Cap column widths at 50 chars
  for i, width in ipairs(col_widths) do
    col_widths[i] = math.min(width, 50)
  end

  -- Build header
  local header_parts = {}
  for i, col in ipairs(columns) do
    local padded = col .. string.rep(" ", col_widths[i] - #col)
    table.insert(header_parts, padded)
  end
  table.insert(lines, " " .. table.concat(header_parts, " │ "))

  -- Build separator
  local sep_parts = {}
  for i, width in ipairs(col_widths) do
    table.insert(sep_parts, string.rep("─", width))
  end
  table.insert(lines, " " .. table.concat(sep_parts, "─┼─"))

  -- Build rows
  for _, row in ipairs(rows) do
    local row_parts = {}
    for i, val in ipairs(row) do
      local str_val = val == nil and "NULL" or tostring(val)
      -- Truncate long values
      if #str_val > col_widths[i] then
        str_val = str_val:sub(1, col_widths[i] - 3) .. "..."
      end
      local padded = str_val .. string.rep(" ", col_widths[i] - #str_val)
      table.insert(row_parts, padded)
    end
    table.insert(lines, " " .. table.concat(row_parts, " │ "))
  end

  return lines
end

-- Truncate SQL for display (single line, max chars)
local function truncate_sql(sql, max_len)
  max_len = max_len or 60
  -- Replace newlines with spaces and collapse multiple spaces
  local one_line = sql:gsub("[\r\n]+", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
  if #one_line > max_len then
    return one_line:sub(1, max_len - 3) .. "..."
  end
  return one_line
end

-- Render results to buffer
local function render(results, error_msg, query_info)
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)

  local lines = {}
  local highlights = {}

  -- Header with connection and query info
  if query_info and type(query_info) == "table" then
    table.insert(lines, string.format(" 󱘲 %s  %s", query_info.connection or "unknown", query_info.database or ""))
    table.insert(highlights, { line = #lines, hl = "PgResultsInfo" })
    table.insert(lines, string.format("  %s", truncate_sql(query_info.sql or "", 80)))
    table.insert(highlights, { line = #lines, hl = "PgResultsHeader" })
    table.insert(lines, "")
  elseif query_info then
    -- Legacy string format
    table.insert(lines, string.format(" Query Results - %s", query_info))
    table.insert(highlights, { line = 1, hl = "PgResultsInfo" })
    table.insert(lines, "")
  end

  if error_msg then
    table.insert(lines, " Error:")
    table.insert(highlights, { line = #lines, hl = "PgResultsError" })
    for err_line in error_msg:gmatch("[^\r\n]+") do
      table.insert(lines, "   " .. err_line)
      table.insert(highlights, { line = #lines, hl = "PgResultsError" })
    end
  elseif results then
    local formatted = format_results(results.columns, results.rows)
    -- Track where data rows start (after header + separator, which are first 2 lines of formatted)
    state.data_start_line = #lines + 3  -- Current lines + header + separator + 1 for next row
    for i, line in ipairs(formatted) do
      table.insert(lines, line)
      if i == 1 then
        table.insert(highlights, { line = #lines, hl = "PgResultsHeader" })
      elseif i == 2 then
        table.insert(highlights, { line = #lines, hl = "PgResultsBorder" })
      else
        local hl = (i % 2 == 0) and "PgResultsRow" or "PgResultsRowAlt"
        table.insert(highlights, { line = #lines, hl = hl })
      end
    end

    table.insert(lines, "")
    local row_count = results.rows and #results.rows or 0
    table.insert(lines, string.format(" %d row(s) returned  │  Enter/i view │ e edit", row_count))
    table.insert(highlights, { line = #lines, hl = "PgResultsInfo" })
  else
    table.insert(lines, " No results to display")
    table.insert(lines, " Run a query with <leader>rr")
  end

  -- Footer with keymaps
  table.insert(lines, "")
  table.insert(lines, " q close │ Enter/i inspect row │ <leader>rt toggle")

  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.bufnr, -1, hl.hl, hl.line - 1, 0, -1)
  end

  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
end

-- Try to detect and pretty-print JSON
local function try_format_json(str)
  -- Quick check if it looks like JSON
  local trimmed = str:match("^%s*(.-)%s*$")
  if not (trimmed:match("^%{") or trimmed:match("^%[")) then
    return nil, false
  end

  -- Try to decode and re-encode with indentation
  local ok, decoded = pcall(vim.json.decode, trimmed)
  if not ok then
    return nil, false
  end

  -- Re-encode with indentation
  local function indent_json(obj, level)
    level = level or 0
    local indent = string.rep("  ", level)
    local next_indent = string.rep("  ", level + 1)

    if type(obj) == "table" then
      local is_array = vim.tbl_islist(obj)
      local parts = {}

      if is_array then
        if #obj == 0 then
          return "[]"
        end
        for _, v in ipairs(obj) do
          table.insert(parts, next_indent .. indent_json(v, level + 1))
        end
        return "[\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "]"
      else
        if vim.tbl_isempty(obj) then
          return "{}"
        end
        local keys = vim.tbl_keys(obj)
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, k in ipairs(keys) do
          local v = obj[k]
          table.insert(parts, next_indent .. '"' .. tostring(k) .. '": ' .. indent_json(v, level + 1))
        end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
      end
    elseif type(obj) == "string" then
      local escaped = obj:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
      return '"' .. escaped .. '"'
    elseif type(obj) == "number" or type(obj) == "boolean" then
      return tostring(obj)
    elseif obj == vim.NIL or obj == nil then
      return "null"
    else
      return '"' .. tostring(obj) .. '"'
    end
  end

  local formatted = indent_json(decoded, 0)
  return formatted, true
end

-- Show full row details in a floating window
local function show_row_details()
  if not state.last_results or not state.last_results.rows or not state.last_results.columns then
    vim.notify("No results to inspect", vim.log.levels.WARN)
    return
  end

  if not state.data_start_line then
    vim.notify("No data rows available", vim.log.levels.WARN)
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local row_index = cursor_line - state.data_start_line + 1

  if row_index < 1 or row_index > #state.last_results.rows then
    vim.notify("Move cursor to a data row and press Enter", vim.log.levels.INFO)
    return
  end

  local row = state.last_results.rows[row_index]
  local columns = state.last_results.columns

  -- Build content - simple clean format
  local lines = {}
  local json_regions = {}

  table.insert(lines, string.format(" Row %d of %d", row_index, #state.last_results.rows))
  table.insert(lines, " " .. string.rep("═", 90))
  table.insert(lines, "")

  for i, col in ipairs(columns) do
    local val = row[i]
    local str_val = val == nil and "NULL" or tostring(val)
    local is_null = val == nil

    -- Column name as header
    table.insert(lines, " " .. col .. ":")

    if is_null then
      table.insert(lines, "   (null)")
    else
      -- Try JSON formatting
      local json_formatted, was_json = try_format_json(str_val)

      if was_json then
        local value_start = #lines + 1
        for json_line in json_formatted:gmatch("[^\n]+") do
          table.insert(lines, "   " .. json_line)
        end
        table.insert(json_regions, { start = value_start, stop = #lines })
      else
        -- Regular value - just show it, let it scroll horizontally
        table.insert(lines, "   " .. str_val)
      end
    end

    table.insert(lines, "")
  end

  table.insert(lines, " " .. string.rep("─", 50))
  table.insert(lines, " q close │ j/k scroll │ h/l horizontal scroll")

  -- Window size
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.85))
  local row_pos = math.floor((vim.o.lines - height) / 2)
  local col_pos = math.floor((vim.o.columns - width) / 2)

  -- Create buffer with JSON filetype for syntax highlighting
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row_pos,
    col = col_pos,
    style = "minimal",
    border = "rounded",
    title = " Row Details ",
    title_pos = "center",
  })

  -- Window options - allow horizontal scrolling
  vim.api.nvim_set_option_value("winblend", 0, { win = win })
  vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:FloatBorder", { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("sidescrolloff", 5, { win = win })

  -- Highlights
  vim.api.nvim_set_hl(0, "PgColumnName", { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, "PgNullValue", { fg = "#6c7086", italic = true })
  vim.api.nvim_set_hl(0, "PgJsonKey", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "PgJsonString", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "PgJsonNumber", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "PgJsonBool", { fg = "#cba6f7" })
  vim.api.nvim_set_hl(0, "PgJsonNull", { fg = "#6c7086", italic = true })
  vim.api.nvim_set_hl(0, "PgJsonBracket", { fg = "#89dceb" })

  local ns = vim.api.nvim_create_namespace("pg_row_details")

  -- Apply highlights
  for i, line in ipairs(lines) do
    local line_idx = i - 1

    if line:match("^ Row %d+") then
      vim.api.nvim_buf_add_highlight(buf, ns, "PgResultsInfo", line_idx, 0, -1)
    elseif line:match("^═") or line:match("^ ═") or line:match("^ ─") then
      vim.api.nvim_buf_add_highlight(buf, ns, "PgResultsBorder", line_idx, 0, -1)
    elseif line:match("^%s+%(null%)") then
      vim.api.nvim_buf_add_highlight(buf, ns, "PgNullValue", line_idx, 0, -1)
    elseif line:match("^%s[%w_]+:$") then
      vim.api.nvim_buf_add_highlight(buf, ns, "PgColumnName", line_idx, 0, -1)
    end
  end

  -- Apply JSON highlighting to JSON regions
  for _, region in ipairs(json_regions) do
    for line_num = region.start, region.stop do
      local line = lines[line_num]
      if line then
        local line_idx = line_num - 1

        -- Find all patterns and highlight them
        -- Keys: "something":
        local pos = 1
        while pos <= #line do
          -- Look for "key":
          local key_start, key_end = line:find('"[^"]+"%s*:', pos)
          if key_start then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonKey", line_idx, key_start - 1, key_end)
            pos = key_end + 1
          else
            break
          end
        end

        -- Strings (not keys) - values after :
        pos = 1
        while pos <= #line do
          local val_start, val_end = line:find(':%s*"[^"]*"', pos)
          if val_start then
            local str_start = line:find('"', val_start + 1)
            if str_start then
              vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonString", line_idx, str_start - 1, val_end)
            end
            pos = val_end + 1
          else
            break
          end
        end

        -- Numbers
        for num in line:gmatch(':%s*(%-?%d+%.?%d*)') do
          local s, e = line:find(num, 1, true)
          if s then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonNumber", line_idx, s - 1, e)
          end
        end

        -- true/false/null
        for s, e in line:gmatch('()true()') do
          if type(s) == "number" then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonBool", line_idx, s - 1, e - 1)
          end
        end
        for s, e in line:gmatch('()false()') do
          if type(s) == "number" then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonBool", line_idx, s - 1, e - 1)
          end
        end
        for s, e in line:gmatch('()null()') do
          if type(s) == "number" then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonNull", line_idx, s - 1, e - 1)
          end
        end

        -- Brackets
        for bracket_pos in line:gmatch('()[%[%]{}]') do
          if type(bracket_pos) == "number" then
            vim.api.nvim_buf_add_highlight(buf, ns, "PgJsonBracket", line_idx, bracket_pos - 1, bracket_pos)
          end
        end
      end
    end
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Keymaps
  local opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, opts)
  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, close_opts)
end

-- Edit a cell value - simple floating pane
local function edit_cell()
  if not state.last_results or not state.last_results.rows or not state.last_results.columns then
    vim.notify("No results to edit", vim.log.levels.WARN)
    return
  end

  if not state.data_start_line then
    vim.notify("No data rows available", vim.log.levels.WARN)
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local row_index = cursor_line - state.data_start_line + 1

  if row_index < 1 or row_index > #state.last_results.rows then
    vim.notify("Move cursor to a data row and press e", vim.log.levels.INFO)
    return
  end

  local row = state.last_results.rows[row_index]
  local columns = state.last_results.columns

  -- Try to extract table name from query
  local table_name = nil
  if state.last_query and state.last_query.sql then
    table_name = state.last_query.sql:match("[Ff][Rr][Oo][Mm]%s+([%w_%.\"]+)")
    if table_name then
      table_name = table_name:gsub('"', '')
    end
  end

  if not table_name then
    vim.notify("Could not determine table name. Use simple SELECT FROM query.", vim.log.levels.ERROR)
    return
  end

  -- Find primary key column (assume 'id' or first column)
  local pk_col_idx = 1
  local pk_col_name = columns[1]
  for idx, col in ipairs(columns) do
    if col:lower() == "id" then
      pk_col_idx = idx
      pk_col_name = col
      break
    end
  end

  local pk_value = row[pk_col_idx]
  if not pk_value or pk_value == "" then
    vim.notify("Primary key value is empty. Cannot edit.", vim.log.levels.ERROR)
    return
  end

  -- Show column picker
  vim.ui.select(columns, {
    prompt = "Select column to edit:",
    format_item = function(col)
      local idx = 1
      for j, c in ipairs(columns) do
        if c == col then idx = j break end
      end
      local val = row[idx] or ""
      if #val > 40 then val = val:sub(1, 37) .. "..." end
      return col .. ": " .. val
    end,
  }, function(selected_col)
    if not selected_col then return end

    local col_idx = 1
    for idx, col in ipairs(columns) do
      if col == selected_col then col_idx = idx break end
    end

    local current_value = row[col_idx] or ""
    local is_json = false

    -- Try to format JSON
    local display_value = current_value
    if current_value:match("^%s*[%{%[]") then
      local ok, decoded = pcall(vim.json.decode, current_value)
      if ok then
        is_json = true
        display_value = vim.fn.json_encode(decoded)
        -- Pretty print using external or manual
        local formatted = {}
        local indent = 0
        local in_string = false
        local i = 1
        local line = ""

        while i <= #display_value do
          local c = display_value:sub(i, i)

          if c == '"' and display_value:sub(i-1, i-1) ~= '\\' then
            in_string = not in_string
            line = line .. c
          elseif not in_string then
            if c == '{' or c == '[' then
              line = line .. c
              table.insert(formatted, string.rep("  ", indent) .. line)
              indent = indent + 1
              line = ""
            elseif c == '}' or c == ']' then
              if #line > 0 then
                table.insert(formatted, string.rep("  ", indent) .. line)
                line = ""
              end
              indent = indent - 1
              table.insert(formatted, string.rep("  ", indent) .. c)
            elseif c == ',' then
              line = line .. c
              table.insert(formatted, string.rep("  ", indent) .. line)
              line = ""
            elseif c == ':' then
              line = line .. ": "
            elseif c ~= ' ' and c ~= '\n' and c ~= '\r' and c ~= '\t' then
              line = line .. c
            end
          else
            line = line .. c
          end
          i = i + 1
        end
        if #line > 0 then
          table.insert(formatted, string.rep("  ", indent) .. line)
        end
        display_value = table.concat(formatted, "\n")
      end
    end

    -- Create buffer with value
    local edit_buf = vim.api.nvim_create_buf(false, true)
    local lines = {}
    for line in display_value:gmatch("([^\n]*)") do
      table.insert(lines, line)
    end
    -- Remove trailing empty lines but keep at least one
    while #lines > 1 and lines[#lines] == "" do
      table.remove(lines)
    end
    if #lines == 0 then lines = { "" } end

    vim.api.nvim_buf_set_lines(edit_buf, 0, -1, false, lines)

    if is_json then
      vim.api.nvim_buf_set_option(edit_buf, "filetype", "json")
    end

    -- Window size - 80% of screen
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.min(math.max(#lines + 2, 10), math.floor(vim.o.lines * 0.8))
    local win_row = math.floor((vim.o.lines - height) / 2)
    local win_col = math.floor((vim.o.columns - width) / 2)

    local edit_win = vim.api.nvim_open_win(edit_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = win_row,
      col = win_col,
      style = "minimal",
      border = "rounded",
      title = string.format(" Edit: %s.%s ", table_name, selected_col),
      title_pos = "center",
      footer = " i insert │ <leader>w save │ q cancel ",
      footer_pos = "center",
    })

    vim.api.nvim_set_option_value("winblend", 0, { win = edit_win })
    vim.api.nvim_set_option_value("wrap", true, { win = edit_win })
    vim.api.nvim_set_option_value("number", true, { win = edit_win })
    vim.api.nvim_set_option_value("cursorline", true, { win = edit_win })

    local opts = { buffer = edit_buf, noremap = true, silent = true }

    -- Close without saving
    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(edit_win, true)
    end, opts)

    -- Save changes
    vim.keymap.set("n", "<leader>w", function()
      local new_lines = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)
      local new_value = table.concat(new_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")

      -- Validate JSON if it was JSON
      if is_json then
        local ok, err = pcall(vim.json.decode, new_value)
        if not ok then
          vim.notify("Invalid JSON: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        -- Compact the JSON for storage
        local decoded = vim.json.decode(new_value)
        new_value = vim.json.encode(decoded)
      end

      -- Escape for SQL
      local escaped = new_value:gsub("'", "''")

      local update_sql = string.format(
        "UPDATE %s SET %s = '%s' WHERE %s = '%s'",
        table_name, selected_col, escaped,
        pk_col_name, tostring(pk_value):gsub("'", "''")
      )

      -- Execute update
      local active_conn = connections.get_active()
      if not active_conn then
        vim.notify("No active connection", vim.log.levels.ERROR)
        return
      end

      local _, err = query.execute(active_conn, update_sql)
      if err then
        vim.notify("Update failed: " .. tostring(err), vim.log.levels.ERROR)
      else
        vim.notify("Updated " .. table_name .. "." .. selected_col .. " successfully!", vim.log.levels.INFO)
        vim.api.nvim_win_close(edit_win, true)

        -- Refresh results
        if state.last_query and state.last_query.sql then
          local results = query.execute_with_headers(active_conn, state.last_query.sql)
          if results then
            M.display(results, nil, state.last_query)
          end
        end
      end
    end, opts)
  end)
end

-- Setup keymaps for results buffer
local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

  -- Close results
  vim.keymap.set("n", "q", function()
    M.hide()
  end, opts)

  -- Inspect row (show full details)
  vim.keymap.set("n", "<CR>", show_row_details, opts)
  vim.keymap.set("n", "i", show_row_details, opts)

  -- Edit cell
  vim.keymap.set("n", "e", edit_cell, opts)

  -- Scroll
  vim.keymap.set("n", "<C-d>", "<C-d>", opts)
  vim.keymap.set("n", "<C-u>", "<C-u>", opts)
end

-- Create the results buffer
local function create_buffer()
  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "postgres-results")
  vim.api.nvim_buf_set_name(bufnr, "postgres://results")

  setup_keymaps(bufnr)

  return bufnr
end

-- Show the results pane
function M.show()
  setup_highlights()

  -- Check if already visible
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_set_current_win(state.winid)
    return
  end

  -- Create buffer if needed
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = create_buffer()
  end

  -- Find the editor window (main buffer only, not side panels or terminals)
  local target_win = nil
  local wins = vim.api.nvim_list_wins()

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buftype = vim.bo[buf].buftype
    local buf_name = vim.api.nvim_buf_get_name(buf)

    -- Exclude: postgres-drawer, postgres results, terminal buffers (like Claude)
    if ft ~= "postgres-drawer" and ft ~= "postgres-results"
       and buftype ~= "terminal" and not buf_name:match("postgres://") then
      target_win = win
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
  end

  -- Create horizontal split at bottom
  vim.cmd("belowright split")
  state.winid = vim.api.nvim_get_current_win()

  -- Set height to ~30% of editor
  local height = math.floor(vim.o.lines * 0.3)
  vim.api.nvim_win_set_height(state.winid, height)

  -- Set buffer
  vim.api.nvim_win_set_buf(state.winid, state.bufnr)

  -- Window options
  vim.api.nvim_win_set_option(state.winid, "number", false)
  vim.api.nvim_win_set_option(state.winid, "relativenumber", false)
  vim.api.nvim_win_set_option(state.winid, "signcolumn", "no")
  vim.api.nvim_win_set_option(state.winid, "wrap", false)
  vim.api.nvim_win_set_option(state.winid, "cursorline", true)
  vim.api.nvim_win_set_option(state.winid, "winfixheight", true)

  state.visible = true

  -- Render last results if any
  if state.last_results then
    render(state.last_results, nil, state.last_query)
  else
    render(nil, nil, nil)
  end
end

-- Hide the results pane
function M.hide()
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  end
  state.winid = nil
  state.visible = false
end

-- Toggle the results pane
function M.toggle()
  if state.visible and state.winid and vim.api.nvim_win_is_valid(state.winid) then
    M.hide()
  else
    M.show()
  end
end

-- Display results
function M.display(results, error_msg, query_info)
  state.last_results = results
  state.last_query = query_info

  -- Show pane if not visible
  if not state.visible or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
    M.show()
  end

  render(results, error_msg, query_info)

  -- Focus the results pane
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_set_current_win(state.winid)
  end
end

-- Check if visible
function M.is_visible()
  return state.visible and state.winid and vim.api.nvim_win_is_valid(state.winid)
end

return M
