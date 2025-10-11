-- Floating terminal configurations
local M = {}

function M.setup()
    -- General Floating Terminal
    vim.api.nvim_create_user_command("TermFF", function()
        local term = require("toggleterm.terminal").Terminal:new({
            direction = "float",
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                row = math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2),
                col = math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2),
            },
            hidden = true,
        })
        vim.schedule(function()
            term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle Floating Terminal" })
end

-- Return keymaps for floating terminals
function M.keymaps()
    return {
        { "<leader>tff", "<cmd>TermFF<CR>", desc = "Toggle Floating Terminal" },
    }
end

return M
