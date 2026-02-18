-- Secrets Drawer - Tree view for browsing AWS Secrets
local M = {}

local api = require("secrets.api")
local secrets_module = require("secrets")

local state = {
  bufnr = nil,
  winid = nil,
  secrets = {},
  expanded = {},
  loading = {},
  current_secret = nil, -- Track current previewed secret {name, arn}
}

-- Icons
local icons = {
  secret = "󰌋",
  secret_expanded = "󰌌",
  loading = "󰔟",
  key = "",
  value = "",
}

-- Setup highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "SecretsHeader", { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, "SecretsItem", { fg = "#f9e2af" }) -- Yellow for secrets
  vim.api.nvim_set_hl(0, "SecretsLoading", { fg = "#a6adc8", italic = true })
  vim.api.nvim_set_hl(0, "SecretsDescription", { fg = "#6c7086", italic = true })
  vim.api.nvim_set_hl(0, "SecretsKey", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "SecretsValue", { fg = "#a6e3a1" })
end

-- Render the tree
local function render()
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then return end

  local lines = {}
  local highlights = {}
  local line_data = {}

  -- Header
  local region = secrets_module.get_region() or "no region"
  local header = " Secrets Manager [" .. region .. "]"
  table.insert(lines, header)
  table.insert(highlights, { line = 1, hl = "SecretsHeader" })
  table.insert(line_data, { type = "header" })

  table.insert(lines, "")
  table.insert(line_data, { type = "empty" })

  -- Secrets
  for _, secret in ipairs(state.secrets) do
    local is_loading = state.loading[secret.name]
    local icon = is_loading and icons.loading or icons.secret

    local display_name = secret.name
    -- Truncate if too long
    local max_width = secrets_module.config.drawer_width - 4
    if #display_name > max_width then
      display_name = display_name:sub(1, max_width - 3) .. "..."
    end

    table.insert(lines, icon .. " " .. display_name)
    table.insert(highlights, { line = #lines, hl = is_loading and "SecretsLoading" or "SecretsItem" })
    table.insert(line_data, {
      type = "secret",
      name = secret.name,
      arn = secret.arn,
      description = secret.description,
    })

    -- Show description on next line if present
    if secret.description and secret.description ~= "" then
      local desc = "  " .. secret.description
      if #desc > max_width then
        desc = desc:sub(1, max_width - 3) .. "..."
      end
      table.insert(lines, desc)
      table.insert(highlights, { line = #lines, hl = "SecretsDescription" })
      table.insert(line_data, { type = "description", parent = secret.name })
    end
  end

  -- Set content
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.bufnr, -1, hl.hl, hl.line - 1, 0, -1)
  end

  -- Store line data
  vim.b[state.bufnr].secrets_line_data = line_data
end

-- Get line data
local function get_line_data(line)
  local data = vim.b[state.bufnr].secrets_line_data
  return data and data[line] or nil
end

-- Preview secret value in right pane
function M.preview_secret(secret_name)
  -- Track current secret
  state.current_secret = { name = secret_name }

  -- Find or create preview window
  local preview_win = nil
  local preview_buf = nil

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "secrets-preview" then
      preview_win = win
      preview_buf = buf
      break
    end
  end

  if not preview_win then
    -- Create preview window to the right
    vim.cmd("wincmd l")
    if vim.bo.filetype == "secrets-drawer" then
      vim.cmd("vsplit")
    end
    preview_win = vim.api.nvim_get_current_win()
    preview_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
    vim.bo[preview_buf].buftype = "nofile"
    vim.bo[preview_buf].bufhidden = "wipe"
    vim.bo[preview_buf].filetype = "secrets-preview"
  end

  -- Set buffer name
  vim.api.nvim_buf_set_name(preview_buf, "secret://" .. secret_name)

  -- Show loading
  vim.bo[preview_buf].modifiable = true
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "  Loading secret..." })
  vim.bo[preview_buf].modifiable = false

  -- Mark as loading
  state.loading[secret_name] = true
  render()

  -- Fetch secret value
  vim.defer_fn(function()
    local secret_data, err = api.get_secret_value(secret_name)
    state.loading[secret_name] = false
    render()

    vim.bo[preview_buf].modifiable = true
    if secret_data then
      -- Format the value
      local formatted = api.format_value(secret_data.value)
      local lines = vim.split(formatted, "\n")

      -- Add header info
      local header_lines = {
        "Secret: " .. secret_data.name,
        "Version: " .. (secret_data.version_id or "N/A"),
        "Stages: " .. table.concat(secret_data.version_stages or {}, ", "),
        string.rep("─", 60),
        "",
      }

      -- Combine header with content
      for i = #header_lines, 1, -1 do
        table.insert(lines, 1, header_lines[i])
      end

      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

      -- Set filetype for syntax highlighting
      if api.is_json(secret_data.value) then
        vim.bo[preview_buf].filetype = "json"
      else
        vim.bo[preview_buf].filetype = "text"
      end
    else
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "  Error: " .. (err or "unknown") })
    end
    vim.bo[preview_buf].modifiable = false
  end, 10)
end

-- Handle enter on a line
local function handle_enter()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data then return end

  if data.type == "secret" then
    M.preview_secret(data.name)
  elseif data.type == "description" then
    -- If on description line, act on parent secret
    if data.parent then
      M.preview_secret(data.parent)
    end
  end
end

-- Setup keymaps
local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  vim.keymap.set("n", "<CR>", handle_enter, opts)
  vim.keymap.set("n", "o", handle_enter, opts)

  vim.keymap.set("n", "r", function()
    M.load_secrets()
  end, opts)

  vim.keymap.set("n", "R", function()
    M.load_secrets()
  end, opts)

  vim.keymap.set("n", "q", function()
    M.close()
  end, opts)

  vim.keymap.set("n", "?", function()
    M.show_help()
  end, opts)

  vim.keymap.set("n", "/", function()
    M.fuzzy_search()
  end, opts)

  vim.keymap.set("n", "i", function()
    M.show_current_metadata()
  end, opts)

  vim.keymap.set("n", "y", function()
    M.yank_secret_value()
  end, opts)
end

-- Yank secret value to clipboard
function M.yank_secret_value()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or data.type ~= "secret" then
    vim.notify("Select a secret to copy", vim.log.levels.WARN)
    return
  end

  vim.notify("Fetching secret value...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local secret_data, err = api.get_secret_value(data.name)
    if secret_data then
      vim.fn.setreg("+", secret_data.value)
      vim.fn.setreg('"', secret_data.value)
      vim.notify("Secret value copied to clipboard", vim.log.levels.INFO)
    else
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
    end
  end, 10)
end

-- Fuzzy search secrets
function M.fuzzy_search()
  if #state.secrets == 0 then
    vim.notify("No secrets loaded", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Search Secrets",
    finder = finders.new_table({
      results = state.secrets,
      entry_maker = function(entry)
        local display = icons.secret .. " " .. entry.name
        if entry.description and entry.description ~= "" then
          display = display .. " - " .. entry.description
        end
        return {
          value = entry,
          display = display,
          ordinal = entry.name .. " " .. (entry.description or ""),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.preview_secret(selection.value.name)
        end
      end)
      return true
    end,
  }):find()
end

-- Create buffer
local function create_buffer()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = "secrets-drawer"
  vim.api.nvim_buf_set_name(bufnr, "secrets://browser")
  setup_keymaps(bufnr)
  return bufnr
end

-- Open drawer
function M.open()
  setup_highlights()

  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_set_current_win(state.winid)
    return
  end

  state.bufnr = create_buffer()

  local width = secrets_module.config.drawer_width
  vim.cmd("topleft " .. width .. "vsplit")
  state.winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.winid, state.bufnr)

  vim.wo[state.winid].number = false
  vim.wo[state.winid].relativenumber = false
  vim.wo[state.winid].winfixwidth = true
  vim.wo[state.winid].cursorline = true
  vim.wo[state.winid].wrap = false
  vim.wo[state.winid].signcolumn = "no"

  render()
end

-- Close drawer
function M.close()
  if state.winid and vim.api.nvim_win_is_valid(state.winid) then
    vim.api.nvim_win_close(state.winid, true)
  end
  state.winid = nil
  state.bufnr = nil
end

-- Load secrets
function M.load_secrets()
  state.expanded = {}
  state.loading = {}

  vim.notify("Loading secrets...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local secrets, err = api.list_secrets()
    if secrets then
      state.secrets = secrets
      vim.notify("Loaded " .. #secrets .. " secrets", vim.log.levels.INFO)
    else
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      state.secrets = {}
    end
    render()
  end, 10)
end

-- Show metadata popup
local function show_metadata_popup(title, lines)
  table.insert(lines, "")
  table.insert(lines, " Press q or <Esc> to close")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 65
  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  -- Solid background
  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal"

  -- Apply highlights
  vim.api.nvim_buf_add_highlight(buf, -1, "SecretsHeader", 0, 0, -1)

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- Show metadata for secret under cursor
function M.show_current_metadata()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  local secret_name = nil
  if data and data.type == "secret" then
    secret_name = data.name
  elseif data and data.type == "description" and data.parent then
    secret_name = data.parent
  elseif state.current_secret then
    secret_name = state.current_secret.name
  end

  if not secret_name then
    vim.notify("Select a secret first", vim.log.levels.WARN)
    return
  end

  vim.notify("Loading metadata...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local meta, err = api.describe_secret(secret_name)
    if not meta then
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end

    local lines = {
      " Secret Metadata",
      "",
      " Basic Info",
      " ─────────────────────────────────────────────────────",
      "  Name:         " .. (meta.name or "N/A"),
      "  ARN:          " .. (meta.arn or "N/A"),
      "  Description:  " .. (meta.description ~= "" and meta.description or "(none)"),
      "",
      " Encryption",
      " ─────────────────────────────────────────────────────",
      "  KMS Key ID:   " .. (meta.kms_key_id or "aws/secretsmanager (default)"),
      "",
      " Rotation",
      " ─────────────────────────────────────────────────────",
      "  Enabled:      " .. (meta.rotation_enabled and "Yes" or "No"),
    }

    if meta.rotation_enabled then
      table.insert(lines, "  Lambda ARN:   " .. (meta.rotation_lambda_arn or "N/A"))
      if meta.rotation_rules then
        table.insert(lines, "  Interval:     " .. (meta.rotation_rules.AutomaticallyAfterDays or "N/A") .. " days")
      end
      table.insert(lines, "  Last Rotated: " .. api.format_date(meta.last_rotated_date))
    end

    table.insert(lines, "")
    table.insert(lines, " Timestamps")
    table.insert(lines, " ─────────────────────────────────────────────────────")
    table.insert(lines, "  Created:      " .. api.format_date(meta.created_date))
    table.insert(lines, "  Last Changed: " .. api.format_date(meta.last_changed_date))
    table.insert(lines, "  Last Accessed:" .. api.format_date(meta.last_accessed_date))

    -- Tags
    if meta.tags and #meta.tags > 0 then
      table.insert(lines, "")
      table.insert(lines, " Tags")
      table.insert(lines, " ─────────────────────────────────────────────────────")
      for _, tag in ipairs(meta.tags) do
        table.insert(lines, "  " .. tag.Key .. ": " .. tag.Value)
      end
    end

    -- Versions
    if meta.version_ids_to_stages and next(meta.version_ids_to_stages) then
      table.insert(lines, "")
      table.insert(lines, " Versions")
      table.insert(lines, " ─────────────────────────────────────────────────────")
      for version_id, stages in pairs(meta.version_ids_to_stages) do
        local short_id = version_id:sub(1, 20) .. "..."
        table.insert(lines, "  " .. short_id .. " [" .. table.concat(stages, ", ") .. "]")
      end
    end

    show_metadata_popup("Secret Metadata", lines)
  end, 10)
end

-- Show help
function M.show_help()
  local lines = {
    " Secrets Manager Help",
    "",
    " Navigation",
    " ─────────────────────────────────────",
    " <CR>     Preview secret value",
    " o        Preview secret value",
    " C-h      Cycle windows forward",
    " C-g      Cycle windows backward",
    "",
    " Search",
    " ─────────────────────────────────────",
    " /        Fuzzy search secrets",
    "",
    " Actions",
    " ─────────────────────────────────────",
    " y        Copy secret value to clipboard",
    " i        Show secret metadata",
    " r/R      Refresh secrets list",
    " q        Close drawer",
    " ?        Show this help",
    "",
    " Press any key to close",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 45
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  -- Solid background
  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal"

  -- Apply highlights
  vim.api.nvim_buf_add_highlight(buf, -1, "SecretsHeader", 0, 0, -1)

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<CR>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

return M
