-- Mini.nvim - Collection of minimal, independent modules
return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  config = function()
    -- mini.ai - Extend and create text objects (around/inside)
    require("mini.ai").setup()

    -- mini.align - Align text interactively
    require("mini.align").setup()

    -- mini.bracketed - Go forward/backward with square brackets
    require("mini.bracketed").setup()

    -- mini.bufremove - Remove buffers
    require("mini.bufremove").setup()

    -- mini.comment - Comment code (alternative to Comment.nvim)
    require("mini.comment").setup()

    -- mini.cursorword - Highlight word under cursor
    require("mini.cursorword").setup()

    -- mini.diff - Git diff signs (replaces gitsigns)
    require("mini.diff").setup({
      view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
      },
    })

    -- mini.git - Git integration
    require("mini.git").setup()

    -- mini.icons - Icon provider
    require("mini.icons").setup()

    -- mini.indentscope - Visualize and operate on indent scope
    require("mini.indentscope").setup({
      symbol = "│",
      options = { try_as_border = true },
    })

    -- mini.move - Move any selection in any direction
    require("mini.move").setup()

    -- mini.operators - Text edit operators
    require("mini.operators").setup()

    -- mini.pairs - Autopairs (alternative to nvim-autopairs)
    require("mini.pairs").setup()

    -- mini.splitjoin - Split and join arguments
    require("mini.splitjoin").setup()

    -- mini.surround - Surround actions
    require("mini.surround").setup()

    -- mini.trailspace - Trailing whitespace
    require("mini.trailspace").setup()
  end,
}
