-- Window focus highlighting configuration
local M = {}

function M.setup()
    -- Create autocmd group for window focus
    local group = vim.api.nvim_create_augroup("WindowFocusHighlight", { clear = true })

    -- Set up highlight groups for active/inactive windows
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
            -- Active window - normal brightness
            vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "NONE" })
            
            -- Inactive window - slightly dimmed
            local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
            if normal_bg then
                -- Darken the background slightly for inactive windows
                vim.api.nvim_set_hl(0, "InactiveWindow", { 
                    bg = normal_bg,
                    blend = 10  -- 10% blend to make it slightly dimmer
                })
            else
                -- Fallback if no background color
                vim.api.nvim_set_hl(0, "InactiveWindow", { 
                    fg = "#6c6c6c",  -- Dimmed text
                    bg = "NONE"
                })
            end
            
            -- Cursor line highlight for active window
            vim.api.nvim_set_hl(0, "ActiveCursorLine", { 
                bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg or "#2d2d2d",
                bold = true
            })
            
            -- Dimmed cursor line for inactive windows
            vim.api.nvim_set_hl(0, "InactiveCursorLine", { 
                bg = "#1a1a1a"
            })
        end,
    })

    -- Apply window highlighting when entering/leaving windows
    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
        group = group,
        callback = function()
            -- Set active window highlights
            vim.wo.winhighlight = "Normal:ActiveWindow,CursorLine:ActiveCursorLine"
        end,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        group = group,
        callback = function()
            -- Set inactive window highlights
            vim.wo.winhighlight = "Normal:InactiveWindow,CursorLine:InactiveCursorLine"
        end,
    })

    -- Terminal-specific highlighting
    vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        callback = function()
            -- Different highlighting for terminal windows
            vim.api.nvim_set_hl(0, "TerminalActive", { 
                bg = "#1e1e2e",  -- Slightly different background for terminals
                fg = "#cdd6f4"
            })
            vim.api.nvim_set_hl(0, "TerminalInactive", { 
                bg = "#11111b",  -- Darker for inactive terminals
                fg = "#6c7086"   -- Dimmed text
            })
        end,
    })

    -- Apply terminal highlights
    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
        group = group,
        pattern = "term://*",
        callback = function()
            vim.wo.winhighlight = "Normal:TerminalActive"
        end,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        group = group,
        pattern = "term://*",
        callback = function()
            vim.wo.winhighlight = "Normal:TerminalInactive"
        end,
    })

    -- Initial setup
    vim.schedule(function()
        vim.cmd("doautocmd ColorScheme")
    end)
end

return M