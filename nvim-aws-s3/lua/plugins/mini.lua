-- Mini.nvim - Text objects, surround, pairs
return {
  "echasnovski/mini.nvim",
  event = "VeryLazy",
  config = function()
    -- mini.ai - Extend text objects (yiq, diq, ciq, etc.)
    require("mini.ai").setup()

    -- mini.surround - Surround actions
    require("mini.surround").setup()

    -- mini.pairs - Autopairs for quotes, brackets
    require("mini.pairs").setup()
  end,
}
