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

    -- k9s (Kubernetes TUI)
    local k9s_term = nil
    vim.api.nvim_create_user_command("TermK9s", function()
        if k9s_term == nil then
            k9s_term = require("toggleterm.terminal").Terminal:new({
                cmd = "k9s",
                direction = "float",
                float_opts = {
                    border = "curved",
                    width = math.floor(vim.o.columns * 0.9),
                    height = math.floor(vim.o.lines * 0.9),
                    row = math.floor((vim.o.lines - (vim.o.lines * 0.9)) / 2),
                    col = math.floor((vim.o.columns - (vim.o.columns * 0.9)) / 2),
                },
                hidden = true,
                on_exit = function()
                    k9s_term = nil
                end,
            })
        end
        vim.schedule(function()
            k9s_term:toggle()
        end)
    end, { nargs = 0, desc = "Toggle k9s (Kubernetes)" })
end

-- Return keymaps for floating terminals
function M.keymaps()
    return {
        { "<leader>tff", "<cmd>TermFF<CR>", desc = "Toggle Floating Terminal" },
        { "<leader>kb", "<cmd>TermK9s<CR>", desc = "Toggle k9s (Kubernetes)" },
    }
end

return M
