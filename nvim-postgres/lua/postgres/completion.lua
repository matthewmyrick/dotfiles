-- SQL completion module - provides table/column name completion from cached schema data
local M = {}

local connections = require("postgres.connections")
local query_mod = require("postgres.query")

-- Build completion items from drawer state
function M.get_completions(base)
  local drawer = require("postgres.drawer")
  local state = drawer.get_state()
  local items = {}
  local seen = {}
  local lower_base = (base or ""):lower()

  -- Add table/view names from cached data
  for schema_key, tables in pairs(state.tables or {}) do
    local conn_id, schema = schema_key:match("^(.+):(.+)$")
    if conn_id and schema then
      if not seen[schema] then
        seen[schema] = true
        if schema:lower():find(lower_base, 1, true) then
          table.insert(items, { word = schema, menu = "[schema]" })
        end
      end

      for _, tbl in ipairs(tables) do
        if not seen[tbl.name] then
          seen[tbl.name] = true
          local kind = tbl.type == "VIEW" and "[view]" or "[table]"
          if tbl.name:lower():find(lower_base, 1, true) then
            table.insert(items, { word = tbl.name, menu = kind })
          end
        end

        local qualified = schema .. "." .. tbl.name
        if not seen[qualified] then
          seen[qualified] = true
          local kind = tbl.type == "VIEW" and "[view]" or "[table]"
          if qualified:lower():find(lower_base, 1, true) then
            table.insert(items, { word = qualified, menu = kind })
          end
        end
      end
    end
  end

  -- Add column names from active connection if available
  local active_conn = connections.get_active()
  if active_conn then
    for schema_key, tables in pairs(state.tables or {}) do
      local conn_id, schema = schema_key:match("^(.+):(.+)$")
      if conn_id and schema then
        local col_cache_key = "cols:" .. schema_key
        if not state[col_cache_key] then
          state[col_cache_key] = {}
          for _, tbl in ipairs(tables) do
            local cols = query_mod.get_columns(active_conn, schema, tbl.name)
            if cols then
              state[col_cache_key][tbl.name] = cols
            end
          end
        end
        for tbl_name, cols in pairs(state[col_cache_key] or {}) do
          for _, col in ipairs(cols) do
            if not seen[col.name] then
              seen[col.name] = true
              if col.name:lower():find(lower_base, 1, true) then
                table.insert(items, { word = col.name, menu = tbl_name .. " [" .. col.type .. "]" })
              end
            end
          end
        end
      end
    end
  end

  return items
end

-- Trigger completion from insert mode
function M.complete()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Find start of current word
  local start = col
  while start > 0 and line:sub(start, start):match("[%w_.]") do
    start = start - 1
  end
  local base = line:sub(start + 1, col)

  local items = M.get_completions(base)

  if #items == 0 then
    vim.notify("No completions (expand a schema in the drawer first)", vim.log.levels.WARN)
    return
  end

  -- Use vim.fn.complete to show popup
  vim.fn.complete(start + 1, items)
end

return M
