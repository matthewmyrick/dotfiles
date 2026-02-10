-- AWS S3 API wrapper using AWS CLI
local M = {}

-- Parse JSON output from AWS CLI
local function parse_json(output)
  local ok, result = pcall(vim.fn.json_decode, output)
  if ok then
    return result, nil
  else
    return nil, "Failed to parse JSON"
  end
end

-- List all S3 buckets
function M.list_buckets()
  local cmd = "aws s3api list-buckets 2>&1"
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "AWS CLI error: " .. output
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  local buckets = {}
  for _, bucket in ipairs(data.Buckets or {}) do
    table.insert(buckets, {
      name = bucket.Name,
      creation_date = bucket.CreationDate,
    })
  end

  return buckets, nil
end

-- List objects in a bucket with optional prefix
function M.list_objects(bucket, prefix)
  prefix = prefix or ""
  local cmd = string.format(
    "aws s3api list-objects-v2 --bucket %s --prefix %s --delimiter / 2>&1",
    vim.fn.shellescape(bucket),
    vim.fn.shellescape(prefix)
  )
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "AWS CLI error: " .. output
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  local result = {
    folders = {},
    files = {},
  }

  -- Parse CommonPrefixes (folders)
  for _, cp in ipairs(data.CommonPrefixes or {}) do
    local folder_path = cp.Prefix
    local name = folder_path:sub(#prefix + 1):gsub("/$", "")
    if name ~= "" then
      table.insert(result.folders, {
        name = name,
        prefix = folder_path,
      })
    end
  end

  -- Parse Contents (files)
  for _, obj in ipairs(data.Contents or {}) do
    if obj.Key ~= prefix then
      local name = obj.Key:sub(#prefix + 1)
      if not name:match("/$") and name ~= "" then
        table.insert(result.files, {
          name = name,
          key = obj.Key,
          size = obj.Size,
          last_modified = obj.LastModified,
        })
      end
    end
  end

  return result, nil
end

-- Get object content for preview
function M.get_content(bucket, key, max_bytes)
  max_bytes = max_bytes or 102400
  local cmd = string.format(
    "aws s3api get-object --bucket %s --key %s --range bytes=0-%d /dev/stdout 2>/dev/null",
    vim.fn.shellescape(bucket),
    vim.fn.shellescape(key),
    max_bytes - 1
  )
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "Failed to fetch content"
  end

  return output, nil
end

-- Format bytes
function M.format_bytes(bytes)
  if not bytes then return "0 B" end
  if bytes < 1024 then return string.format("%d B", bytes)
  elseif bytes < 1024 * 1024 then return string.format("%.1f KB", bytes / 1024)
  elseif bytes < 1024 * 1024 * 1024 then return string.format("%.1f MB", bytes / (1024 * 1024))
  else return string.format("%.1f GB", bytes / (1024 * 1024 * 1024)) end
end

-- Get object metadata
function M.get_metadata(bucket, key)
  local cmd = string.format(
    "aws s3api head-object --bucket %s --key %s 2>&1",
    vim.fn.shellescape(bucket),
    vim.fn.shellescape(key)
  )
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "Failed to get metadata"
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  return {
    content_length = data.ContentLength,
    content_type = data.ContentType,
    last_modified = data.LastModified,
    etag = data.ETag,
    storage_class = data.StorageClass,
    metadata = data.Metadata or {},
  }, nil
end

-- Check if binary
function M.is_binary(filename)
  local binary_ext = { "png", "jpg", "jpeg", "gif", "pdf", "zip", "tar", "gz", "exe", "bin", "mp3", "mp4" }
  local ext = filename:match("%.([^%.]+)$")
  if ext then
    ext = ext:lower()
    for _, b in ipairs(binary_ext) do
      if ext == b then return true end
    end
  end
  return false
end

-- Get filetype for syntax highlighting
function M.get_filetype(filename)
  local map = {
    lua = "lua", py = "python", js = "javascript", ts = "typescript",
    json = "json", yaml = "yaml", yml = "yaml", xml = "xml",
    html = "html", css = "css", md = "markdown", sh = "sh",
    sql = "sql", txt = "text", log = "text", csv = "csv",
  }
  local ext = filename:match("%.([^%.]+)$")
  return ext and map[ext:lower()] or "text"
end

return M
