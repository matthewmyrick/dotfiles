-- Python command system with interpreter selection
return {
  "neovim/nvim-lspconfig",
  
  init = function()
    -- Function to get Python path from venv
    local function get_python_path(venv_info)
      if not venv_info or not venv_info.path then
        return "python"
      end
      return venv_info.path .. "/bin/python"
    end

    -- Function to switch Python interpreter for LSP
    local function switch_python_interpreter()
      local python_utils = require("plugins.toggleterm.python-utils")
      local venv_list = python_utils.find_all_venvs()
      
      python_utils.select_venv_with_telescope(venv_list, function(selected_venv)
        local python_path = get_python_path(selected_venv)
        
        -- Update the LSP settings
        local clients = vim.lsp.get_clients({ name = "basedpyright" })
        if #clients > 0 then
          for _, client in ipairs(clients) do
            -- Update client settings
            client.config.settings = client.config.settings or {}
            client.config.settings.basedpyright = client.config.settings.basedpyright or {}
            client.config.settings.basedpyright.pythonPath = python_path
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          
          if selected_venv then
            vim.notify("Switched Python interpreter to: " .. selected_venv.relative_path .. "\nPath: " .. python_path, vim.log.levels.INFO)
          else
            vim.notify("Switched to system Python interpreter", vim.log.levels.INFO)
          end
        else
          vim.notify("No basedpyright LSP client found. Make sure you're in a Python file.", vim.log.levels.WARN)
        end
      end)
    end

    -- Function to show comprehensive help
    local function show_python_help()
      local help_text = [[
╭─────────────────────────────────────────────────────────────────────────────╮
│                           🐍 PYTHON COMMANDS                                │
╰─────────────────────────────────────────────────────────────────────────────╯

py i        - Select Python interpreter (fuzzy finder)
py help     - Show this comprehensive help

╭─────────────────────────────────────────────────────────────────────────────╮
│                         🛠️  CUSTOM COMMANDS REFERENCE                       │
╰─────────────────────────────────────────────────────────────────────────────╯

🖥️  TERMINAL COMMANDS
─────────────────────────────────────────────────────────────────────────────
Buffer Terminals:
  <leader>tt   - Enhanced terminal buffer (auto-numbered)
  <leader>td   - Terminal in current file's directory
  <leader>tc   - Claude terminal (vertical split, single instance)
  <leader>tg   - Gemini terminal (vertical split)
  <leader>tk   - Kubernetes (k9s) terminal
  <leader>ty   - Yazi file manager terminal
  <leader>tb   - Bluetooth TUI terminal
  <leader>ta   - Azure Searcher terminal
  <leader>tr   - Rename current terminal buffer

Floating Terminals:
  <leader>tff  - General floating terminal
  <leader>tfg  - Gemini floating terminal
  <leader>tfk  - Kubernetes floating terminal
  <leader>tfy  - Yazi floating terminal
  <leader>tfc  - Claude floating terminal
  <leader>tfb  - Bluetooth floating terminal
  <leader>tfq  - Quill floating terminal
  <leader>tfa  - Azure Searcher floating terminal
  <leader>tfj  - JQP JSON viewer (with file picker)

Horizontal/Vertical Terminals:
  <leader>tht  - 33% horizontal terminal
  <leader>thh  - 50% horizontal terminal  
  <leader>tvt  - 33% vertical terminal
  <leader>tvh  - 50% vertical terminal

🔍 NAVIGATION & SEARCH
─────────────────────────────────────────────────────────────────────────────
  <C-h>        - Cycle through all windows
  <C-l>        - Go right or wrap to first window
  <leader>e    - Open/Focus File Explorer
  <leader>ww   - Save file
  <leader>sg   - Grep (current window)
  <leader>sG   - Grep string under cursor (current window)

🗂️  FILE MANAGEMENT  
─────────────────────────────────────────────────────────────────────────────
  0            - Go to first non-blank character (swapped with ^)
  ^            - Go to beginning of line (swapped with 0)
  dd           - Delete line without copying to clipboard
  d (visual)   - Delete selection without copying

🏥 DIAGNOSTICS
─────────────────────────────────────────────────────────────────────────────
  <leader>d    - Open diagnostic float
  [d           - Go to previous diagnostic
  ]d           - Go to next diagnostic
  <leader>q    - Open diagnostics list

💡 USAGE TIPS
─────────────────────────────────────────────────────────────────────────────
• Terminal naming: Creates "terminal", "terminal 2", "terminal 3", etc.
• Claude terminal: Only one instance allowed, focuses existing if present
• Python venv: Auto-detected when opening .py files (if only one found)
• All floating terminals use rounded borders and proper centering

Press 'q' or <Esc> to close this help
]]
      
      -- Create a floating window to display help
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(help_text, '\n'))
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
      vim.api.nvim_buf_set_option(buf, 'filetype', 'help')
      
      -- Calculate window size (larger for comprehensive help)
      local width = math.min(85, math.floor(vim.o.columns * 0.9))
      local height = math.min(45, math.floor(vim.o.lines * 0.9))
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)
      
      local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' 🛠️  Custom Commands Reference ',
        title_pos = 'center',
      }
      
      local win = vim.api.nvim_open_win(buf, true, opts)
      
      -- Set window highlights with better colors
      vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Normal,FloatBorder:FloatBorder,Title:Title')
      
      -- Close on escape or q
      vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, silent = true })
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
      
      -- Enable scrolling
      vim.keymap.set('n', 'j', 'j', { buffer = buf, silent = true })
      vim.keymap.set('n', 'k', 'k', { buffer = buf, silent = true })
      vim.keymap.set('n', '<C-d>', '<C-d>', { buffer = buf, silent = true })
      vim.keymap.set('n', '<C-u>', '<C-u>', { buffer = buf, silent = true })
    end

    -- Main Python command handler
    local function python_command_handler(args)
      local cmd = args.args:lower():gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
      
      if cmd == "i" then
        switch_python_interpreter()
      elseif cmd == "help" then
        show_python_help()
      else
        vim.notify("Unknown Python command: '" .. cmd .. "'. Use 'py help' to see available commands.", vim.log.levels.WARN)
      end
    end

    -- Create the main py command
    vim.api.nvim_create_user_command("Py", python_command_handler, {
      nargs = 1,
      desc = "Python command system",
      complete = function(ArgLead, CmdLine, CursorPos)
        -- Auto-complete for py commands
        local commands = {"i", "help"}
        local matches = {}
        for _, cmd in ipairs(commands) do
          if cmd:sub(1, #ArgLead) == ArgLead then
            table.insert(matches, cmd)
          end
        end
        return matches
      end
    })

    -- Auto-detect and set Python interpreter when opening Python files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function()
        -- Only auto-detect if we haven't already set a custom interpreter
        local clients = vim.lsp.get_clients({ name = "basedpyright" })
        if #clients > 0 then
          local client = clients[1]
          local current_python = client.config.settings and 
                                client.config.settings.basedpyright and 
                                client.config.settings.basedpyright.pythonPath
          
          -- If using default python, try to auto-detect venv
          if not current_python or current_python == "python" then
            local python_utils = require("plugins.toggleterm.python-utils")
            local venv_list = python_utils.find_all_venvs()
            
            -- If only one venv found, use it automatically
            if #venv_list == 1 then
              local python_path = get_python_path(venv_list[1])
              client.config.settings = client.config.settings or {}
              client.config.settings.basedpyright = client.config.settings.basedpyright or {}
              client.config.settings.basedpyright.pythonPath = python_path
              client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
              vim.notify("Auto-detected Python venv: " .. venv_list[1].relative_path, vim.log.levels.INFO)
            end
          end
        end
      end,
    })
  end,
  
  opts = function(_, opts)
    -- Ensure Python LSP settings exist for initial configuration
    opts.servers = opts.servers or {}
    opts.servers.basedpyright = opts.servers.basedpyright or {}
    opts.servers.basedpyright.settings = opts.servers.basedpyright.settings or {}
    opts.servers.basedpyright.settings.basedpyright = opts.servers.basedpyright.settings.basedpyright or {}
    return opts
  end,
}