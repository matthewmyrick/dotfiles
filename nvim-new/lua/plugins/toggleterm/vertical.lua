-- Vertical terminal configurations
local M = {}

function M.setup()
    -- 50% Vertical Terminal
    vim.api.nvim_create_user_command("TermV50", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "vertical",
            size = vim.o.columns * 0.50,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle 50% Vertical Terminal" })

    -- Fullscreen Vertical Terminal
    vim.api.nvim_create_user_command("TermVFull", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "vertical",
            size = vim.o.columns,
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Fullscreen Vertical Terminal" })
end

-- Return keymaps for vertical terminals
function M.keymaps()
    return {
        { "<leader>tvv", "<cmd>TermV50<CR>", desc = "Toggle 50% Vertical Terminal" },
        { "<leader>tvf", "<cmd>TermVFull<CR>", desc = "Toggle Fullscreen Vertical Terminal" },
    }
end

return M