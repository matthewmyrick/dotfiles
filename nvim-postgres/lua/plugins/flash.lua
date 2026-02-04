-- Flash.nvim - Navigate your code with search labels
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    labels = "asdfghjklqwertyuiopzxcvbnm",
    search = {
      multi_window = false,
      forward = true,
      wrap = true,
      mode = "exact",
      incremental = false,
    },
    jump = {
      autojump = false,
      pos = "start",
    },
    label = {
      uppercase = true,
      rainbow = {
        enabled = false,
      },
    },
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
    modes = {
      search = {
        enabled = false,
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
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
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
