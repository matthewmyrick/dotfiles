-- Main postgres plugin module
local M = {}

M.config = {
  -- Default configuration
  connections_file = vim.fn.stdpath("data") .. "/postgres/connections.json",
  drawer_width = 40,
  sql_directory = vim.fn.expand("~/.config/nvim-postgres/sql"),
  queries_directory = vim.fn.expand("~/.config/nvim-postgres/queries"),
  procrastinate_queries_directory = vim.fn.expand("~/.config/nvim-postgres/queries/procrastinate"),
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Ensure data directory exists
  local data_dir = vim.fn.fnamemodify(M.config.connections_file, ":h")
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, "p")
  end

  -- Ensure SQL directory exists
  if vim.fn.isdirectory(M.config.sql_directory) == 0 then
    vim.fn.mkdir(M.config.sql_directory, "p")
  end

  -- Create user commands
  vim.api.nvim_create_user_command("PgOpen", function()
    require("postgres.drawer").open()
  end, { desc = "Open Postgres drawer" })

  vim.api.nvim_create_user_command("PgClose", function()
    require("postgres.drawer").close()
  end, { desc = "Close Postgres drawer" })

  vim.api.nvim_create_user_command("PgToggle", function()
    require("postgres.drawer").toggle()
  end, { desc = "Toggle Postgres drawer" })

  vim.api.nvim_create_user_command("PgAddConnection", function()
    require("postgres.connections").add()
  end, { desc = "Add new Postgres connection" })

  -- Auto-open drawer on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        require("postgres.drawer").open()
      end, 100)
    end,
  })
end

return M
