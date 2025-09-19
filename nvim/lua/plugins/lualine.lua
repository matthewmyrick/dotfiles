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
    if not opts.sections.lualine_c then
      opts.sections.lualine_c = {}
    end
    
    -- Custom filename component that shows 5 directories
    local custom_filename = {
      function()
        local path = vim.fn.expand('%:p')  -- Get full path
        if path == '' then
          return '[No Name]'
        end
        
        -- Split path into components
        local parts = {}
        for part in path:gmatch('[^/]+') do
          table.insert(parts, part)
        end
        
        -- Get last 5 directories + filename
        local num_parts = #parts
        local start_idx = math.max(1, num_parts - 5)
        
        -- Rebuild the path with last 5 components
        local result = {}
        for i = start_idx, num_parts do
          table.insert(result, parts[i])
        end
        
        -- Add ... if there are more directories
        if start_idx > 1 then
          return '.../' .. table.concat(result, '/')
        else
          return table.concat(result, '/')
        end
      end,
      icon = '',
      color = {},
    }
    
    -- Replace filename component in lualine_c with custom one
    opts.sections.lualine_c = { custom_filename }
    
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