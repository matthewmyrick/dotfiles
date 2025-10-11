-- Horizontal terminal configurations
local M = {}

function M.setup()
    -- 50% Horizontal Terminal
    vim.api.nvim_create_user_command("TermH50", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "horizontal",
            size = vim.o.lines * 0.5,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 50% Horizontal Terminal" })

    -- Fullscreen Horizontal Terminal
    vim.api.nvim_create_user_command("TermHFull", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "horizontal",
            size = vim.o.lines,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Fullscreen Horizontal Terminal" })
end

-- Return keymaps for horizontal terminals
function M.keymaps()
    return {
        { "<leader>thh", "<cmd>TermH50<CR>", desc = "Toggle 50% Horizontal Terminal" },
        { "<leader>thf", "<cmd>TermHFull<CR>", desc = "Toggle Fullscreen Horizontal Terminal" },
    }
end

return M