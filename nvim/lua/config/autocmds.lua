-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-format terragrunt.hcl files on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "terragrunt.hcl",
  callback = function()
    local file = vim.fn.expand("%:p")
    vim.cmd("silent !terragrunt hclfmt " .. file)
    vim.cmd("edit!")
  end,
  group = vim.api.nvim_create_augroup("TerragruntFormat", { clear = true }),
  desc = "Format terragrunt.hcl files on save",
})

-- Prevent Snacks explorer from closing
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(args)
    local buf = vim.api.nvim_win_get_buf(args.match)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "snacks_explorer" then
      -- Re-open the explorer if it was closed
      vim.defer_fn(function()
        if Snacks and Snacks.explorer then
          Snacks.explorer()
        end
      end, 10)
    end
  end,
  group = vim.api.nvim_create_augroup("KeepExplorerOpen", { clear = true }),
  desc = "Keep Snacks explorer open",
})
