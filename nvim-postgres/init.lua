-- nvim-postgres: PostgreSQL client for Neovim
-- Custom plugin for managing PostgreSQL connections and queries

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

-- Load postgres plugin
require("postgres").setup()

-- Keymaps
vim.keymap.set("n", "<leader>po", function()
  require("postgres.drawer").open()
end, { desc = "Open Postgres drawer" })

vim.keymap.set("n", "<leader>pc", function()
  require("postgres.drawer").close()
end, { desc = "Close Postgres drawer" })

vim.keymap.set("n", "<leader>pt", function()
  require("postgres.drawer").toggle()
end, { desc = "Toggle Postgres drawer" })

vim.keymap.set("n", "<leader>pa", function()
  require("postgres.connections").add()
end, { desc = "Add new connection" })

vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa!<CR>", { desc = "Force Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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

-- Write file
vim.keymap.set("n", "<leader>ww", "<cmd>w<CR>", { desc = "Write file" })

-- Global fuzzy search for SQL files with /
vim.keymap.set("n", "/", function()
  local sql_dir = require("postgres").config.sql_directory
  local has_telescope, builtin = pcall(require, "telescope.builtin")
  if has_telescope then
    builtin.find_files({
      cwd = sql_dir,
      prompt_title = "Search SQL Files",
    })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
end, { desc = "Search SQL files" })

-- Global fuzzy search for tables with \
vim.keymap.set("n", "\\", function()
  require("postgres.drawer").fuzzy_search_tables()
end, { desc = "Search tables" })

-- Claude terminal helper functions
local function set_terminal_name(name)
  if name == "" or name == nil then
    name = "terminal"
  end
  local base_name = name
  local counter = 1
  local full_name = "$ " .. name

  local existing_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" then
        local filename = vim.fn.fnamemodify(buf_name, ":t")
        existing_buffers[filename] = true
      end
    end
  end

  while existing_buffers[full_name] do
    counter = counter + 1
    full_name = "$ " .. base_name .. " " .. counter
  end

  vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

local function create_claude_terminal(use_continue)
  local nvm_dir = vim.fn.expand("$HOME/.nvm")
  local node_version = vim.fn.system("source " .. nvm_dir .. "/nvm.sh && nvm current"):gsub("%s+", "")
  local claude_path = nvm_dir .. "/versions/node/" .. node_version .. "/bin/claude"

  local claude_cmd
  if vim.fn.filereadable(claude_path) == 1 then
    claude_cmd = claude_path .. (use_continue and " --continue" or "")
  else
    claude_cmd = "claude" .. (use_continue and " --continue" or "")
  end

  vim.cmd("terminal " .. claude_cmd)

  vim.schedule(function()
    set_terminal_name("claude")
  end)

  if use_continue then
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for _, line in ipairs(lines) do
              if line:match("No conversation found") then
                vim.cmd("terminal " .. (vim.fn.filereadable(claude_path) == 1 and claude_path or "claude"))
                vim.schedule(function()
                  set_terminal_name("claude")
                end)
                vim.notify("No previous conversation found, started new Claude session", vim.log.levels.INFO)
                return
              end
            end
          end)
        end
      })
    end)
  end
end

local function find_claude_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name ~= "" then
        local filename = vim.fn.fnamemodify(buf_name, ":t")
        if filename == "$ claude" then
          return buf
        end
      end
    end
  end
  return nil
end

-- Claude vertical terminal command (toggle)
vim.api.nvim_create_user_command("ClaudeVerticalTerm", function()
  local claude_buf = find_claude_buffer()

  -- Check if Claude window is currently open
  if claude_buf then
    local claude_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == claude_buf then
        claude_win = win
        break
      end
    end

    if claude_win then
      -- Claude window is open - close it
      vim.api.nvim_win_close(claude_win, false)
      return
    end
  end

  -- Calculate 33% of total editor width (not current window)
  local total_width = vim.o.columns
  local third_width = math.floor(total_width * 0.33)

  -- Find the main editor window (not neo-tree, not postgres-drawer, not results)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if ft ~= "neo-tree" and ft ~= "postgres-drawer" and ft ~= "postgres-results" and not buf_name:match("postgres://") then
      target_win = win
      break
    end
  end

  if claude_buf then
    -- Claude buffer exists but window is closed - reopen it
    if target_win then
      vim.api.nvim_set_current_win(target_win)
    end
    vim.cmd("botright vsplit")
    vim.cmd("vertical resize " .. third_width)
    vim.api.nvim_set_current_buf(claude_buf)
    return
  end

  -- No Claude buffer - create new one
  if target_win then
    vim.api.nvim_set_current_win(target_win)
  end
  vim.cmd("botright vsplit")
  vim.cmd("vertical resize " .. third_width)
  -- Start fresh Claude session (no --continue)
  create_claude_terminal(false)
end, { nargs = 0, desc = "Toggle Claude in 33% Vertical Split" })

-- Claude close-only command (for <leader>wq - only closes, never opens)
vim.api.nvim_create_user_command("ClaudeCloseTerm", function()
  local claude_buf = find_claude_buffer()

  if claude_buf then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == claude_buf then
        vim.api.nvim_win_close(win, false)
        return
      end
    end
  end
  -- If Claude window is not open, do nothing (don't reopen it)
end, { nargs = 0, desc = "Close Claude panel (if open)" })

-- Claude terminal keymaps
vim.keymap.set("n", "<leader>tc", "<cmd>ClaudeVerticalTerm<CR>", { desc = "Toggle Claude (33% split)" })
vim.keymap.set("n", "<leader>wq", "<cmd>ClaudeCloseTerm<CR>", { desc = "Close Claude panel" })

-- Run SQL query
vim.keymap.set("n", "<leader>rr", function()
  local query = require("postgres.query")
  local results_pane = require("postgres.results")

  local results, err, conn_name = query.run_buffer_sql()
  if err then
    results_pane.display(nil, err, nil)
  else
    results_pane.display(results, nil, conn_name)
  end
end, { desc = "Run SQL query" })

-- Toggle results pane
vim.keymap.set("n", "<leader>rt", function()
  require("postgres.results").toggle()
end, { desc = "Toggle results pane" })
