-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Import plugins from plugins directory
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- Don't lazy-load by default
    version = false, -- Use latest git commit
  },
  install = { colorscheme = { "catppuccin-mocha" } },
  checker = {
    enabled = true, -- Check for plugin updates
    notify = false, -- Don't notify on update
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
  },
})
