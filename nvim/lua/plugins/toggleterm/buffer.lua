-- Buffer terminal configurations
local M = {}

-- Helper function to set terminal buffer name with icon
local function set_terminal_name(name)
    -- If name is empty, use default "terminal"
    if name == "" or name == nil then
        name = "terminal"
    end
    -- Add the $ icon prefix
    local full_name = "$ " .. name
    vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

-- Helper function to check if a terminal should open in vertical split
local function should_open_in_vertical(name)
    -- List of terminals that should open in vertical split
    local vertical_terminals = {
        "claude",
        "gemini",
        "chatgpt",
    }
    
    -- Check if the name matches any of the vertical terminals
    local lower_name = string.lower(name or "")
    for _, term in ipairs(vertical_terminals) do
        if string.find(lower_name, term) then
            return true
        end
    end
    return false
end

-- Helper function to open terminal with appropriate split
local function open_terminal_with_split(cmd, name)
    if should_open_in_vertical(name) then
        -- Open in vertical split
        vim.cmd("vsplit")
        vim.cmd("wincmd l") -- Move to the new split
        vim.cmd("terminal " .. cmd)
    else
        -- Open normally in current buffer
        vim.cmd("enew")
        vim.cmd("terminal " .. cmd)
    end
    
    vim.schedule(function()
        set_terminal_name(name)
    end)
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
    
    -- Claude Vertical Split Terminal
    vim.api.nvim_create_user_command("ClaudeVerticalTerm", function()
        -- Open a vertical split (50% width)
        vim.cmd("vsplit")
        vim.cmd("wincmd l") -- Move to the new split
        
        -- Get the current Node version from NVM
        local nvm_dir = vim.fn.expand("$HOME/.nvm")
        local node_version = vim.fn.system("source " .. nvm_dir .. "/nvm.sh && nvm current"):gsub("%s+", "")
        local claude_path = nvm_dir .. "/versions/node/" .. node_version .. "/bin/claude"
        
        -- Check if claude exists at this path
        if vim.fn.filereadable(claude_path) == 1 then
            vim.cmd("terminal " .. claude_path)
        else
            -- Fallback to trying claude directly
            vim.cmd("terminal claude")
        end
        
        vim.schedule(function()
            set_terminal_name("claude")
        end)
    end, { nargs = 0, desc = "Open Claude in Vertical Split" })

    -- Gemini Vertical Split Terminal
    vim.api.nvim_create_user_command("GeminiBufferTerm", function()
        open_terminal_with_split("gemini", "gemini")
    end, { nargs = 0, desc = "Open Gemini in Vertical Split" })



    -- Kubernetes (k9s) Buffer Terminal
    vim.api.nvim_create_user_command("KubernetesBufferTerm", function()
        vim.cmd("terminal k9s")
        vim.schedule(function()
            set_terminal_name("k9s")
        end)
    end, { nargs = 0, desc = "Open Kubernetes (k9s) in Current Buffer" })

    -- Yazi Buffer Terminal
    vim.api.nvim_create_user_command("YaziBufferTerm", function()
        vim.cmd("terminal yazi")
        vim.schedule(function()
            set_terminal_name("yazi")
        end)
    end, { nargs = 0, desc = "Open Yazi in Current Buffer" })

    -- Bluetooth Buffer Terminal
    vim.api.nvim_create_user_command("BluetoothBufferTerm", function()
        vim.cmd("terminal bluetooth-tui")
        vim.schedule(function()
            set_terminal_name("bluetooth-tui")
        end)
    end, { nargs = 0, desc = "Open Bluetooth TUI in Current Buffer" })

    -- Azure Searcher Buffer Terminal
    vim.api.nvim_create_user_command("AzureSearcherBufferTerm", function()
        vim.cmd("terminal azure-searcher")
        vim.schedule(function()
            set_terminal_name("azure-searcher")
        end)
    end, { nargs = 0, desc = "Open Azure Searcher in Current Buffer" })

    -- Enhanced Buffer Terminal (replaces BufferTerm for <leader>tt)
    vim.api.nvim_create_user_command("EnhancedBufferTerm", function()
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
        
        -- Open terminal and change to the file's directory
        open_terminal_with_split(vim.o.shell, name)
        
        -- Change directory after the terminal opens
        vim.schedule(function()
            if vim.b.terminal_job_id then
                vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(file_dir) .. "\r")
            end
        end)
    end, { nargs = 0, desc = "Open Terminal in current file's directory" })

    -- General Buffer Terminal with Python venv detection
    vim.api.nvim_create_user_command("BufferTerm", function()
        -- Prompt for terminal name first
        local name = vim.fn.input("Terminal name (empty for default): ")
        
        -- Check if this is a Python-related terminal
        local python_utils = require("plugins.toggleterm.python-utils")
        local is_python = python_utils.is_python_name(name)
        
        if is_python then
            -- Look for virtual environments using enhanced detection
            local venv_list = python_utils.find_all_venvs()
            
            python_utils.select_venv_with_telescope(venv_list, function(selected_venv)
                local terminal_cmd
                if selected_venv then
                    terminal_cmd = python_utils.create_python_terminal_cmd(selected_venv)
                else
                    terminal_cmd = vim.o.shell
                end
                
                -- Create terminal with custom command
                vim.cmd("terminal " .. terminal_cmd)
                vim.schedule(function()
                    set_terminal_name(name)
                end)
            end)
        else
            -- Not a Python terminal, proceed normally
            vim.cmd("terminal")
            vim.schedule(function()
                set_terminal_name(name)
            end)
        end
    end, { nargs = 0, desc = "Open Terminal in Current Buffer" })
    
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
        { "<leader>tc", "<cmd>ClaudeVerticalTerm<CR>", desc = "Claude (vertical split)" },
        { "<leader>tg", "<cmd>GeminiBufferTerm<CR>", desc = "Gemini (vertical split)" },
        { "<leader>tk", "<cmd>KubernetesBufferTerm<CR>", desc = "Open Kubernetes in Current Buffer" },
        { "<leader>ty", "<cmd>YaziBufferTerm<CR>", desc = "Open Yazi in Current Buffer" },
        { "<leader>tb", "<cmd>BluetoothBufferTerm<CR>", desc = "Open Bluetooth in Current Buffer" },
        { "<leader>ta", "<cmd>AzureSearcherBufferTerm<CR>", desc = "Open Azure Searcher in Current Buffer" },
        { "<leader>tr", "<cmd>TerminalRename<CR>", desc = "Rename Terminal Buffer" },
    }
end

return M