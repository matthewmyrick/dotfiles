-- Disable LazyVim default plugins that we want to customize
return {
  -- Disable LazyVim's bufferline integration to prevent conflicts
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  -- Completely disable blink.cmp - it has origin issues and conflicts
  {
    "saghen/blink.cmp",
    enabled = false,
  },
  {
    "Saghen/blink.cmp", 
    enabled = false,
  },
  {
    "blink.cmp",
    enabled = false,
  },
  -- Disable LazyVim's completion extra that includes blink.cmp
  {
    import = "lazyvim.plugins.extras.coding.blink",
    enabled = false,
  },
}