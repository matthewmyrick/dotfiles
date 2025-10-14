return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            code = {
                -- Disable background highlighting for code blocks
                style = 'none',
                -- Or if you want to keep some styling but remove background:
                highlight = '',
                -- Disable inline code background
                inline_highlight = '',
            },
        },
    },
}