return {
    -- {
    --     "dasupradyumna/midnight.nvim", -- black theme
    --     lazy = false,
    --     priority = 1000,
    -- },
    -- {
    --     "LazyVim/LazyVim",
    --     opts = {
    --         colorscheme = "midnight",
    --     },
    -- },

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
