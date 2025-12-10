-- Connection management module
local M = {}

-- State
local state = {
  active_connection_id = nil,
}

-- Get connections file path
local function get_connections_file()
  return require("postgres").config.connections_file
end

-- Load connections from file
function M.load()
  local file_path = get_connections_file()
  if vim.fn.filereadable(file_path) == 0 then
    return {}
  end

  local content = vim.fn.readfile(file_path)
  if #content == 0 then
    return {}
  end

  local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok then
    vim.notify("Failed to parse connections file", vim.log.levels.ERROR)
    return {}
  end

  return data.connections or {}
end

-- Save connections to file
function M.save(connections)
  local file_path = get_connections_file()
  local data = { connections = connections }
  local json = vim.json.encode(data)

  -- Pretty print JSON
  local formatted = vim.fn.system("echo '" .. json .. "' | jq '.'")
  if vim.v.shell_error ~= 0 then
    formatted = json
  end

  vim.fn.writefile(vim.split(formatted, "\n"), file_path)
end

-- Add a new connection
function M.add()
  local ui = require("postgres.ui")

  ui.open_connection_form(nil, function(connection)
    local connections = M.load()
    table.insert(connections, connection)
    M.save(connections)

    vim.notify("Connection '" .. connection.name .. "' added", vim.log.levels.INFO)
    require("postgres.drawer").refresh()
  end)
end

-- Edit a connection
function M.edit(id)
  local connections = M.load()
  local conn_idx = nil
  local connection = nil

  for i, c in ipairs(connections) do
    if c.id == id then
      conn_idx = i
      connection = c
      break
    end
  end

  if not connection then
    vim.notify("Connection not found", vim.log.levels.ERROR)
    return
  end

  local ui = require("postgres.ui")

  ui.open_connection_form(connection, function(updated_connection)
    connections[conn_idx] = updated_connection
    M.save(connections)

    vim.notify("Connection '" .. updated_connection.name .. "' updated", vim.log.levels.INFO)
    require("postgres.drawer").refresh()
  end)
end

-- Delete a connection
function M.delete(id)
  local connections = M.load()
  local conn_name = nil

  for i, c in ipairs(connections) do
    if c.id == id then
      conn_name = c.name
      table.remove(connections, i)
      break
    end
  end

  if conn_name then
    M.save(connections)
    vim.notify("Connection '" .. conn_name .. "' deleted", vim.log.levels.INFO)
    require("postgres.drawer").refresh()
  else
    vim.notify("Connection not found", vim.log.levels.ERROR)
  end
end

-- Get connection by ID
function M.get(id)
  local connections = M.load()
  for _, c in ipairs(connections) do
    if c.id == id then
      return c
    end
  end
  return nil
end

-- Build connection URL
function M.get_url(connection)
  local ssl_param = connection.ssl and "sslmode=require" or "sslmode=disable"
  return string.format(
    "postgresql://%s:%s@%s:%s/%s?%s",
    connection.user,
    connection.password,
    connection.host,
    connection.port,
    connection.database,
    ssl_param
  )
end

-- Set active connection
function M.set_active(id)
  state.active_connection_id = id
  local conn = M.get(id)
  if conn then
    vim.notify("Active connection: " .. conn.name, vim.log.levels.INFO)
  end
end

-- Get active connection
function M.get_active()
  if not state.active_connection_id then
    return nil
  end
  return M.get(state.active_connection_id)
end

-- Get active connection ID
function M.get_active_id()
  return state.active_connection_id
end

return M
