-- Disable LazyVim default plugins that we want to customize
return {
  -- Disable LazyVim's bufferline integration to prevent conflicts
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
}