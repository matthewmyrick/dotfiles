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

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
        
        -- Terminal keybindings
        ["<Leader>tc"] = { "<Cmd>vsplit | terminal claude<CR>", desc = "Open Claude CLI in vertical terminal" },
        ["<Leader>tb"] = { "<Cmd>terminal<CR>", desc = "Open terminal as buffer" },
        
        -- Neo-tree source navigation
        ["<Leader>e"] = { "<Cmd>Neotree focus filesystem left<CR>", desc = "Focus Neo-tree filesystem" },
        ["<Leader>be"] = { "<Cmd>Neotree focus buffers left<CR>", desc = "Focus Neo-tree buffers" },
        ["<Leader>ge"] = { "<Cmd>Neotree focus git_status left<CR>", desc = "Focus Neo-tree git status" },
        
        -- Quick source switching (when Neo-tree is already open)
        ["<Leader>1"] = { "<Cmd>Neotree source=filesystem<CR>", desc = "Neo-tree Files" },
        ["<Leader>2"] = { "<Cmd>Neotree source=buffers<CR>", desc = "Neo-tree Buffers" },
        ["<Leader>3"] = { "<Cmd>Neotree source=git_status<CR>", desc = "Neo-tree Git" },
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
