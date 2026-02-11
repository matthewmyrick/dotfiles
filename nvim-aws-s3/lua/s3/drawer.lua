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
  clipboard = nil,     -- {mode = "copy"|"cut", bucket, key, name}
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
  vim.api.nvim_set_hl(0, "S3Cut", { fg = "#f38ba8", italic = true })  -- Red for cut files
  vim.api.nvim_set_hl(0, "S3Copied", { fg = "#a6e3a1", italic = true })  -- Green for copied files
end

-- Check if file is in clipboard
local function get_clipboard_hl(bucket, key)
  if state.clipboard and state.clipboard.bucket == bucket and state.clipboard.key == key then
    return state.clipboard.mode == "cut" and "S3Cut" or "S3Copied"
  end
  return nil
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
    local clip_hl = get_clipboard_hl(bucket, file.key)
    table.insert(highlights, { line = #lines, hl = clip_hl or "S3File" })
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
  local header = " S3 [" .. region .. "]"
  if state.clipboard then
    header = header .. " [" .. state.clipboard.mode:upper() .. ": " .. state.clipboard.name .. "]"
  end
  table.insert(lines, header)
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

-- Confirmation dialog
local function confirm_dialog(title, message, on_yes)
  local lines = {
    " " .. title,
    "",
    " " .. message,
    "",
    " [y] Yes    [n] No",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.max(#title + 4, #message + 4, 25)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  -- Solid background (no transparency, no text showing through)
  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal"
  vim.api.nvim_buf_add_highlight(buf, -1, "S3Header", 0, 0, -1)

  vim.keymap.set("n", "y", function()
    vim.api.nvim_win_close(win, true)
    on_yes()
  end, { buffer = buf })

  vim.keymap.set("n", "n", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

-- Input dialog
local function input_dialog(title, default_value, on_submit)
  vim.ui.input({
    prompt = title .. ": ",
    default = default_value,
  }, function(input)
    if input and input ~= "" then
      on_submit(input)
    end
  end)
end

-- Download file
function M.download_file()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or data.type ~= "file" then
    vim.notify("Select a file to download", vim.log.levels.WARN)
    return
  end

  local default_path = vim.fn.expand("~/Downloads/") .. data.name

  input_dialog("Download to", default_path, function(path)
    vim.notify("Downloading " .. data.name .. "...", vim.log.levels.INFO)
    vim.defer_fn(function()
      local ok, err = api.download_object(data.bucket, data.key, path)
      if ok then
        vim.notify("Downloaded to " .. path, vim.log.levels.INFO)
      else
        vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      end
    end, 10)
  end)
end

-- Delete file
function M.delete_file()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or data.type ~= "file" then
    vim.notify("Select a file to delete", vim.log.levels.WARN)
    return
  end

  confirm_dialog("Delete File", "Delete " .. data.name .. "?", function()
    vim.notify("Deleting " .. data.name .. "...", vim.log.levels.INFO)
    vim.defer_fn(function()
      local ok, err = api.delete_object(data.bucket, data.key)
      if ok then
        vim.notify("Deleted " .. data.name, vim.log.levels.INFO)
        -- Clear from clipboard if it was there
        if state.clipboard and state.clipboard.bucket == data.bucket and state.clipboard.key == data.key then
          state.clipboard = nil
        end
        -- Refresh the parent folder
        M.refresh_current_bucket()
      else
        vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      end
    end, 10)
  end)
end

-- Edit file
function M.edit_file()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  -- Also allow editing from preview window
  if not data and state.current_file then
    data = { type = "file", bucket = state.current_file.bucket, key = state.current_file.key, name = state.current_file.key:match("[^/]+$") }
  end

  if not data or data.type ~= "file" then
    vim.notify("Select a file to edit", vim.log.levels.WARN)
    return
  end

  if api.is_binary(data.key) then
    vim.notify("Cannot edit binary files", vim.log.levels.WARN)
    return
  end

  vim.notify("Loading file for editing...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local content, err = api.get_full_content(data.bucket, data.key)
    if not content then
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end

    -- Create a new buffer for editing
    local edit_buf = vim.api.nvim_create_buf(true, false)
    local lines = vim.split(content, "\n")
    vim.api.nvim_buf_set_lines(edit_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(edit_buf, "s3-edit://" .. data.bucket .. "/" .. data.key)
    vim.bo[edit_buf].filetype = api.get_filetype(data.key)
    vim.bo[edit_buf].modified = false

    -- Store S3 info in buffer variables
    vim.b[edit_buf].s3_bucket = data.bucket
    vim.b[edit_buf].s3_key = data.key

    -- Find or create edit window
    vim.cmd("wincmd l")
    if vim.bo.filetype == "s3-drawer" then
      vim.cmd("vsplit")
    end
    vim.api.nvim_win_set_buf(0, edit_buf)

    -- Setup save command for this buffer
    vim.api.nvim_buf_create_user_command(edit_buf, "W", function()
      M.save_edited_file(edit_buf)
    end, {})

    -- Also map :w to save
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = edit_buf,
      callback = function()
        M.save_edited_file(edit_buf)
      end,
    })

    -- Map <leader>ww
    vim.keymap.set("n", "<leader>ww", function()
      M.save_edited_file(edit_buf)
    end, { buffer = edit_buf, desc = "Save to S3" })

    vim.notify("Editing " .. data.name .. " - Use :w or <leader>ww to save to S3", vim.log.levels.INFO)
  end, 10)
end

-- Save edited file back to S3
function M.save_edited_file(bufnr)
  local bucket = vim.b[bufnr].s3_bucket
  local key = vim.b[bufnr].s3_key

  if not bucket or not key then
    vim.notify("No S3 info for this buffer", vim.log.levels.ERROR)
    return
  end

  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Write to temp file
  local tmp_file = vim.fn.tempname()
  local f = io.open(tmp_file, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(content)
  f:close()

  vim.notify("Saving to S3...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local ok, err = api.put_object(bucket, key, tmp_file)
    os.remove(tmp_file)

    if ok then
      vim.bo[bufnr].modified = false
      vim.notify("Saved to s3://" .. bucket .. "/" .. key, vim.log.levels.INFO)
    else
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
    end
  end, 10)
end

-- Copy file (yank)
function M.yank_file()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or data.type ~= "file" then
    vim.notify("Select a file to copy", vim.log.levels.WARN)
    return
  end

  state.clipboard = {
    mode = "copy",
    bucket = data.bucket,
    key = data.key,
    name = data.name,
  }

  vim.notify("Copied: " .. data.name, vim.log.levels.INFO)
  render()
end

-- Cut file (for move)
function M.cut_file()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or data.type ~= "file" then
    vim.notify("Select a file to move", vim.log.levels.WARN)
    return
  end

  state.clipboard = {
    mode = "cut",
    bucket = data.bucket,
    key = data.key,
    name = data.name,
  }

  vim.notify("Cut: " .. data.name .. " (press p to paste)", vim.log.levels.INFO)
  render()
end

-- Paste file
function M.paste_file()
  if not state.clipboard then
    vim.notify("Nothing in clipboard. Use y to copy or m to cut.", vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data then
    vim.notify("Select a destination folder or bucket", vim.log.levels.WARN)
    return
  end

  -- Determine destination
  local dest_bucket = data.bucket
  local dest_prefix = ""

  if data.type == "folder" then
    dest_prefix = data.prefix
  elseif data.type == "file" then
    -- Get parent folder
    dest_prefix = data.key:match("^(.*/)")  or ""
  end

  local dest_key = dest_prefix .. state.clipboard.name

  -- Check if same location
  if dest_bucket == state.clipboard.bucket and dest_key == state.clipboard.key then
    vim.notify("Cannot paste to same location", vim.log.levels.WARN)
    return
  end

  local mode = state.clipboard.mode
  local action = mode == "copy" and "Copying" or "Moving"

  vim.notify(action .. " " .. state.clipboard.name .. "...", vim.log.levels.INFO)

  vim.defer_fn(function()
    local ok, err

    if mode == "copy" then
      ok, err = api.copy_object(state.clipboard.bucket, state.clipboard.key, dest_bucket, dest_key)
    else
      ok, err = api.move_object(state.clipboard.bucket, state.clipboard.key, dest_bucket, dest_key)
    end

    if ok then
      vim.notify((mode == "copy" and "Copied" or "Moved") .. " to s3://" .. dest_bucket .. "/" .. dest_key, vim.log.levels.INFO)

      -- Clear clipboard after move
      if mode == "cut" then
        state.clipboard = nil
      end

      -- Refresh
      M.refresh_current_bucket()
    else
      vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
    end
  end, 10)
end

-- Rename file or folder
function M.rename_item()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data or (data.type ~= "file" and data.type ~= "folder") then
    vim.notify("Select a file or folder to rename", vim.log.levels.WARN)
    return
  end

  local current_name = data.name
  local is_folder = data.type == "folder"

  input_dialog("Rename to", current_name, function(new_name)
    if new_name == current_name then
      return
    end

    confirm_dialog("Confirm Rename", "Rename to " .. new_name .. "?", function()
      if is_folder then
        vim.notify("Folder renaming requires moving all contents. Not yet implemented.", vim.log.levels.WARN)
        return
      end

      -- Calculate new key
      local parent_prefix = data.key:match("^(.*/)") or ""
      local new_key = parent_prefix .. new_name

      vim.notify("Renaming to " .. new_name .. "...", vim.log.levels.INFO)

      vim.defer_fn(function()
        local ok, err = api.move_object(data.bucket, data.key, data.bucket, new_key)
        if ok then
          vim.notify("Renamed to " .. new_name, vim.log.levels.INFO)
          M.refresh_current_bucket()
        else
          vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
        end
      end, 10)
    end)
  end)
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

  -- Refresh keymaps (changed)
  vim.keymap.set("n", "gr", function()
    M.refresh_current_bucket()
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

  -- Metadata (changed from m to i)
  vim.keymap.set("n", "i", function()
    M.show_current_metadata()
  end, opts)

  -- New features
  vim.keymap.set("n", "d", function()
    M.download_file()
  end, opts)

  vim.keymap.set("n", "D", function()
    M.delete_file()
  end, opts)

  vim.keymap.set("n", "e", function()
    M.edit_file()
  end, opts)

  vim.keymap.set("n", "y", function()
    M.yank_file()
  end, opts)

  vim.keymap.set("n", "m", function()
    M.cut_file()
  end, opts)

  vim.keymap.set("n", "p", function()
    M.paste_file()
  end, opts)

  vim.keymap.set("n", "r", function()
    M.rename_item()
  end, opts)
end

-- Find line number for a bucket in the tree
local function find_bucket_line(bucket_name)
  local line_data = vim.b[state.bufnr].s3_line_data
  if not line_data then return nil end
  for i, data in ipairs(line_data) do
    if data.type == "bucket" and data.name == bucket_name then
      return i
    end
  end
  return nil
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
          local bucket_name = selection.value.name
          -- Expand the bucket
          local data = { type = "bucket", bucket = bucket_name, name = bucket_name }
          toggle_node(data)
          -- Move cursor to the bucket line after render
          vim.defer_fn(function()
            local line = find_bucket_line(bucket_name)
            if line and state.winid and vim.api.nvim_win_is_valid(state.winid) then
              vim.api.nvim_set_current_win(state.winid)
              vim.api.nvim_win_set_cursor(state.winid, { line, 0 })
            end
          end, 50)
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

-- Refresh current bucket (clears cache and reloads, keeping expanded folders open)
function M.refresh_current_bucket()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local data = get_line_data(line)

  if not data then
    vim.notify("No item under cursor", vim.log.levels.WARN)
    return
  end

  -- Get the bucket name from whatever item we're on
  local bucket_name = data.bucket
  if not bucket_name then
    vim.notify("No bucket context", vim.log.levels.WARN)
    return
  end

  vim.notify("Refreshing bucket: " .. bucket_name, vim.log.levels.INFO)

  -- Save which folders were expanded for this bucket
  local expanded_prefixes = {}
  for key, is_expanded in pairs(state.expanded) do
    if is_expanded and key:match("^" .. bucket_name .. ":") then
      local prefix = key:sub(#bucket_name + 2)  -- Remove "bucket:"
      if prefix ~= "" then
        table.insert(expanded_prefixes, prefix)
      end
    end
  end

  -- Clear all cached contents for this bucket
  local keys_to_remove = {}
  for key, _ in pairs(state.contents) do
    if key:match("^" .. bucket_name .. ":") then
      table.insert(keys_to_remove, key)
    end
  end
  for _, key in ipairs(keys_to_remove) do
    state.contents[key] = nil
  end

  -- Reload the bucket contents and re-expand folders
  if state.expanded[bucket_name] then
    state.loading[bucket_name] = true
    render()

    vim.defer_fn(function()
      -- First reload the root
      local contents, err = api.list_objects(bucket_name, "")
      state.loading[bucket_name] = false
      if contents then
        state.contents[bucket_name .. ":"] = contents

        -- Now reload each expanded folder
        local pending = #expanded_prefixes
        if pending == 0 then
          vim.notify("Bucket refreshed", vim.log.levels.INFO)
          render()
        else
          for _, prefix in ipairs(expanded_prefixes) do
            vim.defer_fn(function()
              local folder_contents, _ = api.list_objects(bucket_name, prefix)
              if folder_contents then
                state.contents[bucket_name .. ":" .. prefix] = folder_contents
                state.expanded[bucket_name .. ":" .. prefix] = true
              end
              pending = pending - 1
              if pending == 0 then
                vim.notify("Bucket refreshed", vim.log.levels.INFO)
                render()
              end
            end, 10)
          end
        end
      else
        vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
        render()
      end
    end, 10)
  else
    render()
  end
end

-- Refresh (legacy, just re-render)
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

-- Show metadata popup
local function show_metadata_popup(title, lines)
  table.insert(lines, "")
  table.insert(lines, " Press q or <Esc> to close")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 55
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

  -- Solid background (no transparency, no text showing through)
  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal"

  -- Apply highlights
  vim.api.nvim_buf_add_highlight(buf, -1, "S3Header", 0, 0, -1)

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- Show metadata for item under cursor (or current previewed file)
function M.show_current_metadata()
  -- Check if we're in the drawer
  local in_drawer = vim.bo.filetype == "s3-drawer"
  local data = nil

  if in_drawer then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    data = get_line_data(line)
  end

  -- If in drawer with valid data, show metadata for that item
  if data then
    if data.type == "bucket" then
      -- Show bucket info (no S3 API call needed)
      local lines = {
        " S3 Bucket Info",
        "",
        " Bucket",
        " ─────────────────────────────────────────",
        "  Name:    " .. data.name,
        "  URI:     s3://" .. data.name,
        "",
        " Contents",
        " ─────────────────────────────────────────",
      }

      -- Count folders and files if expanded
      local content_key = data.bucket .. ":"
      local contents = state.contents[content_key]
      if contents then
        local folder_count = contents.folders and #contents.folders or 0
        local file_count = contents.files and #contents.files or 0
        table.insert(lines, "  Folders: " .. folder_count)
        table.insert(lines, "  Files:   " .. file_count)
      else
        table.insert(lines, "  (Expand bucket to see contents)")
      end

      show_metadata_popup("Bucket Info", lines)
      return

    elseif data.type == "folder" then
      -- Show folder info
      local lines = {
        " S3 Folder Info",
        "",
        " Location",
        " ─────────────────────────────────────────",
        "  Bucket:  " .. data.bucket,
        "  Prefix:  " .. data.prefix,
        "  URI:     s3://" .. data.bucket .. "/" .. data.prefix,
        "",
        " Contents",
        " ─────────────────────────────────────────",
      }

      -- Count folders and files if expanded
      local content_key = data.bucket .. ":" .. data.prefix
      local contents = state.contents[content_key]
      if contents then
        local folder_count = contents.folders and #contents.folders or 0
        local file_count = contents.files and #contents.files or 0
        table.insert(lines, "  Folders: " .. folder_count)
        table.insert(lines, "  Files:   " .. file_count)
      else
        table.insert(lines, "  (Expand folder to see contents)")
      end

      show_metadata_popup("Folder Info", lines)
      return

    elseif data.type == "file" then
      -- Fetch file metadata from S3
      vim.notify("Loading metadata...", vim.log.levels.INFO)
      vim.defer_fn(function()
        local meta, err = api.get_metadata(data.bucket, data.key)
        if not meta then
          vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
          return
        end

        local lines = {
          " S3 Object Metadata",
          "",
          " Basic Info",
          " ─────────────────────────────────────────",
          "  Bucket:        " .. data.bucket,
          "  Key:           " .. data.key,
          "  Size:          " .. api.format_bytes(meta.content_length) .. " (" .. (meta.content_length or 0) .. " bytes)",
          "  Content-Type:  " .. (meta.content_type or "unknown"),
          "",
          " Timestamps",
          " ─────────────────────────────────────────",
          "  Last Modified: " .. (meta.last_modified or "unknown"),
          "",
          " Storage",
          " ─────────────────────────────────────────",
          "  Storage Class: " .. (meta.storage_class or "STANDARD"),
          "  ETag:          " .. (meta.etag or "unknown"),
        }

        -- Add custom metadata if present
        if meta.metadata and next(meta.metadata) then
          table.insert(lines, "")
          table.insert(lines, " Custom Metadata")
          table.insert(lines, " ─────────────────────────────────────────")
          for k, v in pairs(meta.metadata) do
            table.insert(lines, "  " .. k .. ": " .. v)
          end
        end

        show_metadata_popup("Object Metadata", lines)
      end, 10)
      return
    end
  end

  -- Fall back to current previewed file
  if state.current_file then
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
        " ─────────────────────────────────────────",
        "  Bucket:        " .. bucket,
        "  Key:           " .. key,
        "  Size:          " .. api.format_bytes(meta.content_length) .. " (" .. (meta.content_length or 0) .. " bytes)",
        "  Content-Type:  " .. (meta.content_type or "unknown"),
        "",
        " Timestamps",
        " ─────────────────────────────────────────",
        "  Last Modified: " .. (meta.last_modified or "unknown"),
        "",
        " Storage",
        " ─────────────────────────────────────────",
        "  Storage Class: " .. (meta.storage_class or "STANDARD"),
        "  ETag:          " .. (meta.etag or "unknown"),
      }

      -- Add custom metadata if present
      if meta.metadata and next(meta.metadata) then
        table.insert(lines, "")
        table.insert(lines, " Custom Metadata")
        table.insert(lines, " ─────────────────────────────────────────")
        for k, v in pairs(meta.metadata) do
          table.insert(lines, "  " .. k .. ": " .. v)
        end
      end

      show_metadata_popup("Object Metadata", lines)
    end, 10)
    return
  end

  vim.notify("No item selected", vim.log.levels.WARN)
end

-- Show help
function M.show_help()
  local lines = {
    " S3 Browser Help",
    "",
    " Navigation",
    " ─────────────────────────────────────",
    " <CR>     Expand/collapse or preview",
    " o        Toggle expand folder/bucket",
    " C-h      Cycle windows forward",
    " C-g      Cycle windows backward",
    "",
    " Search",
    " ─────────────────────────────────────",
    " /        Fuzzy search files",
    " b        Fuzzy search buckets",
    "",
    " File Operations",
    " ─────────────────────────────────────",
    " e        Edit file (save with :w)",
    " d        Download file",
    " D        Delete file",
    " r        Rename file/folder",
    "",
    " Copy/Move",
    " ─────────────────────────────────────",
    " y        Copy (yank) file",
    " m        Cut (move) file",
    " p        Paste file",
    "",
    " Other",
    " ─────────────────────────────────────",
    " i        Show info/metadata",
    " gr       Refresh current bucket",
    " R        Reload all buckets",
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

  -- Solid background (no transparency, no text showing through)
  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal"

  -- Apply highlights
  vim.api.nvim_buf_add_highlight(buf, -1, "S3Header", 0, 0, -1)

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<CR>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

return M
