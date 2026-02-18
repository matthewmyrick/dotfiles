-- Main Secrets plugin module
local M = {}

M.config = {
  drawer_width = 50,
  preview_max_lines = 1000,
}

M.state = {
  region = nil,
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.get_region()
  return M.state.region
end

function M.set_region(region)
  M.state.region = region
  vim.env.AWS_DEFAULT_REGION = region
end

return M
