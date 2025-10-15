-- Python Virtual Environment Picker with Telescope
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function(_, opts)
    local telescope = require("telescope")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- Function to get Python version from interpreter
    local function get_python_version(python_path)
      local handle = io.popen(python_path .. ' --version 2>&1')
      if handle then
        local result = handle:read("*a")
        handle:close()
        return result:match("Python ([%d%.]+)") or "Unknown"
      end
      return "Unknown"
    end

    -- Function to find all Python interpreters
    local function find_python_interpreters()
      local interpreters = {}
      
      -- Common virtual environment locations
      local venv_patterns = {
        vim.fn.expand("~/.virtualenvs/*/bin/python*"),
        vim.fn.expand("~/.pyenv/versions/*/bin/python*"),
        vim.fn.expand("~/venv/*/bin/python*"),
        vim.fn.expand("~/.venv/bin/python*"),
        vim.fn.expand("./venv/bin/python*"),
        vim.fn.expand("./.venv/bin/python*"),
        vim.fn.expand("**/venv/bin/python*"),
        vim.fn.expand("**/.venv/bin/python*"),
      }
      
      -- Homebrew Python installations
      local homebrew_pattern = "/opt/homebrew/Cellar/python@*/*/bin/python*"
      table.insert(venv_patterns, homebrew_pattern)
      
      -- System Python
      local system_pythons = {
        "/usr/bin/python3",
        "/usr/bin/python",
        "/usr/local/bin/python3",
        "/usr/local/bin/python",
      }
      
      -- Find virtual environment Pythons
      for _, pattern in ipairs(venv_patterns) do
        local matches = vim.fn.glob(pattern, false, true)
        for _, path in ipairs(matches) do
          if vim.fn.executable(path) == 1 then
            local version = get_python_version(path)
            local env_name = path:match("/([^/]+)/bin/python") or "system"
            table.insert(interpreters, {
              path = path,
              version = version,
              env_name = env_name,
              display = string.format("%s (Python %s) - %s", env_name, version, path),
            })
          end
        end
      end
      
      -- Add system Pythons
      for _, path in ipairs(system_pythons) do
        if vim.fn.executable(path) == 1 then
          local version = get_python_version(path)
          table.insert(interpreters, {
            path = path,
            version = version,
            env_name = "system",
            display = string.format("system (Python %s) - %s", version, path),
          })
        end
      end
      
      -- Remove duplicates and sort
      local seen = {}
      local unique_interpreters = {}
      for _, interp in ipairs(interpreters) do
        if not seen[interp.path] then
          seen[interp.path] = true
          table.insert(unique_interpreters, interp)
        end
      end
      
      table.sort(unique_interpreters, function(a, b)
        return a.env_name < b.env_name
      end)
      
      return unique_interpreters
    end

    -- Function to set Python interpreter for LSP
    local function set_python_interpreter(python_path)
      -- Update Pyright settings
      local clients = vim.lsp.get_clients({ name = "pyright" })
      for _, client in ipairs(clients) do
        if client.config.settings then
          client.config.settings.python = client.config.settings.python or {}
          client.config.settings.python.pythonPath = python_path
          client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
      end
      
      -- Update global LSP config for future clients
      if vim.lsp.config and vim.lsp.config.pyright then
        vim.lsp.config.pyright.settings = vim.lsp.config.pyright.settings or {}
        vim.lsp.config.pyright.settings.python = vim.lsp.config.pyright.settings.python or {}
        vim.lsp.config.pyright.settings.python.pythonPath = python_path
      end
      
      vim.notify("Python interpreter set to: " .. python_path, vim.log.levels.INFO)
    end

    -- Telescope picker for Python interpreters
    local function python_interpreter_picker(opts)
      opts = opts or {}
      local interpreters = find_python_interpreters()
      
      if #interpreters == 0 then
        vim.notify("No Python interpreters found", vim.log.levels.WARN)
        return
      end
      
      pickers.new(opts, {
        prompt_title = "Select Python Interpreter",
        finder = finders.new_table({
          results = interpreters,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.display,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              set_python_interpreter(selection.value.path)
            end
          end)
          return true
        end,
      }):find()
    end

    -- Register the picker as a Telescope extension
    telescope.register_extension({
      exports = {
        python_interpreter = python_interpreter_picker,
      },
    })

    -- Add keybinding
    vim.keymap.set("n", "<leader>lpp", function()
      python_interpreter_picker()
    end, { desc = "Pick Python Interpreter" })

    return opts
  end,
}