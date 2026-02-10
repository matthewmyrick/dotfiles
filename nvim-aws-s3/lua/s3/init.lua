-- Main S3 plugin module
local M = {}

M.config = {
  drawer_width = 40,
  preview_max_bytes = 102400, -- 100KB
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
