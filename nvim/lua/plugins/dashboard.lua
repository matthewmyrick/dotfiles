return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            dashboard = {
                enabled = true,
                sections = {
                    -- Terminal Junkie header at the top
                    {
                        section = "header",
                        padding = 1,
                    },
                    -- Three command panes and Stitch
                    {
                        section = "terminal",
                        cmd = "echo ''; echo ''; echo ''",
                        height = 0,
                        padding = 0,
                    },
                    -- Custom layout with 4 sections
                    {
                        pane = 1,
                        section = "keys",
                        title = "⚡ Quick Actions",
                        padding = { 2, 2 },
                        indent = 3,
                    },
                    {
                        pane = 2,
                        {
                            title = "🔍 Search & Navigation",
                            padding = { 1, 2 },
                            indent = 3,
                            text = {
                                { "  [f] Find File       ", hl = "Special" },
                                { "  [g] Live Grep       ", hl = "Special" },
                                { "  [r] Recent Files    ", hl = "Special" },
                                { "  [b] File Browser    ", hl = "Special" },
                                { "  [/] Search in File  ", hl = "Special" },
                            },
                        },
                    },
                    {
                        pane = 2,
                        {
                            title = "📝 Editor Commands",
                            padding = { 1, 2 },
                            indent = 3,
                            text = {
                                { "  [n] New File        ", hl = "String" },
                                { "  [w] Save File       ", hl = "String" },
                                { "  [c] Open Config     ", hl = "String" },
                                { "  [s] Sessions        ", hl = "String" },
                                { "  [q] Quit            ", hl = "String" },
                            },
                        },
                    },
                    {
                        pane = 2,
                        {
                            title = "🚀 Development",
                            padding = { 1, 2 },
                            indent = 3,
                            text = {
                                { "  [l] Lazy (Plugins)  ", hl = "Function" },
                                { "  [m] Mason (LSP)     ", hl = "Function" },
                                { "  [t] Terminal        ", hl = "Function" },
                                { "  [d] Diagnostics     ", hl = "Function" },
                                { "  [x] Lazy Extras     ", hl = "Function" },
                            },
                        },
                    },
                    -- Startup time at bottom
                    { section = "startup", padding = 1 },
                },
                preset = {
                    pick = function(cmd, opts)
                        return LazyVim.pick(cmd, opts)()
                    end,
                    -- Terminal Junkie header
                    header = [[
  _____                   _             _       _             _    _      
 |_   _|__ _ __ _ __ ___ (_)_ __   __ _| |     | |_   _ _ __ | | _(_) ___ 
   | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | |  _  | | | | | '_ \| |/ / |/ _ \
   | |  __/ |  | | | | | | | | | | (_| | | | |_| | |_| | | | |   <| |  __/
   |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_|  \___/ \__,_|_| |_|_|\_\_|\___|


        ⠀⠀⠀⠀⠀⠀⢀⣀⠤⡤⣠⣄⣀⠠⠔⡱⠉⡀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⢀⠔⠈⠀⠀⠀⠀⠀⠁⠈⠢⢀⠃⢀⡇⠀⠀⣀⠤⠤⡀
        ⠀⢀⢴⡷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣀⠜⠁⡴⠊⠀⠀⡠⠇
        ⢠⠁⣈⢀⢔⣊⣉⡉⠑⡄⠀⠀⠀⠀⢈⡃⠔⡺⠁⠀⠀⠸⢤⠀
        ⠈⠦⡿⣿⣿⣯⣼⡇⠀⠇⠀⠀⣠⠔⢁⣠⡞⠁⠀⠀⢀⡴⠁⠀
        ⠀⠀⠙⠻⢯⡍⠥⠤⠊⠀⠀⠀⢧⣶⣿⠟⠁⠀⣀⠔⠋⠀⠀⠀
        ⠀⠀⠀⠀⠀⣸⡍⢀⡖⠉⠀⠈⠀⠈⠹⣍⠉⠁⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⢰⠉⣾⡠⠀⠀⡜⠀⠀⠀⠈⠣⡀⠀⠀⠀⠀⠀⠀
        ⠀⢠⢲⣲⣍⡉⡰⠃⠀⣀⠤⠧⠤⡀⠀⠀⠀⢹⡀⠀⠀⠀⠀⠀
        ⠀⠀⢿⣧⣸⢿⡇⠠⡾⢄⠁⡂⠀⠀⠀⠀⠀⠀⡅⠀⠀⠀⠀⠀
        ⠀⠀⠀⠉⢛⣿⡮⠥⢇⢀⢗⣇⣀⣀⣀⣀⣤⣾⡧⠀⠀⠀⠀⠀
]],
                    -- Main keys configuration
                    keys = {
                        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        {
                            icon = " ",
                            key = "g",
                            desc = "Find Text",
                            action = ":lua Snacks.dashboard.pick('live_grep')",
                        },
                        {
                            icon = " ",
                            key = "r",
                            desc = "Recent Files",
                            action = ":lua Snacks.dashboard.pick('oldfiles')",
                        },
                        {
                            icon = " ",
                            key = "c",
                            desc = "Config",
                            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                        },
                        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                        { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
            },
        },
    },
}

