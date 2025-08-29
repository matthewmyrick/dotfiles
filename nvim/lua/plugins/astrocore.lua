-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure autocommands for terminal buffers and startup
    autocmds = {
      terminal_settings = {
        {
          event = "TermOpen",
          desc = "Configure terminal buffer settings",
          callback = function()
            -- Make terminal buffers unlisted to avoid showing in buffer pickers
            vim.bo.buflisted = false
            -- Set local options for terminal buffers
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            -- Start in insert mode
            vim.cmd("startinsert")
          end,
        },
        {
          event = "TermClose",
          desc = "Close terminal buffer window on exit",
          callback = function()
            -- Close the window when terminal process exits with success
            if vim.v.event.status == 0 then
              vim.api.nvim_input("<CR>")
            end
          end,
        },
      },
      readme_opener = {
        {
          event = "VimEnter",
          desc = "Handle startup with README or dashboard",
          callback = function()
            -- Delay to let AstroNvim's initial setup complete
            vim.defer_fn(function()
              -- Check if Neovim was opened with a directory argument
              local args = vim.fn.argv()
              local is_directory = #args == 1 and vim.fn.isdirectory(args[1]) == 1
              
              if is_directory then
                -- Get the directory path
                local dir = vim.fn.expand(args[1])
                
                -- List of possible README filenames
                local readme_files = {
                  "README.md",
                  "readme.md",
                  "README.MD",
                  "README",
                  "readme",
                  "README.txt",
                  "readme.txt",
                  "README.rst",
                  "readme.rst",
                }
                
                -- Find the first README that exists
                local readme_path = nil
                for _, readme_name in ipairs(readme_files) do
                  local full_path = dir .. "/" .. readme_name
                  if vim.fn.filereadable(full_path) == 1 then
                    readme_path = full_path
                    break
                  end
                end
                
                if readme_path then
                  -- README exists - first open README in main window
                  vim.cmd("edit " .. vim.fn.fnameescape(readme_path))
                  
                  -- Then open Neo-tree on the left without changing layout
                  vim.defer_fn(function()
                    vim.cmd("Neotree filesystem show left")
                    -- Make sure focus returns to README
                    vim.cmd("wincmd l")
                  end, 50)
                else
                  -- No README - show dashboard with Neo-tree
                  -- Close any existing Neo-tree first
                  vim.cmd("Neotree close")
                  
                  -- Open dashboard
                  if vim.fn.exists(":Snacks") == 2 then
                    vim.cmd("Snacks dashboard")
                  elseif vim.fn.exists(":Dashboard") == 2 then
                    vim.cmd("Dashboard")
                  else
                    vim.cmd("enew") -- Create empty buffer if no dashboard
                  end
                  
                  -- Open Neo-tree on the left
                  vim.defer_fn(function()
                    vim.cmd("Neotree filesystem reveal left")
                    -- Focus back on the dashboard/main window
                    vim.cmd("wincmd l")
                  end, 50)
                end
              end
            end, 150)
          end,
        },
      },
    },
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        title = false, -- prevent Neovim from overriding terminal title
        titlestring = "", -- empty title string
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>g"] = { desc = "Git" },
        ["<Leader>ga"] = { desc = "GitHub Actions" },
        ["<Leader>d"] = { desc = "Docker" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
        
        -- Center search results
        ["n"] = { "nzzzv", desc = "Next search result centered" },
        ["N"] = { "Nzzzv", desc = "Previous search result centered" },
        
        -- Terminal keybindings with proper buffer handling
        ["<Leader>tc"] = { 
          function()
            -- Create a persistent Claude CLI session
            local claude_buf_name = "claude-cli"
            local existing_buf = nil
            
            -- Check if Claude buffer already exists
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) then
                local name = vim.api.nvim_buf_get_name(buf)
                if name:match(claude_buf_name) then
                  existing_buf = buf
                  break
                end
              end
            end
            
            -- Check if Claude is already visible in a window
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if buf == existing_buf then
                -- Claude is already visible, just focus it
                vim.api.nvim_set_current_win(win)
                vim.cmd("startinsert")
                return
              end
            end
            
            -- Open Claude in a vertical split
            vim.cmd("vsplit")
            
            if existing_buf then
              -- Reuse existing Claude buffer
              vim.api.nvim_set_current_buf(existing_buf)
              vim.cmd("startinsert")
            else
              -- Create new Claude terminal
              vim.cmd("terminal claude")
              vim.api.nvim_buf_set_name(0, claude_buf_name)
              -- Set buffer as unlisted to avoid showing in buffer pickers
              vim.bo.buflisted = false
              -- Make buffer persist when hidden
              vim.bo.bufhidden = "hide"
              vim.cmd("startinsert")
            end
          end,
          desc = "Toggle Claude CLI (persistent session)" 
        },
        ["<Leader>tC"] = {
          function()
            -- Kill Claude CLI session completely
            local claude_buf_name = "claude-cli"
            
            -- Find and delete Claude buffer
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) then
                local name = vim.api.nvim_buf_get_name(buf)
                if name:match(claude_buf_name) then
                  -- Close any windows showing this buffer first
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                      vim.api.nvim_win_close(win, true)
                    end
                  end
                  -- Force delete the buffer
                  vim.api.nvim_buf_delete(buf, { force = true })
                  vim.notify("Claude CLI session terminated", vim.log.levels.INFO)
                  return
                end
              end
            end
            vim.notify("No Claude CLI session found", vim.log.levels.WARN)
          end,
          desc = "Kill Claude CLI session"
        },
        ["<Leader>tt"] = { 
          function()
            -- Open terminal in new tab
            vim.cmd("tabnew")
            vim.cmd("terminal")
            vim.cmd("startinsert")
            -- Set buffer as unlisted to avoid showing in buffer pickers
            vim.bo.buflisted = false
          end,
          desc = "Open terminal in new tab" 
        },
        
        -- Neo-tree source navigation
        ["<Leader>e"] = { "<Cmd>Neotree focus filesystem left<CR>", desc = "Focus Neo-tree filesystem" },
        ["<Leader>be"] = { "<Cmd>Neotree focus buffers left<CR>", desc = "Focus Neo-tree buffers" },
        ["<Leader>ge"] = { "<Cmd>Neotree focus git_status left<CR>", desc = "Focus Neo-tree git status" },
        
        -- Quick source switching (when Neo-tree is already open)
        ["<Leader>1"] = { "<Cmd>Neotree source=filesystem<CR>", desc = "Neo-tree Files" },
        ["<Leader>2"] = { "<Cmd>Neotree source=buffers<CR>", desc = "Neo-tree Buffers" },
        ["<Leader>3"] = { "<Cmd>Neotree source=git_status<CR>", desc = "Neo-tree Git" },
        
        -- LazyDocker keybindings
        ["<Leader>dd"] = { "<Cmd>LazyDocker<CR>", desc = "Open LazyDocker" },
        ["<Leader>dl"] = { "<Cmd>LazyDockerLogs<CR>", desc = "LazyDocker Logs" },
        ["<Leader>dc"] = { "<Cmd>LazyDockerConfig<CR>", desc = "LazyDocker Config" },
      },
      t = {
        -- Terminal mode mappings
        ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
      },
      -- Operator pending mode for text objects
      o = {
        ["ag"] = { "<Cmd>normal! ggVG<CR>", desc = "Select entire file" },
      },
      -- Visual mode for text objects
      x = {
        ["ag"] = { "gg0oG$", desc = "Select entire file" },
      },
    },
  },
}
