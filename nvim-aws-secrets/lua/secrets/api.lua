-- AWS Secrets Manager API wrapper using AWS CLI
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

-- List all secrets
function M.list_secrets()
  local cmd = "aws secretsmanager list-secrets 2>&1"
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "AWS CLI error: " .. output
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  local secrets = {}
  for _, secret in ipairs(data.SecretList or {}) do
    table.insert(secrets, {
      name = secret.Name,
      arn = secret.ARN,
      description = secret.Description or "",
      last_changed = secret.LastChangedDate,
      last_accessed = secret.LastAccessedDate,
      created_date = secret.CreatedDate,
      tags = secret.Tags or {},
    })
  end

  -- Sort by name
  table.sort(secrets, function(a, b)
    return a.name < b.name
  end)

  return secrets, nil
end

-- Get secret value
function M.get_secret_value(secret_id)
  local cmd = string.format(
    "aws secretsmanager get-secret-value --secret-id %s 2>&1",
    vim.fn.shellescape(secret_id)
  )
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "AWS CLI error: " .. output
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  -- SecretString contains the actual value (could be JSON or plain string)
  local value = data.SecretString
  if not value and data.SecretBinary then
    -- Binary secrets are base64 encoded
    value = "[Binary Secret - Base64 encoded]\n" .. data.SecretBinary
  end

  return {
    name = data.Name,
    arn = data.ARN,
    version_id = data.VersionId,
    version_stages = data.VersionStages or {},
    value = value or "",
    created_date = data.CreatedDate,
  }, nil
end

-- Describe secret (get metadata)
function M.describe_secret(secret_id)
  local cmd = string.format(
    "aws secretsmanager describe-secret --secret-id %s 2>&1",
    vim.fn.shellescape(secret_id)
  )
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "AWS CLI error: " .. output
  end

  local data, err = parse_json(output)
  if err then
    return nil, err
  end

  return {
    name = data.Name,
    arn = data.ARN,
    description = data.Description or "",
    kms_key_id = data.KmsKeyId,
    rotation_enabled = data.RotationEnabled or false,
    rotation_lambda_arn = data.RotationLambdaARN,
    rotation_rules = data.RotationRules,
    last_rotated_date = data.LastRotatedDate,
    last_changed_date = data.LastChangedDate,
    last_accessed_date = data.LastAccessedDate,
    deleted_date = data.DeletedDate,
    tags = data.Tags or {},
    version_ids_to_stages = data.VersionIdsToStages or {},
    created_date = data.CreatedDate,
    primary_region = data.PrimaryRegion,
    replication_status = data.ReplicationStatus,
  }, nil
end

-- Try to format value as pretty JSON
function M.format_value(value)
  if not value or value == "" then
    return "(empty)"
  end

  -- Try to parse as JSON and pretty-print
  local ok, decoded = pcall(vim.fn.json_decode, value)
  if ok and type(decoded) == "table" then
    -- Pretty print JSON
    local formatted = vim.fn.json_encode(decoded)
    -- Use jq for formatting if available, otherwise manual
    local jq_result = vim.fn.system("echo " .. vim.fn.shellescape(formatted) .. " | jq '.' 2>/dev/null")
    if vim.v.shell_error == 0 and jq_result ~= "" then
      return jq_result
    end
    -- Manual simple formatting
    return M.simple_json_format(formatted)
  end

  -- Return as-is for non-JSON
  return value
end

-- Simple JSON formatter (fallback if jq not available)
function M.simple_json_format(json_str)
  local result = {}
  local indent = 0
  local in_string = false
  local escape_next = false

  for i = 1, #json_str do
    local c = json_str:sub(i, i)

    if escape_next then
      table.insert(result, c)
      escape_next = false
    elseif c == "\\" and in_string then
      table.insert(result, c)
      escape_next = true
    elseif c == '"' then
      in_string = not in_string
      table.insert(result, c)
    elseif not in_string then
      if c == "{" or c == "[" then
        table.insert(result, c)
        indent = indent + 2
        table.insert(result, "\n" .. string.rep(" ", indent))
      elseif c == "}" or c == "]" then
        indent = indent - 2
        table.insert(result, "\n" .. string.rep(" ", indent))
        table.insert(result, c)
      elseif c == "," then
        table.insert(result, c)
        table.insert(result, "\n" .. string.rep(" ", indent))
      elseif c == ":" then
        table.insert(result, ": ")
      elseif c ~= " " and c ~= "\n" and c ~= "\t" then
        table.insert(result, c)
      end
    else
      table.insert(result, c)
    end
  end

  return table.concat(result)
end

-- Check if value looks like JSON
function M.is_json(value)
  if not value then return false end
  local trimmed = value:match("^%s*(.-)%s*$")
  return trimmed:match("^{") or trimmed:match("^%[")
end

-- Format date string
function M.format_date(date_str)
  if not date_str then return "N/A" end
  -- AWS dates come in ISO format, just return as-is for now
  return date_str
end

return M
