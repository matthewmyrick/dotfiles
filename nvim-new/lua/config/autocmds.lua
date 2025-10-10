-- Autocmds
local function augroup(name)
  return vim.api.nvim_create_augroup("myconfig_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Force Snacks explorer to be transparent - NUCLEAR OPTION
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter", "BufWinEnter" }, {
  group = augroup("force_explorer_transparent"),
  callback = function()
    local ft = vim.bo.filetype
    if ft == "snacks_explorer" or ft == "snacks_picker" or ft == "snacks_picker_list" or string.match(ft, "^snacks") then
      vim.schedule(function()
        vim.wo.winhighlight = "Normal:Normal,NormalNC:Normal,NormalFloat:Normal,FloatBorder:Normal,EndOfBuffer:Normal,SignColumn:Normal,CursorLine:NONE,CursorLineNr:NONE,VertSplit:Normal,StatusLine:Normal,StatusLineNC:Normal"
        vim.wo.winblend = 0
        vim.wo.cursorline = false
      end)
    end
  end,
})

-- Ensure no bottom gap from Noice
vim.api.nvim_create_autocmd("VeryLazy", {
  group = augroup("fix_bottom_gap"),
  callback = function()
    vim.opt.cmdheight = 0
    vim.opt.laststatus = 3
  end,
})
