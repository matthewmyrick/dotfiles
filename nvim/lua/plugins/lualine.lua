return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Override the default time format in the status line
    if not opts.sections then
      opts.sections = {}
    end
    if not opts.sections.lualine_z then
      opts.sections.lualine_z = {}
    end
    
    -- Replace the entire lualine_z section with only EST time
    opts.sections.lualine_z = {
      {
        function()
          return os.date("%I:%M %p EST")
        end,
      }
    }
    
    return opts
  end,
}