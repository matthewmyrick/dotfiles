-- Simple fuzzy line finder for backslash command
return {
  -- Just add the functionality without messing with noice
  "nvim-telescope/telescope.nvim",
  config = function()
    -- Create custom fuzzy find command
    vim.api.nvim_create_user_command("FuzzyLines", function()
      local builtin = require('telescope.builtin')
      
      -- Get current buffer info
      local bufnr = vim.api.nvim_get_current_buf()
      local filename = vim.fn.expand('%:t')
      
      builtin.current_buffer_fuzzy_find({
        prompt_title = "🔍 Search Lines in Current Buffer",
        results_title = "Matches in " .. filename,
        preview_title = "Context Preview",
        layout_strategy = 'horizontal',
        layout_config = {
          preview_width = 0.6,
          width = 0.95,
          height = 0.85,
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        -- This ensures no results show until user starts typing
        default_text = "",
        attach_mappings = function(prompt_bufnr, map)
          local actions = require('telescope.actions')
          local action_state = require('telescope.actions.state')
          
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              -- Jump to the selected line and center it
              vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
              vim.cmd('normal! zz')
            end
          end)
          return true
        end,
        -- Configure to show more context lines in preview
        preview = {
          treesitter = false,  -- Disable treesitter for faster preview
        },
      })
    end, { desc = "Fuzzy find lines in current buffer only - type to see results" })
    
    -- Custom backslash command that opens the fuzzy finder
    vim.keymap.set('n', '\\', function()
      vim.cmd('FuzzyLines')
    end, { desc = "Fuzzy search in current buffer with context preview" })
  end,
}