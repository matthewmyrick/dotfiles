-- S3 Drawer - Tree view for browsing S3 buckets
local M = {}

local api = require("s3.api")
local s3 = require("s3")

local state = {
  bufnr = nil,
  winid = nil,
  buckets = {},
  expanded = {},
  contents = {},
  loading = {},
  current_file = nil,  -- Track current previewed file {bucket, key, size}
}

-- Icons
local icons = {
  bucket = "󰆼",
  folder_closed = "",
  folder_open = "",
  file = "",
  loading = "󰔟",
}

-- Get icon for file using nvim-web-devicons
local function get_file_icon(filename)
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    local icon, _ = devicons.get_icon(filename, nil, { default = true })
    return icon or icons.file
  end
  return icons.file
end

-- Setup highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "S3Bucket", { fg = "#74c7ec", bold = true })  -- Soft blue (sapphire)
  vim.api.nvim_set_hl(0, "S3Folder", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "S3File", { fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "S3Loading", { fg = "#a6adc8", italic = true })
  vim.api.nvim_set_hl(0, "S3Size", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "S3Header", { fg = "#89b4fa", bold = true })
end

-- Render contents recursively
local function render_contents(lines, highlights, line_data, bucket, prefix, depth)
  local content_key = bucket .. ":" .. prefix
  local contents = state.contents[content_key]
  if not contents then return end

  local indent = string.rep("  ", depth)

  -- Folders first
  for _, folder in ipairs(contents.folders or {}) do
    local folder_key = bucket .. ":" .. folder.prefix
    local is_expanded = state.expanded[folder_key]
    local is_loading = state.loading[folder_key]

    local icon = is_loading and icons.loading or (is_expanded and icons.folder_open or icons.folder_closed)
    table.insert(lines, indent .. icon .. " " .. folder.name)
    table.insert(highlights, { line = #lines, hl = is_loading and "S3Loading" or "S3Folder" })
    table.insert(line_data, { type = "folder", name = folder.name, bucket = bucket, prefix = folder.prefix })

    if is_expanded and not is_loading then
      render_contents(lines, highlights, line_data, bucket, folder.prefix, depth + 1)
    end
  end

  -- Files
  for _, file in ipairs(contents.files or {}) do
    local size_str = api.format_bytes(file.size)
    local icon = get_file_icon(file.name)
    table.insert(lines, indent .. icon .. " " .. file.name .. "  " .. size_str)
    table.insert(highlights, { line = #lines, hl = "S3File" })
    table.insert(line_data, { type = "file", name = file.name, bucket = bucket, key = file.key, size = file.size })
  end
end

-- Render the tree
local function render()
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then return end

  local lines = {}
  local highlights = {}
  local line_data = {}

  -- Header
  local region = s3.get_region() or "no region"
  table.insert(lines, " S3 [" .. region .. "]")
  table.insert(highlights, { line = 1, hl = "S3Header" })
  table.insert(line_data, { type = "header" })

  table.insert(lines, "")
  table.insert(line_data, { type = "empty" })

  -- Buckets
  for _, bucket in ipairs(state.buckets) do
    local is_expanded = state.expanded[bucket.name]
    local is_loading = state.loading[bucket.name]

    local icon = is_loading and icons.loading or icons.bucket
    table.insert(lines, icon .. " " .. bucket.name)
    table.insert(highlights, { line = #lines, hl = is_loading and "S3Loading" or "S3Bucket" })
    table.insert(line_data, { type = "bucket", name = bucket.name, bucket = bucket.name })

    if is_expanded and not is_loading then
      render_contents(lines, highlights, line_data, bucket.name, "", 1)
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
  vim.b[state.bufnr].s3_line_data = line_data
end

-- Get line data
local function get_line_data(line)
  local data = vim.b[state.bufnr].s3_line_data
  return data and data[line] or nil
end

-- Toggle expand
local function toggle_node(data)
  if not data then return end

  if data.type == "bucket" then
    local key = data.bucket
    if state.expanded[key] then
      state.expanded[key] = false
      render()
    else
      local content_key = data.bucket .. ":"
      if not state.contents[content_key] then
        state.loading[key] = true
        render()
        vim.defer_fn(function()
          local contents, err = api.list_objects(data.bucket, "")
          state.loading[key] = false
          if contents then
            state.contents[content_key] = contents
            state.expanded[key] = true
          else
            vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
          end
          render()
        end, 10)
      else
        state.expanded[key] = true
        render()
      end
    end

  elseif data.type == "folder" then
    local key = data.bucket .. ":" .. data.prefix
    if state.expanded[key] then
      state.expanded[key] = false
      render()
    else
      if not state.contents[key] then
        state.loading[key] = true
        render()
        vim.defer_fn(function()
          local contents, err = api.list_objects(data.bucket, data.prefix)
          state.loading[key] = false
          if contents then
            state.contents[key] = contents
            state.expanded[key] = true
          else
            vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
          end
          render()
        end, 10)
      else
        state.expanded[key] = true
        render()
      end
    end

  elseif data.type == "file" then
    -- Preview file
    M.preview_file(data.bucket, data.key, data.size)
  end
end

-- Preview file in right pane
function M.preview_file(bucket, key, size)
  -- Track current file for metadata
  state.current_file = { bucket = bucket, key = key, size = size }

  -- Find or create preview window
  local preview_win = nil
  local preview_buf = nil

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "s3-preview" then
      preview_win = win
      preview_buf = buf
      break
    end
  end

  if not preview_win then
    -- Create preview window to the right
    vim.cmd("wincmd l")
    if vim.bo.filetype == "s3-drawer" then
      vim.cmd("vsplit")
    end
    preview_win = vim.api.nvim_get_current_win()
    preview_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
    vim.bo[preview_buf].buftype = "nofile"
    vim.bo[preview_buf].bufhidden = "wipe"
    vim.bo[preview_buf].filetype = "s3-preview"
  end

  -- Set buffer name
  vim.api.nvim_buf_set_name(preview_buf, "s3://" .. bucket .. "/" .. key)

  -- Check if binary
  if api.is_binary(key) then
    vim.bo[preview_buf].modifiable = true
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {
      "",
      "  Binary file: " .. key,
      "  Size: " .. api.format_bytes(size),
      "",
    })
    vim.bo[preview_buf].modifiable = false
    return
  end

  -- Show loading
  vim.bo[preview_buf].modifiable = true
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "  Loading..." })
  vim.bo[preview_buf].modifiable = false

  -- Fetch content
  vim.defer_fn(function()
    local content, err = api.get_content(bucket, key, s3.config.preview_max_bytes)
    vim.bo[preview_buf].modifiable = true
    if content then
      local lines = vim.split(content, "\n")
      if #content >= s3.config.preview_max_bytes then
        table.insert(lines, "")
        table.insert(lines, "... [Truncated] ...")
      end
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
      vim.bo[preview_buf].filetype = api.get_filetype(key)
    else
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "  Error: " .. (err or "unknown") })
    end
    vim.bo[preview_buf].modifiable = false
  end, 10)
end

-- Setup keymaps
local function setup_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    toggle_node(get_line_data(line))
  end, opts)

  vim.keymap.set("n", "o", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local data = get_line_data(line)
    if data and (data.type == "bucket" or data.type == "folder") then
      toggle_node(data)
    end
  end, opts)

  vim.keymap.set("n", "r", function()
    M.refresh()
  end, opts)

  vim.keymap.set("n", "R", function()
    M.load_buckets()
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

  vim.keymap.set("n", "b", function()
    M.fuzzy_search_buckets()
  end, opts)

  vim.keymap.set("n", "m", function()
    M.show_current_metadata()
  end, opts)
end

-- Fuzzy search buckets
function M.fuzzy_search_buckets()
  if #state.buckets == 0 then
    vim.notify("No buckets loaded", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Search S3 Buckets",
    finder = finders.new_table({
      results = state.buckets,
      entry_maker = function(entry)
        return {
          value = entry,
          display = icons.bucket .. " " .. entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Expand the bucket
          local data = { type = "bucket", bucket = selection.value.name, name = selection.value.name }
          toggle_node(data)
        end
      end)
      return true
    end,
  }):find()
end

-- Fuzzy search across all loaded files
function M.fuzzy_search()
  local items = {}

  -- Collect all files from loaded contents
  for key, contents in pairs(state.contents) do
    local bucket = key:match("^([^:]+):")
    if bucket and contents.files then
      for _, file in ipairs(contents.files) do
        table.insert(items, {
          display = bucket .. "/" .. file.key,
          bucket = bucket,
          key = file.key,
          size = file.size,
          name = file.name,
        })
      end
    end
  end

  if #items == 0 then
    vim.notify("No files loaded. Expand a bucket first.", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Multi-token sorter (space-separated search)
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

  pickers.new({}, {
    prompt_title = "Search S3 Files",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        local icon = get_file_icon(entry.name)
        return {
          value = entry,
          display = icon .. " " .. entry.display .. "  " .. api.format_bytes(entry.size),
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
          M.preview_file(selection.value.bucket, selection.value.key, selection.value.size)
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
  vim.bo[bufnr].filetype = "s3-drawer"
  vim.api.nvim_buf_set_name(bufnr, "s3://browser")
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

  local width = s3.config.drawer_width
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

-- Refresh
function M.refresh()
  render()
end

-- Load buckets
function M.load_buckets()
  state.expanded = {}
  state.contents = {}
  state.loading = {}

  vim.notify("Loading S3 buckets...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local buckets, err = api.list_buckets()
    if buckets then
      state.buckets = buckets
      vim.notify("Loaded " .. #buckets .. " buckets", vim.log.levels.INFO)
    else
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      state.buckets = {}
    end
    render()
  end, 10)
end

-- Show metadata for current file
function M.show_current_metadata()
  if not state.current_file then
    vim.notify("No file selected. Preview a file first.", vim.log.levels.WARN)
    return
  end

  local bucket = state.current_file.bucket
  local key = state.current_file.key

  vim.notify("Loading metadata...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local meta, err = api.get_metadata(bucket, key)
    if not meta then
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end

    local lines = {
      " S3 Object Metadata",
      "",
      " Basic Info",
      " ─────────────────────────────────────",
      "  Bucket:        " .. bucket,
      "  Key:           " .. key,
      "  Size:          " .. api.format_bytes(meta.content_length) .. " (" .. (meta.content_length or 0) .. " bytes)",
      "  Content-Type:  " .. (meta.content_type or "unknown"),
      "",
      " Timestamps",
      " ─────────────────────────────────────",
      "  Last Modified: " .. (meta.last_modified or "unknown"),
      "",
      " Storage",
      " ─────────────────────────────────────",
      "  Storage Class: " .. (meta.storage_class or "STANDARD"),
      "  ETag:          " .. (meta.etag or "unknown"),
    }

    -- Add custom metadata if present
    if meta.metadata and next(meta.metadata) then
      table.insert(lines, "")
      table.insert(lines, " Custom Metadata")
      table.insert(lines, " ─────────────────────────────────────")
      for k, v in pairs(meta.metadata) do
        table.insert(lines, "  " .. k .. ": " .. v)
      end
    end

    table.insert(lines, "")
    table.insert(lines, " Press q or <Esc> to close")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local width = 50
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

    -- Apply highlights
    vim.api.nvim_buf_add_highlight(buf, -1, "S3Header", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "S3Folder", 2, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "S3Folder", 9, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "S3Folder", 13, 0, -1)

    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  end, 10)
end

-- Show help
function M.show_help()
  local lines = {
    " S3 Browser Help",
    "",
    " Navigation",
    " ─────────────────────────",
    " <CR>  Expand/collapse or preview",
    " o     Toggle expand",
    " C-h   Cycle windows forward",
    " C-g   Cycle windows backward",
    "",
    " Search",
    " ─────────────────────────",
    " /     Fuzzy search files",
    " b     Fuzzy search buckets",
    "",
    " Actions",
    " ─────────────────────────",
    " m     Show file metadata",
    " r     Refresh view",
    " R     Reload all buckets",
    " q     Close drawer",
    " ?     Show this help",
    "",
    " Press any key to close",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 35,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - 35) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<CR>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

return M
