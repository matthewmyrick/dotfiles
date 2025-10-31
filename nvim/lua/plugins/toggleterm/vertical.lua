-- Vertical terminal configurations
local M = {}

function M.setup()
    -- 50% Vertical Terminal
    vim.api.nvim_create_user_command("TermVertical", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "vertical",
            size = vim.o.columns * 0.50,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 50% Vertical Terminal" })
end

-- Return keymaps for vertical terminals
function M.keymaps()
    return {
        { "<leader>tv", "<cmd>TermVertical<CR>", desc = "Toggle 50% Vertical Terminal" },
    }
end

return M