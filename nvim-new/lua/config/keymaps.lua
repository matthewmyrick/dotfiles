-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Simple circular window navigation using wincmd (skip explorer)
local function cycle_windows()
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    local normal_wins = {}
    
    -- Get all non-floating, non-explorer windows
    for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        
        -- Skip floating windows and explorer
        if config.relative == "" and ft ~= "snacks_explorer" then
            table.insert(normal_wins, win)
        end
    end
    
    -- If we have multiple windows, cycle through them
    if #normal_wins > 1 then
        -- Find current window index
        local current_idx = 1
        for i, win in ipairs(normal_wins) do
            if win == current_win then
                current_idx = i
                break
            end
        end
        
        -- Move to next window (with wrapping)
        local next_idx = (current_idx % #normal_wins) + 1
        vim.api.nvim_set_current_win(normal_wins[next_idx])
    end
end

-- Override Ctrl+H to cycle through ALL windows in order
vim.keymap.set("n", "<C-h>", cycle_windows, { desc = "Cycle through all windows" })

-- Alternative: Use standard vim directional navigation but with fallback
vim.keymap.set("n", "<C-l>", function()
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd l")
    -- If we didn't move, wrap around
    if vim.api.nvim_get_current_win() == current_win then
        vim.cmd("wincmd t")  -- Go to top-left window
    end
end, { desc = "Go right or wrap to first window" })

-- Keep vertical navigation as standard
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })

-- Escape Terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {})

-- Disable number + gt tab switching (1gt, 2gt, etc.)
for i = 1, 9 do
  vim.keymap.set("n", i .. "gt", "<Nop>", { desc = "Disabled" })
  vim.keymap.set("n", i .. "gT", "<Nop>", { desc = "Disabled" })
end

-- File Explorer keybindings (never closes, only opens or focuses)
vim.keymap.set("n", "<leader>e", function()
    -- Check if explorer is already open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "snacks_explorer" then
            -- Explorer is open, just focus it
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    
    -- Explorer not open, open it
    if Snacks and Snacks.explorer then
        Snacks.explorer()
    else
        vim.notify("Snacks explorer not available", vim.log.levels.WARN)
    end
end, { desc = "Open/Focus File Explorer" })

-- Save file with <leader>ww
vim.keymap.set("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save file" })

-- Close/quit current window with <leader>wq
vim.keymap.set("n", "<leader>wq", "<cmd>q<CR>", { desc = "Close window" })

-- Quit Neovim entirely with <leader>qq
vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit Neovim" })

-- Split current window vertically with file picker
vim.keymap.set("n", "<leader>wv", function()
    vim.cmd("vsplit")
    vim.schedule(function()
        if Snacks and Snacks.picker then
            Snacks.picker.files()
        elseif package.loaded["telescope"] then
            require("telescope.builtin").find_files()
        else
            vim.notify("No file picker available", vim.log.levels.WARN)
        end
    end)
end, { desc = "Split window vertically with picker" })

-- Split current window horizontally with file picker
vim.keymap.set("n", "<leader>wh", function()
    vim.cmd("split")
    vim.schedule(function()
        if Snacks and Snacks.picker then
            Snacks.picker.files()
        elseif package.loaded["telescope"] then
            require("telescope.builtin").find_files()
        else
            vim.notify("No file picker available", vim.log.levels.WARN)
        end
    end)
end, { desc = "Split window horizontally with picker" })

-- Focus/jump to file explorer if it's open
vim.keymap.set("n", "<leader>fe", function()
    -- Look for explorer window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "snacks_explorer" then
            -- Explorer found, focus it
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    -- Explorer not open, notify user
    vim.notify("Explorer is not open. Use <leader>e to open it.", vim.log.levels.INFO)
end, { desc = "Focus File Explorer" })

-- Swap 0 and ^ keybindings
vim.keymap.set({ "n", "v" }, "0", "^", { desc = "Go to first non-blank character" })
vim.keymap.set({ "n", "v" }, "^", "0", { desc = "Go to beginning of line" })

-- Make dd delete without copying to clipboard (use black hole register)
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without copying" })
vim.keymap.set("v", "d", '"_d', { desc = "Delete selection without copying" })

-- Override <leader><leader> to focus/open file explorer
vim.keymap.set("n", "<leader><leader>", function()
    if Snacks and Snacks.explorer then
        -- Check if explorer is already open
        local explorer_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "snacks_explorer" then
                explorer_win = win
                break
            end
        end
        
        if explorer_win then
            -- Explorer is open, just focus it
            vim.api.nvim_set_current_win(explorer_win)
        else
            -- Explorer not open, open it
            Snacks.explorer()
        end
    else
        vim.notify("Snacks explorer not available", vim.log.levels.WARN)
    end
end, { desc = "Focus/Open File Explorer" })

-- Override <leader>sg to use current window for live grep
vim.keymap.set("n", "<leader>sg", function()
    local ok, snacks = pcall(function()
        return Snacks
    end)
    if ok and snacks and snacks.picker then
        -- Use Snacks picker with edit action to open in current window
        snacks.picker.grep({
            action = function(item, ctx)
                -- Edit in current window instead of split
                vim.cmd("edit " .. item.file)
                if item.pos and item.pos[1] then
                    vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] or 0 })
                end
            end,
        })
    elseif package.loaded["telescope"] then
        -- Fallback to Telescope if Snacks is not available
        require("telescope.builtin").live_grep()
    else
        vim.notify("No grep picker available", vim.log.levels.WARN)
    end
end, { desc = "Grep (current window)" })

-- Override <leader>sG to use current window for grep string
vim.keymap.set("n", "<leader>sG", function()
    local ok, snacks = pcall(function()
        return Snacks
    end)
    if ok and snacks and snacks.picker then
        -- Use Snacks picker with edit action to open in current window
        snacks.picker.grep_word({
            action = function(item, ctx)
                -- Edit in current window instead of split
                vim.cmd("edit " .. item.file)
                if item.pos and item.pos[1] then
                    vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] or 0 })
                end
            end,
        })
    elseif package.loaded["telescope"] then
        -- Fallback to Telescope if Snacks is not available
        require("telescope.builtin").grep_string()
    else
        vim.notify("No grep string picker available", vim.log.levels.WARN)
    end
end, { desc = "Grep string (current window)" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Helper function to check if buffer is a Claude terminal
local function is_claude_terminal(bufnr)
    if vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "terminal" then
        return false
    end
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    return string.find(string.lower(buf_name), "claude") ~= nil
end

-- Helper function to check if currently in file explorer
local function is_in_explorer()
    local current_ft = vim.bo.filetype
    return current_ft == "snacks_explorer"
end

-- Helper function to open buffer with smart split logic
local function open_buffer_smart(bufnr)
    if is_claude_terminal(bufnr) then
        -- Open Claude terminal in vertical split on the right
        vim.cmd("vertical rightbelow split")
        vim.api.nvim_set_current_buf(bufnr)
    else
        -- Open normally in current window
        vim.api.nvim_set_current_buf(bufnr)
    end
end

-- Buffer search keymaps
vim.keymap.set("n", "<leader>bf", function()
    -- Don't work in file explorer
    if is_in_explorer() then
        vim.notify("Buffer search disabled in file explorer", vim.log.levels.INFO)
        return
    end
    
    if package.loaded["telescope"] then
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        require("telescope.builtin").buffers({
            sort_mru = true,
            sort_lastused = true,
            show_all_buffers = true,
            previewer = require("telescope.config").values.file_previewer({}),
            attach_mappings = function(prompt_bufnr, map)
                -- Override default select action
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if selection then
                        open_buffer_smart(selection.bufnr)
                    end
                end)
                
                -- Custom delete mappings with Claude terminal check
                local function smart_delete_buffer()
                    local selection = action_state.get_selected_entry()
                    if selection then
                        local buf = selection.bufnr
                        if is_claude_terminal(buf) then
                            vim.ui.input({
                                prompt = "Delete Claude terminal? (y/N): ",
                                default = "N",
                            }, function(input)
                                if input and string.lower(input) == "y" then
                                    vim.api.nvim_buf_delete(buf, { force = true })
                                    vim.notify("Claude terminal deleted", vim.log.levels.INFO)
                                end
                            end)
                        else
                            local is_terminal = vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"
                            vim.api.nvim_buf_delete(buf, { force = is_terminal })
                        end
                    end
                end
                
                map("n", "dd", smart_delete_buffer)
                map("i", "<C-d>", smart_delete_buffer)
                return true
            end,
        })
    else
        local ok, snacks = pcall(function()
            return Snacks
        end)
        if ok and snacks and snacks.picker then
            snacks.picker.buffers()
        else
            vim.notify("No buffer picker available", vim.log.levels.WARN)
        end
    end
end, { desc = "Search open buffers (smart split)" })

-- Alternative buffer search with Telescope (with smart split)
vim.keymap.set("n", "<leader>fb", function()
    -- Don't work in file explorer
    if is_in_explorer() then
        vim.notify("Buffer search disabled in file explorer", vim.log.levels.INFO)
        return
    end
    
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    require("telescope.builtin").buffers({
        attach_mappings = function(prompt_bufnr, map)
            -- Override default select action
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    open_buffer_smart(selection.bufnr)
                end
            end)
            return true
        end,
    })
end, { desc = "Find buffers (smart split)" })

-- Mass buffer deletion with multi-select using Telescope
vim.keymap.set("n", "<leader>fBd", function()
    require("telescope.builtin").buffers({
        sort_mru = true,
        sort_lastused = true,
        show_all_buffers = true,
        prompt_title = "Delete Buffers (Tab to select multiple)",
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- Custom multi-select delete action
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local multi_selections = picker:get_multi_selection()

                if #multi_selections > 0 then
                    -- Check if any are Claude terminals
                    local claude_terminals = {}
                    local other_buffers = {}
                    
                    for _, entry in ipairs(multi_selections) do
                        if is_claude_terminal(entry.bufnr) then
                            table.insert(claude_terminals, entry)
                        else
                            table.insert(other_buffers, entry)
                        end
                    end
                    
                    -- Delete non-Claude buffers first
                    for _, entry in ipairs(other_buffers) do
                        local is_terminal = vim.api.nvim_buf_get_option(entry.bufnr, "buftype") == "terminal"
                        vim.api.nvim_buf_delete(entry.bufnr, { force = is_terminal })
                    end
                    
                    -- Ask about Claude terminals if any
                    if #claude_terminals > 0 then
                        vim.ui.input({
                            prompt = string.format("Delete %d Claude terminal(s)? (y/N): ", #claude_terminals),
                            default = "N",
                        }, function(input)
                            if input and string.lower(input) == "y" then
                                for _, entry in ipairs(claude_terminals) do
                                    vim.api.nvim_buf_delete(entry.bufnr, { force = true })
                                end
                                vim.notify(string.format("Deleted %d buffer(s)", #multi_selections), vim.log.levels.INFO)
                            else
                                vim.notify(string.format("Deleted %d buffer(s), %d Claude terminal(s) kept", #other_buffers, #claude_terminals), vim.log.levels.INFO)
                            end
                        end)
                    else
                        vim.notify(string.format("Deleted %d buffer(s)", #multi_selections), vim.log.levels.INFO)
                    end
                else
                    local selection = action_state.get_selected_entry()
                    if selection then
                        if is_claude_terminal(selection.bufnr) then
                            vim.ui.input({
                                prompt = "Delete Claude terminal? (y/N): ",
                                default = "N",
                            }, function(input)
                                if input and string.lower(input) == "y" then
                                    vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                                    vim.notify("Deleted 1 buffer", vim.log.levels.INFO)
                                end
                            end)
                        else
                            local is_terminal = vim.api.nvim_buf_get_option(selection.bufnr, "buftype") == "terminal"
                            vim.api.nvim_buf_delete(selection.bufnr, { force = is_terminal })
                            vim.notify("Deleted 1 buffer", vim.log.levels.INFO)
                        end
                    end
                end
                actions.close(prompt_bufnr)
            end)

            -- Map Tab to toggle selection for multi-select
            map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
            map("n", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("n", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)

            return true
        end,
    })
end, { desc = "Find and delete buffers (multi-select)" })

-- Quick buffer delete current buffer
vim.keymap.set("n", "<leader>bd", function()
    local buf = vim.api.nvim_get_current_buf()
    local wins = vim.fn.getbufinfo(buf)[1].windows

    -- Check if this is the last window
    if #vim.api.nvim_list_wins() == 1 and #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.notify("Cannot delete the last buffer", vim.log.levels.WARN)
        return
    end

    -- Check if this is a Claude terminal and ask for confirmation
    if is_claude_terminal(buf) then
        vim.ui.input({
            prompt = "Delete Claude terminal? (y/N): ",
            default = "N",
        }, function(input)
            if input and string.lower(input) == "y" then
                -- Try to switch to alternate buffer or previous buffer before deleting
                if #wins > 0 then
                    for _, win in ipairs(wins) do
                        vim.api.nvim_set_current_win(win)
                        vim.cmd("bprevious")
                    end
                end
                -- Force delete for terminals
                vim.api.nvim_buf_delete(buf, { force = true })
                vim.notify("Claude terminal deleted", vim.log.levels.INFO)
            else
                vim.notify("Delete cancelled", vim.log.levels.INFO)
            end
        end)
        return
    end

    -- For non-Claude terminals and regular buffers, delete without confirmation
    local is_terminal = vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"
    
    -- Try to switch to alternate buffer or previous buffer before deleting
    if #wins > 0 then
        for _, win in ipairs(wins) do
            vim.api.nvim_set_current_win(win)
            vim.cmd("bprevious")
        end
    end

    -- Use force for terminals, normal delete for regular buffers
    vim.api.nvim_buf_delete(buf, { force = is_terminal })
    vim.notify("Buffer deleted", vim.log.levels.INFO)
end, { desc = "Delete current buffer" })

-- Move to beginning of text objects (like vi but just moves cursor)
-- This uses a custom function to properly handle text object movements

-- Function to move cursor to beginning of text object
local function move_to_text_object_start(inside, text_obj)
    return function()
        -- Save current position
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Use visual mode to select the text object, then jump to start
        if inside then
            vim.cmd("normal! vi" .. text_obj .. "\x1b`<")
        else
            vim.cmd("normal! va" .. text_obj .. "\x1b`<")
        end
        
        -- If cursor didn't move (text object not found), restore position
        local new_pos = vim.api.nvim_win_get_cursor(0)
        if new_pos[1] == cur_pos[1] and new_pos[2] == cur_pos[2] then
            vim.api.nvim_win_set_cursor(0, cur_pos)
        end
    end
end

-- Define text objects to map
local text_objects = {
    ["b"] = "b", -- brackets/parentheses ()
    ["B"] = "B", -- curly braces {}
    ["]"] = "]", -- square brackets []
    [">"] = ">", -- angle brackets <>
    ["'"] = "'", -- single quotes
    ['"'] = '"', -- double quotes
    ["`"] = "`", -- backticks
    ["t"] = "t", -- tags (HTML/XML)
    ["w"] = "w", -- word
    ["W"] = "W", -- WORD
    ["s"] = "s", -- sentence
    ["p"] = "p", -- paragraph
    ["q"] = '"', -- quotes shortcut
    ["i"] = "i", -- general inside (for things like gii)
}

-- Create keymaps for all text objects using 'gt' prefix (go to beginning)
for key, obj in pairs(text_objects) do
    vim.keymap.set("n", "gti" .. key, move_to_text_object_start(true, obj), 
        { desc = "Move to beginning inside " .. key, silent = true })
    vim.keymap.set("n", "gta" .. key, move_to_text_object_start(false, obj), 
        { desc = "Move to beginning around " .. key, silent = true })
end

-- Go specific keymaps
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        -- Go specific mappings
        vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", { buffer = true, desc = "Go Test" })
        vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<cr>", { buffer = true, desc = "Go Test Function" })
        vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", { buffer = true, desc = "Go Coverage" })
        vim.keymap.set("n", "<leader>gl", "<cmd>GoLint<cr>", { buffer = true, desc = "Go Lint" })
        vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<cr>", { buffer = true, desc = "Go Imports" })
        vim.keymap.set("n", "<leader>gv", "<cmd>GoVet<cr>", { buffer = true, desc = "Go Vet" })
    end,
})
