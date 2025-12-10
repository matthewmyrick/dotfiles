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
    table.insert(lines, string.format(" %d row(s) returned", row_count))
    table.insert(highlights, { line = #lines, hl = "PgResultsInfo" })
  else
    table.insert(lines, " No results to display")
    table.insert(lines, " Run a query with <leader>rr")
  end

  -- Footer with keymaps
  table.insert(lines, "")
  table.insert(lines, " Press q to close, <leader>rt to toggle")

  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.bufnr, -1, hl.hl, hl.line - 1, 0, -1)
  end

  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
end

-- Setup keymaps for results buffer
local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

  -- Close results
  vim.keymap.set("n", "q", function()
    M.hide()
  end, opts)

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

  -- Find the editor window (rightmost non-drawer window)
  local target_win = nil
  local wins = vim.api.nvim_list_wins()

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if ft ~= "neo-tree" and ft ~= "postgres-drawer" and ft ~= "postgres-results" and not buf_name:match("postgres://") then
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
