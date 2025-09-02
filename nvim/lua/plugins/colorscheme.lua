return {
    -- GitHub Dark Theme (commented out)
    -- {
    --     "projekt0n/github-nvim-theme",
    --     name = "github-theme",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         require('github-theme').setup({
    --             options = {
    --                 compile_path = vim.fn.stdpath('cache') .. '/github-theme',
    --                 compile_file_suffix = '_compiled',
    --                 hide_end_of_buffer = true,
    --                 hide_nc_statusline = true,
    --                 transparent = false,
    --                 terminal_colors = true,
    --                 dim_inactive = false,
    --                 module_default = true,
    --                 styles = {
    --                     comments = 'italic',
    --                     functions = 'NONE',
    --                     keywords = 'NONE',
    --                     variables = 'NONE',
    --                     conditionals = 'NONE',
    --                     constants = 'NONE',
    --                     numbers = 'NONE',
    --                     operators = 'NONE',
    --                     strings = 'NONE',
    --                     types = 'NONE',
    --                 },
    --                 inverse = {
    --                     match_paren = false,
    --                     visual = false,
    --                     search = false,
    --                 },
    --             },
    --             groups = {
    --                 all = {
    --                     -- File explorer folder colors
    --                     NeoTreeDirectoryIcon = { fg = '#58a6ff' },  -- Blue folder icon
    --                     NeoTreeDirectoryName = { fg = '#58a6ff' },  -- Blue folder name
    --                     NeoTreeRootName = { fg = '#58a6ff', bold = true },  -- Blue root folder
    --                     
    --                     -- Snacks dashboard folder colors
    --                     SnacksExplorerDirectory = { fg = '#58a6ff' },
    --                     SnacksExplorerDirectoryIcon = { fg = '#58a6ff' },
    --                     
    --                     -- General directory highlights
    --                     Directory = { fg = '#58a6ff' },
    --                 },
    --             },
    --         })
    --         
    --         -- Additional overrides after theme loads
    --         vim.api.nvim_create_autocmd("ColorScheme", {
    --             pattern = "github_*",
    --             callback = function()
    --                 -- Override folder colors for various file explorers
    --                 vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#58a6ff" })
    --                 vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#58a6ff" })
    --                 vim.api.nvim_set_hl(0, "Directory", { fg = "#58a6ff" })
    --                 
    --                 -- Snacks specific overrides
    --                 vim.api.nvim_set_hl(0, "SnacksExplorerDirectory", { fg = "#58a6ff" })
    --                 vim.api.nvim_set_hl(0, "SnacksExplorerDirectoryIcon", { fg = "#58a6ff" })
    --             end,
    --         })
    --     end,
    -- },
    -- {
    --     "LazyVim/LazyVim",
    --     opts = {
    --         colorscheme = "github_dark",
    --     },
    -- },

    -- Catppuccin Theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            integrations = {
                bufferline = true,
                cmp = true,
                gitsigns = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                lsp_trouble = true,
                mason = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                },
                navic = { enabled = true, custom_bg = "lualine" },
                snacks = true,
                noice = true,
                notify = true,
                semantic_tokens = true,
                telescope = true,
                treesitter = true,
                which_key = true,
            },
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
}
