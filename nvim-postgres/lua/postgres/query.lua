-- Query module - execute psql commands and fetch data
local M = {}

local connections = require("postgres.connections")

-- Execute a query and return results
function M.execute(connection, sql)
  local url = connections.get_url(connection)

  -- Use psql to execute query
  local cmd = string.format(
    'psql "%s" -t -A -F "	" -c %s 2>&1',
    url,
    vim.fn.shellescape(sql)
  )

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    return nil, output
  end

  -- Parse output into rows
  local rows = {}
  for line in output:gmatch("[^\r\n]+") do
    if line ~= "" then
      local cols = {}
      for col in line:gmatch("[^	]+") do
        table.insert(cols, col)
      end
      if #cols > 0 then
        table.insert(rows, cols)
      end
    end
  end

  return rows, nil
end

-- Get all schemas for a connection
function M.get_schemas(connection)
  local sql = [[
    SELECT schema_name
    FROM information_schema.schemata
    WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    ORDER BY schema_name
  ]]

  local rows, err = M.execute(connection, sql)
  if err then
    return nil, err
  end

  local schemas = {}
  for _, row in ipairs(rows) do
    table.insert(schemas, row[1])
  end

  return schemas, nil
end

-- Get all tables for a schema
function M.get_tables(connection, schema)
  local sql = string.format([[
    SELECT table_name, table_type
    FROM information_schema.tables
    WHERE table_schema = '%s'
    ORDER BY table_type, table_name
  ]], schema)

  local rows, err = M.execute(connection, sql)
  if err then
    return nil, err
  end

  local tables = {}
  for _, row in ipairs(rows) do
    table.insert(tables, {
      name = row[1],
      type = row[2], -- 'BASE TABLE' or 'VIEW'
    })
  end

  return tables, nil
end

-- Get columns for a table
function M.get_columns(connection, schema, table_name)
  local sql = string.format([[
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = '%s' AND table_name = '%s'
    ORDER BY ordinal_position
  ]], schema, table_name)

  local rows, err = M.execute(connection, sql)
  if err then
    return nil, err
  end

  local columns = {}
  for _, row in ipairs(rows) do
    table.insert(columns, {
      name = row[1],
      type = row[2],
      nullable = row[3] == "YES",
    })
  end

  return columns, nil
end

-- Test connection
function M.test_connection(connection)
  local sql = "SELECT 1"
  local rows, err = M.execute(connection, sql)
  if err then
    return false, err
  end
  return true, nil
end

-- Parse a CSV line properly handling quoted fields
local function parse_csv_line(line)
  local fields = {}
  local field = ""
  local in_quotes = false
  local i = 1

  while i <= #line do
    local c = line:sub(i, i)

    if in_quotes then
      if c == '"' then
        -- Check for escaped quote (doubled)
        if line:sub(i + 1, i + 1) == '"' then
          field = field .. '"'
          i = i + 2
        else
          -- End of quoted field
          in_quotes = false
          i = i + 1
        end
      else
        field = field .. c
        i = i + 1
      end
    else
      if c == '"' then
        in_quotes = true
        i = i + 1
      elseif c == ',' then
        table.insert(fields, field)
        field = ""
        i = i + 1
      else
        field = field .. c
        i = i + 1
      end
    end
  end

  -- Add last field
  table.insert(fields, field)

  return fields
end

-- Execute a query with column headers (for results display)
function M.execute_with_headers(connection, sql)
  local url = connections.get_url(connection)

  -- Use CSV format which properly handles escaping of special characters in data
  local cmd = string.format(
    'psql "%s" --csv -c %s 2>&1',
    url,
    vim.fn.shellescape(sql)
  )

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    return nil, output
  end

  -- Parse CSV output - first line is headers, rest is data
  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
    if line ~= "" then
      table.insert(lines, line)
    end
  end

  if #lines == 0 then
    return { columns = {}, rows = {} }, nil
  end

  -- First line contains column headers
  local columns = parse_csv_line(lines[1])

  -- Rest are data rows
  local rows = {}
  for i = 2, #lines do
    local row = parse_csv_line(lines[i])
    -- Ensure row has same number of columns
    while #row < #columns do
      table.insert(row, "")
    end
    if #row > 0 then
      table.insert(rows, row)
    end
  end

  return { columns = columns, rows = rows }, nil
end

-- Run SQL from buffer content
function M.run_buffer_sql(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sql = table.concat(lines, "\n")

  if sql:match("^%s*$") then
    return nil, "No SQL to execute"
  end

  -- Get active connection
  local active_conn = connections.get_active()
  if not active_conn then
    return nil, "No active connection. Select a connection first."
  end

  local results, err = M.execute_with_headers(active_conn, sql)

  -- Build query info with connection and SQL
  local query_info = {
    connection = active_conn.name,
    database = active_conn.database,
    sql = sql,
  }

  return results, err, query_info
end

return M
