return {
  -- Basic Go treesitter support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
      end
    end,
  },

  -- Essential tools via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "gopls",      -- Go Language Server
        "goimports",  -- Import management
        "gofumpt",    -- Code formatting
      })
    end,
  },

  -- Simple LSP configuration - just gopls with autocomplete
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- Essential settings for autocomplete
              usePlaceholders = true,
              completeUnimported = true,
              completeFunctionCalls = true,
              -- Search settings
              matcher = "Fuzzy",
              symbolMatcher = "fuzzy",
              -- Basic completion
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
      },
    },
  },

  -- Simple formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },
}