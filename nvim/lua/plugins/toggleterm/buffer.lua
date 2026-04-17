-- Buffer terminal configurations
local M = {}

-- Track Claude attention state globally
_G.claude_needs_attention = false

-- Set of buffers already being monitored (avoid duplicate timers)
local monitored_claude_bufs = {}

-- Start monitoring a terminal buffer for Claude attention patterns
local function start_claude_monitor(buf)
    if monitored_claude_bufs[buf] then
        return
    end
    monitored_claude_bufs[buf] = true

    local timer = vim.loop.new_timer()
    if not timer then
        return
    end

    timer:start(3000, 2000, vim.schedule_wrap(function()
        if not vim.api.nvim_buf_is_valid(buf) then
            timer:stop()
            timer:close()
            monitored_claude_bufs[buf] = nil
            return
        end
        -- Read last 20 lines of terminal output
        local line_count = vim.api.nvim_buf_line_count(buf)
        local start_line = math.max(0, line_count - 20)
        local lines = vim.api.nvim_buf_get_lines(buf, start_line, line_count, false)
        local last_text = table.concat(lines, "\n")

        -- Detect patterns that indicate Claude needs user attention
        local needs_attention = last_text:match("Do you want to proceed")
            or last_text:match("Allow")
            or last_text:match("Deny")
            or last_text:match("Yes.*No")
            or last_text:match("waiting for")
            or last_text:match("Press Enter")
            or last_text:match("approve")
            or last_text:match("permission")
            or last_text:match("> $") -- Claude prompt waiting for input
            or last_text:match("❯ $") -- Alternative prompt

        if needs_attention and not _G.claude_needs_attention then
            _G.claude_needs_attention = true
            -- Send macOS notification
            vim.fn.system(
                "terminal-notifier -title 'Neovim - Claude Code' -message 'Needs your attention' -sound Ping -activate com.mitchellh.ghostty"
            )
            -- Send bell to make Ghostty tab light up
            vim.fn.system("printf '\\a'")
            -- Nvim notification
            vim.notify("Claude needs your attention!", vim.log.levels.WARN)
            -- Write attention flag file for external tools
            vim.fn.system("touch /tmp/claude_needs_attention")
        elseif not needs_attention then
            _G.claude_needs_attention = false
            vim.fn.system("rm -f /tmp/claude_needs_attention")
        end
    end))

    -- Clean up timer when buffer is deleted
    vim.api.nvim_create_autocmd("BufDelete", {
        buffer = buf,
        once = true,
        callback = function()
            _G.claude_needs_attention = false
            monitored_claude_bufs[buf] = nil
            vim.fn.system("rm -f /tmp/claude_needs_attention")
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
        end,
    })
end

-- Helper function to set terminal buffer name with icon
local function set_terminal_name(name)
    -- If name is empty, use default "terminal"
    if name == "" or name == nil then
        name = "terminal"
    end

    -- Check if a buffer with this name already exists and auto-number if needed
    local base_name = name
    local counter = 1
    local full_name = "$ " .. name

    -- Get list of all buffer names
    local existing_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name ~= "" then
                -- Extract just the filename part
                local filename = vim.fn.fnamemodify(buf_name, ":t")
                existing_buffers[filename] = true
            end
        end
    end

    -- If the name already exists, try numbered variations
    while existing_buffers[full_name] do
        counter = counter + 1
        full_name = "$ " .. base_name .. " " .. counter
    end

    vim.cmd("file " .. vim.fn.fnameescape(full_name))
end

-- Helper function to setup terminal buffer autocmds
local function setup_terminal_autocmds()
    local augroup = vim.api.nvim_create_augroup("BufferTerminalNaming", { clear = true })

    -- Auto-name terminal buffers when they are created
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        pattern = "*",
        callback = function()
            -- Only apply to buffer terminals (not splits or floats)
            local win_config = vim.api.nvim_win_get_config(0)
            if not win_config.relative or win_config.relative == "" then
                -- Check if it's not a split by looking at window dimensions
                local win_height = vim.api.nvim_win_get_height(0)
                local win_width = vim.api.nvim_win_get_width(0)
                local total_height = vim.o.lines
                local total_width = vim.o.columns

                -- If the terminal takes up most of the screen, it's likely a buffer terminal
                if win_height >= total_height - 5 and win_width >= total_width - 5 then
                    -- Set default name
                    vim.schedule(function()
                        set_terminal_name("terminal")
                    end)
                end
            end
        end,
    })
end

function M.setup()
    -- Setup autocmds for terminal naming
    setup_terminal_autocmds()

    -- Auto-detect Claude running in ANY terminal buffer
    -- This catches: <leader>tt → typing "claude", <leader>tc, or any other terminal
    -- When detected: renames buffer to "$ claude N" and starts the attention monitor
    local claude_detect_group = vim.api.nvim_create_augroup("ClaudeAutoDetect", { clear = true })
    vim.api.nvim_create_autocmd("TermOpen", {
        group = claude_detect_group,
        pattern = "*",
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            -- Check if the terminal command contains "claude"
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match("claude") then
                start_claude_monitor(buf)
                return
            end
            -- For terminals where user might type "claude" later, poll briefly to detect it
            local detect_timer = vim.loop.new_timer()
            if detect_timer then
                local checks = 0
                detect_timer:start(2000, 3000, vim.schedule_wrap(function()
                    checks = checks + 1
                    -- Stop checking after 60 seconds (20 checks)
                    if checks > 20 or not vim.api.nvim_buf_is_valid(buf) then
                        detect_timer:stop()
                        detect_timer:close()
                        return
                    end
                    -- Check buffer name (set_terminal_name may have renamed it)
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name:match("claude") then
                        start_claude_monitor(buf)
                        detect_timer:stop()
                        detect_timer:close()
                        return
                    end
                    -- Check terminal content for Claude's startup output
                    local line_count = vim.api.nvim_buf_line_count(buf)
                    local start_line = math.max(0, line_count - 15)
                    local lines = vim.api.nvim_buf_get_lines(buf, start_line, line_count, false)
                    local text = table.concat(lines, "\n")
                    if text:match("Claude Code") or text:match("claude%-code") or text:match("Anthropic") then
                        -- Rename the buffer from "$ terminal" to "$ claude"
                        vim.schedule(function()
                            if vim.api.nvim_buf_is_valid(buf) then
                                -- Save current buffer context and rename
                                local cur_buf = vim.api.nvim_get_current_buf()
                                vim.api.nvim_set_current_buf(buf)
                                set_terminal_name("claude")
                                if cur_buf ~= buf and vim.api.nvim_buf_is_valid(cur_buf) then
                                    vim.api.nvim_set_current_buf(cur_buf)
                                end
                            end
                        end)
                        start_claude_monitor(buf)
                        detect_timer:stop()
                        detect_timer:close()
                    end
                end))

                -- Clean up detect timer if buffer dies
                vim.api.nvim_create_autocmd("BufDelete", {
                    buffer = buf,
                    once = true,
                    callback = function()
                        if detect_timer and not detect_timer:is_closing() then
                            detect_timer:stop()
                            detect_timer:close()
                        end
                    end,
                })
            end
        end,
    })

    -- Helper to resolve the Claude binary path
    local function get_claude_bin()
        local nvm_dir = vim.fn.expand("$HOME/.nvm")
        local node_version = vim.fn.system("source " .. nvm_dir .. "/nvm.sh && nvm current"):gsub("%s+", "")
        local claude_path = nvm_dir .. "/versions/node/" .. node_version .. "/bin/claude"
        if vim.fn.filereadable(claude_path) == 1 then
            return claude_path
        end
        return "claude"
    end

    -- Helper function to check for Claude context files
    local function get_claude_context_info()
        local context_sources = {}
        local has_project_context = false
        local project_claude = vim.fn.getcwd() .. "/CLAUDE.md"
        if vim.fn.filereadable(project_claude) == 1 then
            table.insert(context_sources, "project")
            has_project_context = true
        end
        local global_claude = vim.fn.expand("~/.claude/CLAUDE.md")
        if vim.fn.filereadable(global_claude) == 1 then
            table.insert(context_sources, "global")
        end
        return context_sources, has_project_context
    end

    -- Helper function to send command to terminal after delay
    local function send_to_terminal(buf, cmd, delay_ms)
        vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buf) then
                local chan = vim.bo[buf].channel
                if chan then
                    vim.api.nvim_chan_send(chan, cmd)
                end
            end
        end, delay_ms or 1500)
    end

    -- Helper function to create Claude terminal
    local function create_claude_terminal(use_continue, is_half_split)
        local claude_bin = get_claude_bin()
        local context_sources, has_project_context = get_claude_context_info()
        local should_run_init = not use_continue and not has_project_context

        if not use_continue then
            if #context_sources > 0 then
                vim.schedule(function()
                    vim.notify("Claude context: " .. table.concat(context_sources, " + "), vim.log.levels.INFO)
                end)
            elseif should_run_init then
                vim.schedule(function()
                    vim.notify("No project CLAUDE.md found - running /init", vim.log.levels.INFO)
                end)
            end
        end

        local claude_cmd = claude_bin .. (use_continue and " --continue" or "")
        vim.cmd("terminal " .. claude_cmd)
        local term_buf = vim.api.nvim_get_current_buf()

        vim.schedule(function()
            set_terminal_name("claude")
        end)

        if should_run_init then
            send_to_terminal(term_buf, "/init\n", 2000)
        end

        start_claude_monitor(term_buf)

        if use_continue then
            vim.schedule(function()
                local buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_create_autocmd("TermClose", {
                    buffer = buf,
                    once = true,
                    callback = function()
                        vim.schedule(function()
                            if not vim.api.nvim_buf_is_valid(buf) then
                                return
                            end
                            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                            for _, line in ipairs(lines) do
                                if line:match("No conversation found") then
                                    vim.cmd("terminal " .. claude_bin)
                                    vim.schedule(function()
                                        set_terminal_name("claude")
                                    end)
                                    vim.notify("No previous conversation found, started new Claude session", vim.log.levels.INFO)
                                    return
                                end
                            end
                        end)
                    end
                })
            end)
        end
    end

    -- Open Claude in a 33% vertical split with a given command
    local function open_claude_split(claude_args)
        local original_width = vim.api.nvim_win_get_width(0)
        vim.cmd("vsplit")
        vim.cmd("wincmd l")
        local third_width = math.floor(original_width / 3)
        vim.cmd("vertical resize " .. third_width)

        local claude_bin = get_claude_bin()
        vim.cmd("terminal " .. claude_bin .. " " .. claude_args)
        local term_buf = vim.api.nvim_get_current_buf()
        vim.schedule(function()
            set_terminal_name("claude")
        end)
        start_claude_monitor(term_buf)
    end

    -- Parse Claude sessions for current project directory
    local function get_claude_sessions()
        local cwd = vim.fn.getcwd()
        -- Claude normalizes project keys: slashes become hyphens, underscores become hyphens
        local proj_key = cwd:gsub("/", "-"):gsub("_", "-")
        local proj_dir = vim.fn.expand("~/.claude/projects/" .. proj_key)
        local sessions_dir = vim.fn.expand("~/.claude/sessions")

        -- Collect session metadata keyed by sessionId
        local session_meta = {}
        local meta_files = vim.fn.glob(sessions_dir .. "/*.json", false, true)
        for _, f in ipairs(meta_files) do
            local ok, content = pcall(vim.fn.readfile, f)
            if ok and #content > 0 then
                local decoded = vim.fn.json_decode(table.concat(content, "\n"))
                if decoded and decoded.cwd and decoded.cwd:gsub("/$", "") == cwd:gsub("/$", "") then
                    session_meta[decoded.sessionId] = decoded
                end
            end
        end

        -- Parse conversation JSONL files
        local sessions = {}
        local jsonl_files = vim.fn.glob(proj_dir .. "/*.jsonl", false, true)
        for _, f in ipairs(jsonl_files) do
            local sid = vim.fn.fnamemodify(f, ":t"):gsub("%.jsonl$", "")
            local first_msg = ""
            local last_ts = ""
            local msg_count = 0
            -- Collect first few user messages for preview
            local preview_msgs = {}
            local lines = vim.fn.readfile(f)
            for _, line in ipairs(lines) do
                local ok2, d = pcall(vim.fn.json_decode, line)
                if ok2 and d then
                    if d.type == "user" then
                        msg_count = msg_count + 1
                        local msg_text = ""
                        local msg = d.message
                        if type(msg) == "table" then
                            local c = msg.content
                            if type(c) == "string" then
                                msg_text = c
                            elseif type(c) == "table" then
                                for _, part in ipairs(c) do
                                    if type(part) == "table" and part.type == "text" then
                                        msg_text = part.text
                                        break
                                    end
                                end
                            end
                        end
                        if first_msg == "" then
                            first_msg = msg_text:sub(1, 80)
                        end
                        if #preview_msgs < 8 then
                            table.insert(preview_msgs, {
                                role = "user",
                                text = msg_text:sub(1, 200),
                                ts = d.timestamp or "",
                            })
                        end
                        last_ts = d.timestamp or last_ts
                    elseif d.type == "assistant" and #preview_msgs < 8 then
                        local msg = d.message
                        if type(msg) == "table" then
                            local c = msg.content
                            local text = ""
                            if type(c) == "string" then
                                text = c
                            elseif type(c) == "table" then
                                for _, part in ipairs(c) do
                                    if type(part) == "table" and part.type == "text" then
                                        text = text .. part.text
                                    end
                                end
                            end
                            if text ~= "" then
                                table.insert(preview_msgs, {
                                    role = "assistant",
                                    text = text:sub(1, 300),
                                })
                            end
                        end
                    end
                end
            end

            if msg_count > 0 then
                local meta = session_meta[sid] or {}
                table.insert(sessions, {
                    id = sid,
                    name = meta.name or "",
                    first_msg = first_msg,
                    last_ts = last_ts,
                    msg_count = msg_count,
                    mtime = vim.fn.getftime(f),
                    preview_msgs = preview_msgs,
                })
            end
        end

        table.sort(sessions, function(a, b)
            return a.mtime > b.mtime
        end)
        return sessions
    end

    -- Build preview text for a session
    local function build_session_preview(s)
        local lines = {}
        local sep = string.rep("─", 50)

        -- Header
        table.insert(lines, "")
        if s.name ~= "" then
            table.insert(lines, "  Session: " .. s.name)
        end
        table.insert(lines, "  ID:       " .. s.id:sub(1, 12) .. "...")
        table.insert(lines, "  Messages: " .. s.msg_count)
        table.insert(lines, "  Last:     " .. s.last_ts:sub(1, 16):gsub("T", " at "))
        table.insert(lines, "")
        table.insert(lines, "  " .. sep)
        table.insert(lines, "  Conversation preview:")
        table.insert(lines, "  " .. sep)
        table.insert(lines, "")

        for _, m in ipairs(s.preview_msgs or {}) do
            if m.role == "user" then
                table.insert(lines, "  > You:")
                for _, l in ipairs(vim.split(m.text, "\n")) do
                    table.insert(lines, "    " .. l)
                end
                table.insert(lines, "")
            else
                table.insert(lines, "  < Claude:")
                for _, l in ipairs(vim.split(m.text, "\n")) do
                    table.insert(lines, "    " .. l)
                end
                table.insert(lines, "")
                table.insert(lines, "  " .. string.rep("- ", 25))
                table.insert(lines, "")
            end
        end

        return lines
    end

    -- Helper function to find existing Claude buffer (matches "$ claude", "$ claude 2", etc.)
    local function find_claude_buffer()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
                local buf_name = vim.api.nvim_buf_get_name(buf)
                if buf_name ~= "" then
                    local filename = vim.fn.fnamemodify(buf_name, ":t")
                    if filename:match("^%$ claude") then
                        return buf
                    end
                end
            end
        end
        return nil
    end

    vim.api.nvim_create_user_command("ClaudeVerticalTerm", function()
        local claude_buf = find_claude_buffer()

        -- If Claude terminal exists, focus or reopen it
        if claude_buf then
            local claude_win = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == claude_buf then
                    claude_win = win
                    break
                end
            end

            if claude_win then
                vim.api.nvim_set_current_win(claude_win)
                vim.notify("Focused existing Claude terminal", vim.log.levels.INFO)
                return
            else
                local original_width = vim.api.nvim_win_get_width(0)
                vim.cmd("vsplit")
                vim.cmd("wincmd l")
                local third_width = math.floor(original_width / 3)
                vim.cmd("vertical resize " .. third_width)
                vim.api.nvim_set_current_buf(claude_buf)
                vim.notify("Reopened existing Claude terminal", vim.log.levels.INFO)
                return
            end
        end

        -- No existing Claude terminal — show session picker with preview
        local sessions = get_claude_sessions()

        -- Build picker items — "New session" first, then past sessions
        local picker_items = {}

        table.insert(picker_items, {
            idx = 0,
            score = 999999,
            text = "New session",
            session_id = nil,
            preview_lines = {
                "  Start a fresh Claude Code session",
                "",
                "  Project: " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
                "  Path:    " .. vim.fn.getcwd(),
                "",
                "  " .. #sessions .. " previous sessions available",
            },
        })

        for i, s in ipairs(sessions) do
            -- Format the date nicely
            local date_display = s.last_ts:sub(1, 10)
            local time_display = s.last_ts:sub(12, 16) or ""
            if time_display ~= "" then
                date_display = date_display .. " " .. time_display
            end

            -- Truncate first message for list display
            local summary = s.first_msg:gsub("%s+", " "):sub(1, 50)
            if #s.first_msg > 50 then
                summary = summary .. "..."
            end

            -- Session title: use name if available, otherwise first message
            local title = s.name ~= "" and s.name or summary

            table.insert(picker_items, {
                idx = i,
                score = 999999 - i,
                text = title,
                date = date_display,
                msgs = s.msg_count,
                session_id = s.id,
                preview_lines = build_session_preview(s),
            })
        end

        Snacks.picker({
            title = "Claude Sessions (" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ")",
            items = picker_items,
            format = function(item)
                if item.idx == 0 then
                    return {
                        { " + ", "DiagnosticInfo" },
                        { item.text, "DiagnosticInfo" },
                    }
                end
                return {
                    { " " .. tostring(item.idx) .. " ", "Comment" },
                    { " " .. item.text .. "  ", "Normal" },
                    { tostring(item.msgs or 0) .. " msgs", "Comment" },
                    { "  " .. (item.date or ""), "DiagnosticHint" },
                }
            end,
            preview = function(ctx)
                local lines = ctx.item.preview_lines or {}
                ctx.preview:set_lines(lines)
            end,
            confirm = function(picker, item)
                picker:close()
                vim.schedule(function()
                    if item.session_id then
                        open_claude_split("--resume " .. item.session_id)
                    else
                        open_claude_split("")
                    end
                end)
            end,
        })
    end, { nargs = 0, desc = "Open Claude in 33% Vertical Split (with session picker)" })


    -- Helper function to find venv in current repo
    local function find_repo_venv()
        -- Get git root
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
        if not git_root or git_root == "" then
            return nil
        end
        git_root = vim.fn.resolve(git_root)

        -- Find venv or .venv directories
        local find_cmd = string.format(
            'find %s -maxdepth 5 -type d \\( -name "venv" -o -name ".venv" \\) 2>/dev/null | head -1',
            vim.fn.shellescape(git_root)
        )
        local venv_dirs = vim.fn.systemlist(find_cmd)

        if #venv_dirs > 0 and venv_dirs[1] ~= "" then
            local venv_path = venv_dirs[1]
            local activate_script = venv_path .. "/bin/activate"
            if vim.fn.filereadable(activate_script) == 1 then
                return activate_script
            end
        end
        return nil
    end

    -- Enhanced Buffer Terminal (replaces BufferTerm for <leader>tt)
    vim.api.nvim_create_user_command("EnhancedBufferTerm", function()
        -- Check for venv before creating terminal
        local venv_activate = find_repo_venv()

        -- Create new buffer first to avoid "requires unmodified buffer" error
        vim.cmd("enew")
        -- Simple terminal buffer
        vim.cmd("terminal")

        local term_buf = vim.api.nvim_get_current_buf()

        vim.schedule(function()
            set_terminal_name("terminal")

            -- If venv found, activate it after shell is ready
            if venv_activate then
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(term_buf) then
                        local chan = vim.bo[term_buf].channel
                        if chan then
                            vim.api.nvim_chan_send(chan, "source " .. vim.fn.shellescape(venv_activate) .. "\n")
                            vim.notify("Activated venv: " .. venv_activate:gsub("/bin/activate$", ""), vim.log.levels.INFO)
                        end
                    end
                end, 500) -- Wait 500ms for shell to be ready
            end
        end)
    end, { nargs = 0, desc = "Open simple terminal buffer (auto-activates venv if found)" })

    -- Terminal in current file's directory
    vim.api.nvim_create_user_command("TerminalInFileDir", function()
        -- Use default name "terminal" without prompting
        local name = "terminal"

        -- Get the directory of the current file
        local current_file = vim.fn.expand("%:p")
        local file_dir = vim.fn.fnamemodify(current_file, ":h")

        -- If the current buffer is not a file (e.g., empty buffer), use current working directory
        if current_file == "" or vim.bo.buftype ~= "" then
            file_dir = vim.fn.getcwd()
        end

        -- Open terminal in new buffer
        vim.cmd("enew")
        vim.cmd("terminal " .. vim.o.shell)

        vim.schedule(function()
            set_terminal_name(name)
            -- Change directory after the terminal opens
            if vim.b.terminal_job_id then
                vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(file_dir) .. "\r")
            end
        end)
    end, { nargs = 0, desc = "Open Terminal in current file's directory" })

    -- Terminal rename command
    vim.api.nvim_create_user_command("TerminalRename", function()
        -- Check if current buffer is a terminal
        if vim.bo.buftype ~= "terminal" then
            vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
            return
        end

        -- Get current name (remove the "$ " prefix if present)
        local current_name = vim.fn.expand("%:t")
        if current_name:sub(1, 2) == "$ " then
            current_name = current_name:sub(3)
        end

        -- Prompt for new name
        local new_name = vim.fn.input("New terminal name: ", current_name)

        -- Set the new name (empty input defaults to "terminal")
        set_terminal_name(new_name)
    end, { nargs = 0, desc = "Rename terminal buffer" })
end

-- Return keymaps for buffer terminals
function M.keymaps()
    return {
        { "<leader>tt", "<cmd>EnhancedBufferTerm<CR>", desc = "Terminal (simple buffer)" },
        { "<leader>td", "<cmd>TerminalInFileDir<CR>", desc = "Terminal in current file's directory" },
        { "<leader>tc", "<cmd>ClaudeVerticalTerm<CR>", desc = "Claude (33% vertical split)" },
        { "<leader>tr", "<cmd>TerminalRename<CR>", desc = "Rename Terminal Buffer" },
    }
end

return M
