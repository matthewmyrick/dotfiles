-- UI module - floating windows and forms
local M = {}

-- State for the form
local form_state = {
  bufnr = nil,
  winid = nil,
  on_submit = nil,
  is_edit = false,
  edit_id = nil,
}

-- Setup highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "PgFormNormal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "PgFormBorder", { bg = "NONE", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE", fg = "#89b4fa", bold = true })
end

-- Parse the buffer content into a connection object
local function parse_form()
  if not form_state.bufnr or not vim.api.nvim_buf_is_valid(form_state.bufnr) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(form_state.bufnr, 0, -1, false)
  local connection = {}

  for _, line in ipairs(lines) do
    -- Skip empty lines and comments
    if line ~= "" and not line:match("^#") then
      local key, value = line:match("^([%w_]+)%s*=%s*(.*)$")
      if key and value then
        -- Trim whitespace
        value = value:gsub("^%s*(.-)%s*$", "%1")

        if key == "ssl" then
          connection[key] = value:lower() == "yes" or value:lower() == "true"
        else
          connection[key] = value
        end
      end
    end
  end

  return connection
end

-- Setup keymaps for the form buffer
local function setup_form_keymaps()
  local opts = { buffer = form_state.bufnr, noremap = true, silent = true }

  -- Save with Ctrl+S
  vim.keymap.set("n", "<C-s>", function()
    M.submit_form()
  end, opts)

  vim.keymap.set("i", "<C-s>", function()
    vim.cmd("stopinsert")
    M.submit_form()
  end, opts)

  -- Cancel with q (normal mode only) or Esc
  vim.keymap.set("n", "q", function()
    M.close_form()
  end, opts)

  vim.keymap.set("n", "<Esc>", function()
    M.close_form()
  end, opts)
end

-- Open the connection form
function M.open_connection_form(connection, on_submit)
  setup_highlights()

  form_state.on_submit = on_submit
  form_state.is_edit = connection ~= nil
  form_state.edit_id = connection and connection.id or nil

  -- Default values
  local name = connection and connection.name or ""
  local host = connection and connection.host or "localhost"
  local port = connection and connection.port or "5432"
  local database = connection and connection.database or "postgres"
  local user = connection and connection.user or "postgres"
  local password = connection and connection.password or ""
  local ssl = connection and connection.ssl and "yes" or "no"

  -- Create buffer content
  local lines = {
    "# Connection Configuration",
    "# Edit values and press Ctrl+S to save, q to cancel",
    "",
    "name=" .. name,
    "host=" .. host,
    "port=" .. port,
    "database=" .. database,
    "user=" .. user,
    "password=" .. password,
    "ssl=" .. ssl,
  }

  -- Calculate window size
  local width = 50
  local height = #lines + 2

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Center the window
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  -- Create buffer
  form_state.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(form_state.bufnr, 0, -1, false, lines)

  -- Buffer options
  vim.api.nvim_buf_set_option(form_state.bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(form_state.bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(form_state.bufnr, "filetype", "conf")

  -- Create floating window
  local title = form_state.is_edit and " Edit Connection " or " New Connection "
  form_state.winid = vim.api.nvim_open_win(form_state.bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  -- Window options
  vim.api.nvim_win_set_option(form_state.winid, "winhighlight", "Normal:PgFormNormal,FloatBorder:PgFormBorder")
  vim.api.nvim_win_set_option(form_state.winid, "cursorline", true)

  -- Set up keymaps
  setup_form_keymaps()

  -- Move cursor to the name field value
  vim.api.nvim_win_set_cursor(form_state.winid, { 4, 5 })

  -- Enter insert mode at end of line if new connection
  if not form_state.is_edit then
    vim.cmd("normal! $")
    vim.cmd("startinsert!")
  end
end

-- Submit the form
function M.submit_form()
  local connection = parse_form()

  if not connection then
    vim.notify("Failed to parse form", vim.log.levels.ERROR)
    return
  end

  -- Validate required fields
  if not connection.name or connection.name == "" then
    vim.notify("Connection name is required", vim.log.levels.WARN)
    return
  end

  -- Add ID
  if form_state.edit_id then
    connection.id = form_state.edit_id
  else
    connection.id = tostring(os.time()) .. tostring(math.random(1000, 9999))
  end

  -- Set defaults for missing fields
  connection.host = connection.host or "localhost"
  connection.port = connection.port or "5432"
  connection.database = connection.database or "postgres"
  connection.user = connection.user or "postgres"
  connection.password = connection.password or ""

  M.close_form()

  if form_state.on_submit then
    form_state.on_submit(connection)
  end
end

-- Close the form
function M.close_form()
  if form_state.winid and vim.api.nvim_win_is_valid(form_state.winid) then
    vim.api.nvim_win_close(form_state.winid, true)
  end
  form_state.winid = nil
  form_state.bufnr = nil
end

return M
