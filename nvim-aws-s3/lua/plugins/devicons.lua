-- nvim-web-devicons for file type icons
return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  config = function()
    require("nvim-web-devicons").setup({
      default = true,
    })
  end,
}
