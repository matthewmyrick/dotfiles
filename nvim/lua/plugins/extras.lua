-- Extra utility plugins
return {
  -- Better % matching
  {
    "andymass/vim-matchup",
    event = { "BufReadPost" },
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Search and replace
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
        end,
        desc = "Search and Replace (current file)",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Search word under cursor",
      },
      {
        "<leader>sw",
        mode = "v",
        function()
          require("grug-far").with_visual_selection()
        end,
        desc = "Search visual selection",
      },
    },
    config = function()
      require("grug-far").setup({
        headerMaxWidth = 80,
        windowCreationCommand = "vsplit",
      })
    end,
  },

}
