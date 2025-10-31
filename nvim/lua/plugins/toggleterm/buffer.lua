-- Buffer terminal configurations
local M = {}

-- Helper function to set terminal buffer name with icon
local function set_terminal_name(name)
    -- If name is empty, use default "terminal"
    if name == "" or name == nil then
        name = "terminal"
    end

    -- Check if a buffer with this name already exists and auto-number if needed
    local base_name = name
    local counter = 1
    local full_name = "$ " .. name

    -- Get list of all buffer names
    local existing_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name ~= "" then
                -- Extract just the filename part
                local filename = vim.fn.fnamemodify(buf_name, ":t")
                existing_buffers[filename] = true
            end
        end
    end

    -- If the name already exists, try numbered variations
    while existing_buffers[full_name] do
        counter = counter + 1
        full_name = "$ " .. base_name .. " " .. counter
    end

    vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

-- Helper function to setup terminal buffer autocmds
local function setup_terminal_autocmds()
    local augroup = vim.api.nvim_create_augroup("BufferTerminalNaming", { clear = true })

    -- Auto-name terminal buffers when they are created
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        pattern = "*",
        callback = function()
            -- Only apply to buffer terminals (not splits or floats)
            local win_config = vim.api.nvim_win_get_config(0)
            if not win_config.relative or win_config.relative == "" then
                -- Check if it's not a split by looking at window dimensions
                local win_height = vim.api.nvim_win_get_height(0)
                local win_width = vim.api.nvim_win_get_width(0)
                local total_height = vim.o.lines
                local total_width = vim.o.columns

                -- If the terminal takes up most of the screen, it's likely a buffer terminal
                if win_height >= total_height - 5 and win_width >= total_width - 5 then
                    -- Set default name
                    vim.schedule(function()
                        set_terminal_name("terminal")
                    end)
                end
            end
        end,
    })
end

function M.setup()
    -- Setup autocmds for terminal naming
    setup_terminal_autocmds()

    -- Helper function to create Claude terminal
    local function create_claude_terminal(use_continue, is_half_split)
        -- Get the current Node version from NVM
        local nvm_dir = vim.fn.expand("$HOME/.nvm")
        local node_version = vim.fn.system("source " .. nvm_dir .. "/nvm.sh && nvm current"):gsub("%s+", "")
        local claude_path = nvm_dir .. "/versions/node/" .. node_version .. "/bin/claude"

        -- Determine command to run
        local claude_cmd
        if vim.fn.filereadable(claude_path) == 1 then
            claude_cmd = claude_path .. (use_continue and " --continue" or "")
        else
            claude_cmd = "claude" .. (use_continue and " --continue" or "")
        end

        -- Create the terminal
        vim.cmd("terminal " .. claude_cmd)

        -- Set terminal name
        vim.schedule(function()
            set_terminal_name("claude")
        end)

        -- If using --continue, monitor for "No conversation found" and restart without --continue
        if use_continue then
            vim.schedule(function()
                local buf = vim.api.nvim_get_current_buf()
                -- Set up an autocmd to monitor the terminal output
                vim.api.nvim_create_autocmd("TermClose", {
                    buffer = buf,
                    once = true,
                    callback = function()
                        -- Check if the terminal closed immediately (likely due to no conversation)
                        vim.schedule(function()
                            -- Check if buffer is still valid before reading
                            if not vim.api.nvim_buf_is_valid(buf) then
                                return
                            end
                            -- Read the terminal output to check for "No conversation found"
                            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                            for _, line in ipairs(lines) do
                                if line:match("No conversation found") then
                                    -- Restart Claude without --continue
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

    -- Helper function to find existing Claude buffer
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

    vim.api.nvim_create_user_command("ClaudeVerticalTerm", function()
        local claude_buf = find_claude_buffer()

        -- If Claude terminal exists, open it in a 33% vertical split
        if claude_buf then
            local claude_win = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == claude_buf then
                    claude_win = win
                    break
                end
            end

            if claude_win then
                -- Focus the existing Claude window
                vim.api.nvim_set_current_win(claude_win)
                vim.notify("Focused existing Claude terminal", vim.log.levels.INFO)
                return
            else
                -- Claude buffer exists but no window is showing it, open it in a 33% vertical split
                -- Get width BEFORE splitting
                local original_width = vim.api.nvim_win_get_width(0)
                vim.cmd("vsplit")
                vim.cmd("wincmd l")
                -- Resize to 33% of original window width
                local third_width = math.floor(original_width / 3)
                vim.cmd("vertical resize " .. third_width)
                vim.api.nvim_set_current_buf(claude_buf)
                vim.notify("Reopened existing Claude terminal", vim.log.levels.INFO)
                return
            end
        end

        -- No existing Claude terminal, create a new one in 33% vertical split
        -- Get width BEFORE splitting
        local original_width = vim.api.nvim_win_get_width(0)
        vim.cmd("vsplit")
        vim.cmd("wincmd l")
        -- Resize to 33% of original window width
        local third_width = math.floor(original_width / 3)
        vim.cmd("vertical resize " .. third_width)
        create_claude_terminal(true, false)
    end, { nargs = 0, desc = "Open Claude in 33% Vertical Split" })


    -- Enhanced Buffer Terminal (replaces BufferTerm for <leader>tt)
    vim.api.nvim_create_user_command("EnhancedBufferTerm", function()
        -- Create new buffer first to avoid "requires unmodified buffer" error
        vim.cmd("enew")
        -- Simple terminal buffer
        vim.cmd("terminal")
        vim.schedule(function()
            set_terminal_name("terminal")
        end)
    end, { nargs = 0, desc = "Open simple terminal buffer" })

    -- Terminal in current file's directory
    vim.api.nvim_create_user_command("TerminalInFileDir", function()
        -- Use default name "terminal" without prompting
        local name = "terminal"

        -- Get the directory of the current file
        local current_file = vim.fn.expand("%:p")
        local file_dir = vim.fn.fnamemodify(current_file, ":h")

        -- If the current buffer is not a file (e.g., empty buffer), use current working directory
        if current_file == "" or vim.bo.buftype ~= "" then
            file_dir = vim.fn.getcwd()
        end

        -- Open terminal in new buffer
        vim.cmd("enew")
        vim.cmd("terminal " .. vim.o.shell)

        vim.schedule(function()
            set_terminal_name(name)
            -- Change directory after the terminal opens
            if vim.b.terminal_job_id then
                vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(file_dir) .. "\r")
            end
        end)
    end, { nargs = 0, desc = "Open Terminal in current file's directory" })

    -- Terminal rename command
    vim.api.nvim_create_user_command("TerminalRename", function()
        -- Check if current buffer is a terminal
        if vim.bo.buftype ~= "terminal" then
            vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
            return
        end

        -- Get current name (remove the "$ " prefix if present)
        local current_name = vim.fn.expand("%:t")
        if current_name:sub(1, 2) == "$ " then
            current_name = current_name:sub(3)
        end

        -- Prompt for new name
        local new_name = vim.fn.input("New terminal name: ", current_name)

        -- Set the new name (empty input defaults to "terminal")
        set_terminal_name(new_name)
    end, { nargs = 0, desc = "Rename terminal buffer" })
end

-- Return keymaps for buffer terminals
function M.keymaps()
    return {
        { "<leader>tt", "<cmd>EnhancedBufferTerm<CR>", desc = "Terminal (simple buffer)" },
        { "<leader>td", "<cmd>TerminalInFileDir<CR>", desc = "Terminal in current file's directory" },
        { "<leader>tc", "<cmd>ClaudeVerticalTerm<CR>", desc = "Claude (33% vertical split)" },
        { "<leader>tr", "<cmd>TerminalRename<CR>", desc = "Rename Terminal Buffer" },
    }
end

return M
