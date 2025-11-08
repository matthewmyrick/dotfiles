-- LSP Configuration
return {
  -- Mason for LSP server management
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",

        -- Shell
        "shellcheck",   -- Shell script linter
        "shfmt",        -- Shell script formatter
        "shellharden",  -- Shell script hardener/linter
        "beautysh",     -- Shell script beautifier

        -- Go
        "gofumpt",      -- Go formatter (better than gofmt)
        "goimports",    -- Go imports organizer
        "golangci-lint", -- Go linter
        "gomodifytags", -- Go struct tag modifier
        "impl",         -- Go interface implementation generator

        -- Python
        "black",        -- Python formatter
        "isort",        -- Python import sorter
        "flake8",       -- Python linter
        "pylint",       -- Python linter
        "mypy",         -- Python type checker

        -- JavaScript/TypeScript
        "prettier",     -- JS/TS/JSON/YAML formatter
        "eslint_d",     -- JS/TS linter (faster)

        -- YAML
        "yamllint",     -- YAML linter
        "yamlfmt",      -- YAML formatter

        -- JSON
        "jsonlint",     -- JSON linter
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason LSPConfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "gopls",
        "pyright",
        "ts_ls",
        "rust_analyzer",
        "yamlls",
        "jsonls",
        "helm_ls",
      },
      automatic_installation = true,
    },
  },

  -- LSPConfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- Setup diagnostics
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Diagnostic signs (handled by mini.nvim)
      -- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      -- for type, icon in pairs(signs) do
      --   local hl = "DiagnosticSign" .. type
      --   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      -- end

      -- LSP keymaps (on attach)
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "gi", function()
          if Snacks and Snacks.picker then
            Snacks.picker.lsp_references()
          else
            vim.lsp.buf.references()
          end
        end, vim.tbl_extend("force", opts, { desc = "Show references" }))
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
        vim.keymap.set("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Type definition" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format" }))
      end

      -- Get capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Setup language servers using new vim.lsp.config API
      local default_config = {
        on_attach = on_attach,
        capabilities = capabilities,
      }

      -- Lua
      vim.lsp.config.lua_ls = vim.tbl_extend("force", default_config, {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Go
      vim.lsp.config.gopls = vim.tbl_extend("force", default_config, {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })

      -- Python
      vim.lsp.config.pyright = vim.tbl_extend("force", default_config, {
        settings = {
          python = {
            pythonPath = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3",
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
        on_init = function(client)
          -- Allow dynamic Python path updates
          client.server_capabilities.workspace = client.server_capabilities.workspace or {}
          client.server_capabilities.workspace.didChangeConfiguration = {
            dynamicRegistration = true,
          }
        end,
      })

      -- TypeScript
      vim.lsp.config.ts_ls = default_config

      -- Rust
      vim.lsp.config.rust_analyzer = vim.tbl_extend("force", default_config, {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })

      -- YAML with schemastore
      vim.lsp.config.yamlls = vim.tbl_extend("force", default_config, {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      -- JSON with schemastore
      vim.lsp.config.jsonls = vim.tbl_extend("force", default_config, {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Helm
      vim.lsp.config.helm_ls = default_config
    end,
  },
}
