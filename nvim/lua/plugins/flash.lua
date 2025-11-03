-- Flash.nvim - Navigate your code with search labels
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Labels to use for jump targets
    labels = "asdfghjklqwertyuiopzxcvbnm",

    -- Search settings
    search = {
      multi_window = false,  -- Only search in current buffer
      forward = true,
      wrap = true,
      mode = "exact",
      incremental = false,
    },

    -- Jump settings
    jump = {
      autojump = false,
      pos = "start",
    },

    -- Label settings
    label = {
      uppercase = true,
      rainbow = {
        enabled = false,
      },
    },

    -- Highlight settings
    highlight = {
      backdrop = true,
      matches = true,
      groups = {
        match = "FlashMatch",
        current = "FlashCurrent",
        backdrop = "FlashBackdrop",
        label = "FlashLabel",
      },
    },

    -- Modes configuration
    modes = {
      search = {
        enabled = false,  -- Disable flash integration with / search
      },
      char = {
        enabled = true,
        keys = { "f", "F", "t", "T", ";", "," },
        search = { wrap = false },
        highlight = { backdrop = true },
        jump = { register = false },
      },
    },
  },
  keys = {
    -- Main flash search - press 's' to activate (current buffer only)
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump({
          search = { multi_window = false },
        })
      end,
      desc = "Flash (current buffer)",
    },

    -- Flash treesitter - search by treesitter nodes
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },

    -- Remote flash - search in other windows
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },

    -- Toggle search mode
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}
