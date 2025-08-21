return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { 
        enabled = false,
        auto_trigger = false,
      },
      panel = { 
        enabled = false,
      },
      filetypes = {
        ["*"] = false, -- Disable for all file types
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      -- Suppress Copilot warnings
      local notify = vim.notify
      vim.notify = function(msg, ...)
        if msg:match("Copilot") and msg:match("disabled") then
          return
        end
        return notify(msg, ...)
      end
    end,
  },
}