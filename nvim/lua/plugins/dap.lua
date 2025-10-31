-- Debug Adapter Protocol (DAP) for debugging
return {
  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for nvim-dap
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",

      -- Python debugger
      "mfussenegger/nvim-dap-python",

      -- Virtual text showing variable values
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")

      -- Setup DAP UI
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
      })

      -- Setup Python debugger (uses debugpy)
      -- This will use the Python interpreter from your current environment
      dap_python.setup("python")

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Icons for breakpoints
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "⭕", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "", linehl = "", numhl = "" })
    end,
    keys = {
      -- Start/Continue debugging
      { "<leader>mc", function() require("dap").continue() end, desc = "Debug: Start/Continue" },

      -- Breakpoints
      { "<leader>mb", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>mB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },

      -- Step controls
      { "<leader>mi", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<leader>mo", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<leader>mO", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>mj", function() require("dap").down() end, desc = "Debug: Down Stack" },
      { "<leader>mk", function() require("dap").up() end, desc = "Debug: Up Stack" },

      -- UI controls
      { "<leader>mu", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>me", function() require("dapui").eval() end, desc = "Debug: Eval", mode = {"n", "v"} },

      -- Terminate
      { "<leader>mt", function() require("dap").terminate() end, desc = "Debug: Terminate" },

      -- Run last
      { "<leader>mr", function() require("dap").run_last() end, desc = "Debug: Run Last" },

      -- Python specific
      { "<leader>mm", function() require("dap-python").test_method() end, desc = "Debug: Test Method", ft = "python" },
      { "<leader>mC", function() require("dap-python").test_class() end, desc = "Debug: Test Class", ft = "python" },
    },
  },
}
