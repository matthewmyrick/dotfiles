-- Language-specific plugins
return {
  -- Go
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- Rust
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      return {
        server = {
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },

  -- YAML schemas
  {
    "b0o/schemastore.nvim",
    lazy = true,
    version = false,
  },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      code = {
        enabled = true,
        sign = false,
        style = "normal",
        position = "left",
        disable_background = true,
      },
    },
  },

}
