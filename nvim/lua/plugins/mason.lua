-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- Language servers
        "lua-language-server",
        "pyright",                  -- Python LSP
        "gopls",                    -- Go LSP
        "rust-analyzer",            -- Rust LSP
        "terraform-ls",             -- Terraform LSP
        "json-lsp",                 -- JSON LSP
        "yaml-language-server",     -- YAML LSP
        "typescript-language-server", -- JavaScript/TypeScript LSP

        -- Formatters
        "stylua",
        "black",                    -- Python formatter
        "gofumpt",                  -- Go formatter
        "rustfmt",                  -- Rust formatter (usually comes with rust-analyzer)
        "prettier",                 -- JavaScript/TypeScript/JSON/YAML formatter

        -- Linters
        "ruff",                     -- Python linter
        "golangci-lint",            -- Go linter
        "tflint",                   -- Terraform linter
        "yamllint",                 -- YAML linter
        "eslint_d",                 -- JavaScript/TypeScript linter

        -- Debuggers
        "debugpy",                  -- Python debugger
        "delve",                    -- Go debugger

        -- Other tools
        "tree-sitter-cli",
      },
    },
  },
}
