-- nvim-aws-secrets: AWS Secrets Manager Browser for Neovim
-- Tree view browser for AWS Secrets Manager (read-only)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.swapfile = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  checker = {
    enabled = false,
  },
})

-- Load Secrets plugin
require("secrets").setup()

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 200 })
  end,
})

-- yag/vag keymaps
vim.keymap.set("n", "vag", "ggVG", { desc = "Select entire buffer" })
vim.keymap.set("n", "yag", "ggyG", { desc = "Yank entire buffer" })

-- AWS regions
local aws_regions = {
  "us-east-1",
  "us-east-2",
  "us-west-1",
  "us-west-2",
  "eu-west-1",
  "eu-west-2",
  "eu-central-1",
  "ap-northeast-1",
  "ap-southeast-1",
  "ap-southeast-2",
}

-- Startup: Show region picker (Telescope), then open drawer with secrets
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      pickers.new({}, {
        prompt_title = "Select AWS Region",
        finder = finders.new_table({ results = aws_regions }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              -- Set region
              require("secrets").set_region(selection[1])

              -- Open drawer and load secrets
              local drawer = require("secrets.drawer")
              drawer.open()
              drawer.load_secrets()
            end
          end)
          return true
        end,
      }):find()
    end)
  end,
})

-- Keymaps
vim.keymap.set("n", "<leader>so", function()
  require("secrets.drawer").open()
end, { desc = "Open Secrets drawer" })

vim.keymap.set("n", "<leader>sc", function()
  require("secrets.drawer").close()
end, { desc = "Close Secrets drawer" })

vim.keymap.set("n", "<leader>sr", function()
  require("secrets.drawer").load_secrets()
end, { desc = "Reload secrets" })

vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qq", function()
  vim.cmd("qa!")
end, { desc = "Force Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })

-- Window navigation (cycle through all windows)
local function cycle_windows()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  local normal_wins = {}

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      table.insert(normal_wins, win)
    end
  end

  if #normal_wins > 1 then
    local current_idx = 1
    for i, win in ipairs(normal_wins) do
      if win == current_win then
        current_idx = i
        break
      end
    end
    local next_idx = (current_idx % #normal_wins) + 1
    vim.api.nvim_set_current_win(normal_wins[next_idx])
  end
end

local function cycle_windows_backward()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  local normal_wins = {}

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      table.insert(normal_wins, win)
    end
  end

  if #normal_wins > 1 then
    local current_idx = 1
    for i, win in ipairs(normal_wins) do
      if win == current_win then
        current_idx = i
        break
      end
    end
    local prev_idx = current_idx - 1
    if prev_idx < 1 then
      prev_idx = #normal_wins
    end
    vim.api.nvim_set_current_win(normal_wins[prev_idx])
  end
end

vim.keymap.set("n", "<C-h>", cycle_windows, { desc = "Cycle windows forward" })
vim.keymap.set("n", "<C-g>", cycle_windows_backward, { desc = "Cycle windows backward" })

-- Global search for secrets with /
vim.keymap.set("n", "/", function()
  -- If in drawer, use drawer's fuzzy search
  if vim.bo.filetype == "secrets-drawer" then
    require("secrets.drawer").fuzzy_search()
  else
    -- Otherwise use default vim search
    vim.api.nvim_feedkeys("/", "n", false)
  end
end, { desc = "Search" })

-- Fuzzy search lines in current buffer with backslash
vim.keymap.set("n", "\\", function()
  local builtin = require("telescope.builtin")
  local filename = vim.fn.expand("%:t")

  builtin.current_buffer_fuzzy_find({
    prompt_title = "Search Lines in Current Buffer",
    results_title = "Matches in " .. filename,
    preview_title = "Context Preview",
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.6,
      width = 0.95,
      height = 0.85,
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    default_text = "",
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
          vim.cmd("normal! zz")
        end
      end)
      return true
    end,
    preview = {
      treesitter = false,
    },
  })
end, { desc = "Fuzzy search in current buffer" })

-- Metadata command to view secret metadata
vim.api.nvim_create_user_command("SecretsMeta", function()
  require("secrets.drawer").show_current_metadata()
end, { desc = "Show secret metadata" })

vim.keymap.set("n", "<leader>m", "<cmd>SecretsMeta<CR>", { desc = "Show secret metadata" })
