-- Snacks.nvim - UI components (explorer, picker, dashboard, notifier)
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Dashboard
    dashboard = {
      enabled = true,
      win = {
        wo = {
          winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Ignore,SignColumn:Normal",
        },
      },
      preset = {
        keys = {
          { icon = "🔍", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
          { icon = "📝", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = "🕒", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = "💤", key = "L", desc = "Lazy", action = ":Lazy" },
          { icon = "⚙️ ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
          { icon = "🚪", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠓⠢⣄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠇⠀⠀⠀⠙⠦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⣽⠀⠀⠀⠀
⠀⠀⠀⢠⠞⠉⠈⢷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⣸⠃⠀⠀⠀⠀
⠀⠀⡰⠋⠀⠀⠀⠘⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠀⠀⠀⠀⠈⠈⠉⢳⡀⠀
⠀⡰⠁⠀⠀⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣇⠀⠀⠀⠀⠀⠀⠀⢧⠀
⢠⠃⠀⠀⠀⠀⠀⠀⠀⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠸⡆
⠘⠀⠀⠀⠀⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣿⣿⣚⢷⣄⠀⠀⠀⠀⠀⠀⢸⢳⡀⠀⠀⠀⠀⠀⠀⡇
⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢀⣤⢤⡤⠒⠊⠉⢡⢄⣀⠀⠀⠀⡨⢷⡤⣀⠀⠀⠀⣸⠀⢷⡀⠀⠀⠀⠀⠀⡇
⢇⠀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⣠⠋⠙⡇⢁⡠⠾⠻⠯⢭⣚⠅⠀⢨⠞⢉⠈⠉⠳⡄⠀⡇⠀⠘⡆⠀⠀⠀⠀⢠⡇
⢸⡀⠀⠀⠀⠀⠀⠀⠀⢸⢳⡀⠀⣴⢿⣶⣄⡿⠋⠀⠀⠀⠀⠀⠉⢧⣠⢣⡞⢻⣿⣿⣶⡈⢾⠅⠀⠀⡇⠀⠀⠀⠀⣼⠀
⠀⢧⠀⠀⠀⠀⠀⠀⠀⣼⠀⢷⣸⣿⣼⣿⣿⣧⡀⠀⠀⠀⠀⢀⠄⣴⡏⣿⣷⣾⣿⣿⣿⡇⠘⡇⠀⠀⡇⠀⠀⠀⢰⠏⠀
⠀⠈⣧⠀⠀⠀⠀⠀⠀⣹⠀⢘⠋⣿⣿⡿⡟⠳⣷⡀⠀⠀⢀⠎⣠⠃⠣⡀⠙⠿⠿⠿⠟⠁⠀⣳⠀⢀⡇⠀⣀⣴⠏⠀⠀
⠀⠀⠈⢧⡀⠀⢀⣀⡀⢸⡄⣼⡀⠈⠉⡜⡄⠀⠈⠓⠤⡤⠾⠚⠁⠀⠀⠺⢕⠢⠄⣀⣀⠠⠔⠛⠀⣸⠒⠉⣰⠏⠀⠀⠀
⠀⠀⠀⠈⠋⠉⢁⡾⠁⠀⢳⣌⠉⠒⠊⣊⠤⠴⡖⠒⣲⠋⠻⡀⢒⡶⡆⠤⢄⣉⡁⠀⠀⢠⡀⠀⠘⠁⣠⠞⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠻⢖⡒⠒⠚⢻⠀⣴⢯⣣⡀⢰⠉⠙⠁⢀⡠⠬⠥⣀⠘⡄⢀⣴⡽⡯⠟⢹⡃⢠⠗⠋⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⠒⠼⢦⡙⣍⠁⣈⣉⠤⠤⠴⠥⣀⣀⡠⠖⠉⠙⠉⢡⠼⢯⣳⠏⢘⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣏⢻⢛⣧⢀⠀⠀⠀⠈⠁⠀⠀⣀⣀⣖⠒⠧⣠⠏⢀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣄⠹⣤⠋⣆⠀⣀⠀⠀⣀⠀⡇⠀⠙⣦⠔⠁⡠⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡧⣌⠑⠼⣺⡉⢣⢼⢈⣳⡳⠔⠊⣁⢴⡊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⠤⡔⠊⠀⠈⠑⠢⠤⣀⣈⣁⣀⡀⠤⠔⠊⣳⢄⠙⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡞⠁⠀⡰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⡄⠀⠀⠀⣎⢻⠃⠈⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⢏⠤⠒⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠀⠀⠈⢷⣿⠆⢰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⡾⡇⠀⠀⠀⠀⠀⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⡸⠋⠀⢸⡀⠀⠀⢀⣴⣤⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⠁⡇⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠑⡄⠀⡰⠁⠀⠀⠈⢯⠲⣴⠟⠛⢻⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣼⠉⠀⠀⠀⠀⠀⠀⣀⣀⣇⡀⠀⠀⠀⠀⠀⠀⠀⠘⣤⠃⠀⠀⠀⠀⠘⣆⠙⢀⣴⠞⢧⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡞⠉⣿⠀⠀⠀⠀⠀⠔⠋⠁⠀⠀⠈⠑⢆⠀⠀⠀⠀⠀⠀⠘⣆⠀⠀⠀⠀⠀⢸⠀⠸⡜⢦⡎⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠱⡀⠈⠀⠀⠀⠀⠀⠀⠀⠀⣮⣩⠽⠶⢠⢷⠤⡄⠀⠀⠀⠀⠘⡆⠀⠀⠀⢰⣯⡦⡤⣀⡹⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠲⠧⡀⠀⠀⠀⠀⠀⣸⠃⡠⠔⠀⠤⡈⠳⢼⠀⠀⠀⢀⣞⡤⠤⣀⣀⣀⣀⣼⣛⡻⣝⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠢⣄⡀⢠⠮⡝⡸⠀⠀⢣⠀⠘⡄⡏⠀⢀⡀⠘⠋⠉⣾⣏⠭⠷⠀⠁⠀⠈⠉⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣨⠇⢱⡀⠀⡼⠀⢠⠷⣻⣐⡋⣌⣳⣀⡼⠓⠢⣝⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠣⣙⣦⣤⠴⠯⠚⠛⠉⠛⠓⠺⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]],
      },
      sections = {
        -- Left pane: Header and Keys
        { section = "header",  pane = 1 },
        { section = "keys",    gap = 1, padding = 1, pane = 1 },
        -- Right pane: Load speed at top
        { section = "startup", pane = 2, padding = 1 },
        -- Right pane: Git Info
        {
          pane = 2,
          icon = " ",
          title = "Git Information",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = [=[
# Get remote URL and extract organization/owner
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo '')
if [[ -n "$REMOTE_URL" ]]; then
  # Extract organization from GitHub URLs (both HTTPS and SSH)
  if [[ "$REMOTE_URL" =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
    ORG="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
  else
    ORG="Unknown"
    REPO=$(basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null || echo 'Unknown')
  fi
else
  ORG="Not in a git repo"
  REPO=""
fi

echo "\033[0;35m🏢 Organization:\033[0m $ORG"
echo "\033[0;36m📦 Repository:\033[0m $REPO"
echo "\033[0;35m🌐 Remote:\033[0m ${REMOTE_URL:-'No remote configured'}"
echo ""

# Current branch info
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo 'No branch')
echo "\033[0;32m🌿 Current Branch:\033[0m $CURRENT_BRANCH"

# Current branch latest commit and author
if [[ -n "$CURRENT_BRANCH" ]]; then
  echo "\033[0;33m📝 Latest Commit:\033[0m $(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null || echo 'No commits')"
  echo "\033[0;33m👤 Author:\033[0m $(git log -1 --pretty=format:'%an <%ae>' 2>/dev/null || echo 'No author')"
fi
echo ""

# Main branch info (usually main or master)
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo 'main')
if git show-ref --verify --quiet "refs/heads/$MAIN_BRANCH" || git show-ref --verify --quiet "refs/remotes/origin/$MAIN_BRANCH"; then
  echo "\033[0;34m🎯 $MAIN_BRANCH Branch:\033[0m"
  echo "  Latest Commit: $(git log -1 --pretty=format:'%h - %s (%cr)' $MAIN_BRANCH 2>/dev/null || echo 'No commits')"
  echo "  Author: $(git log -1 --pretty=format:'%an <%ae>' $MAIN_BRANCH 2>/dev/null || echo 'No author')"
  echo ""
fi

# Merge status check (only if on a different branch)
if [[ "$CURRENT_BRANCH" != "$MAIN_BRANCH" && -n "$CURRENT_BRANCH" ]]; then
  echo "\033[0;36m🔀 Merge Status:\033[0m"

  # Check if we can merge into main
  MERGE_BASE=$(git merge-base $CURRENT_BRANCH $MAIN_BRANCH 2>/dev/null)
  if [[ $? -eq 0 ]]; then
    # Try a test merge to see if there are conflicts
    git merge-tree $MERGE_BASE $MAIN_BRANCH $CURRENT_BRANCH > /tmp/merge-test 2>&1

    if grep -q "<<<<<<< " /tmp/merge-test; then
      echo "  ⚠️  \033[0;31mMerge conflicts detected\033[0m"
      echo "  Conflicting files:"
      grep -B1 "<<<<<<< " /tmp/merge-test | grep "^+" | sed 's/^+/    - /' | head -5
    else
      AHEAD=$(git rev-list --count $MAIN_BRANCH..$CURRENT_BRANCH 2>/dev/null || echo '0')
      BEHIND=$(git rev-list --count $CURRENT_BRANCH..$MAIN_BRANCH 2>/dev/null || echo '0')

      if [[ "$AHEAD" -gt 0 && "$BEHIND" -eq 0 ]]; then
        echo "  ✅ \033[0;32mCan merge cleanly\033[0m ($AHEAD commits ahead)"
      elif [[ "$AHEAD" -gt 0 && "$BEHIND" -gt 0 ]]; then
        echo "  🔄 Can merge cleanly ($AHEAD ahead, $BEHIND behind)"
      else
        echo "  ℹ️  Up to date with $MAIN_BRANCH"
      fi
    fi
    rm -f /tmp/merge-test
  else
    echo "  ⚠️  Cannot determine merge status"
  fi
  echo ""
fi

echo "\033[0;34m🏷️  Latest Tag:\033[0m $(git describe --tags --abbrev=0 2>/dev/null || echo 'No tags')"
echo ""
echo "\033[0;36m📈 Stats:\033[0m"
echo "  Commits: $(git rev-list --count HEAD 2>/dev/null || echo '0')"
echo "  Contributors: $(git shortlog -sn --all | wc -l | tr -d ' ' 2>/dev/null || echo '0')"
echo "  Branches: $(git branch -a | wc -l | tr -d ' ' 2>/dev/null || echo '0')"
echo ""
echo "\033[0;31m📊 Status:\033[0m"
STATUS_OUTPUT=$(git status --short 2>/dev/null)
if [[ -z "$STATUS_OUTPUT" ]]; then
  echo "  ✓ Working tree clean"
else
  echo "$STATUS_OUTPUT"
fi
          ]=],
          height = 20,
          padding = 1,
          ttl = 5 * 60,
        },
      },
    },
    -- File Explorer
    explorer = {
      layout = {
        backdrop = false,
      },
      win = {
        wo = {
          winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Ignore,SignColumn:Normal",
        },
      },
      git = {
        enable = true,
        icons = {
          untracked = "?",
          added = "+",
          modified = "~",
          deleted = "-",
          renamed = "→",
          ignored = "!",
        },
        hl = {
          untracked = "DiagnosticWarn",
          added = "DiagnosticInfo",
          modified = "DiagnosticHint",
          deleted = "DiagnosticError",
          renamed = "DiagnosticInfo",
          ignored = "Comment",
        },
      },
      filters = {
        dotfiles = true,    -- Hide dotfiles by default (toggle with 'H')
        git_ignored = true, -- Hide git ignored files by default (toggle with 'I')
        custom = {},
      },
      follow_symlinks = true,
      show_hidden = false, -- Hide hidden files by default
      close_on_select = false,
      auto_close = false,
      replace_netrw = true,
      hijack_netrw = true,
    },
    -- Notifier
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 1, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "compact",
      top_down = true, -- Show from top down instead of bottom up
      date_format = "%I:%M %p EST",
    },
    -- Picker (fuzzy finder)
    picker = {
      enabled = true,
      layout = {
        backdrop = false,
      },
      win = {
        input = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Ignore,SignColumn:Normal",
          },
        },
        list = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Ignore,SignColumn:Normal",
          },
        },
        preview = {
          backdrop = false,
          wo = {
            winblend = 0,
            winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:Normal,EndOfBuffer:Ignore,SignColumn:Normal",
          },
        },
      },
    },
    -- Lazygit integration
    lazygit = { enabled = true },
    -- Git browse
    gitbrowse = { enabled = true },
    -- Big file handling
    bigfile = { enabled = true },
    -- Quickfile
    quickfile = { enabled = true },
    -- Status column
    statuscolumn = { enabled = false },
    -- Words
    words = { enabled = false },
    -- Input (replaces dressing.nvim for vim.ui.input)
    input = { enabled = true },
    -- Image viewing support
    image = { enabled = true },
    -- Layout manager (controls window dimensions)
    layout = { enabled = true },
  },
  keys = {
    -- File Explorer
    { "<leader>e",        function() Snacks.explorer() end,                desc = "Open/Focus File Explorer" },

    -- Snacks Picker
    { "<leader><leader>", function() Snacks.picker.files() end,            desc = "Find Files" },
    { "<leader>fb",       function() Snacks.picker.buffers() end,          desc = "Find Buffers" },
    { "<leader>fr",       function() Snacks.picker.recent() end,           desc = "Recent Files" },
    { "<leader>fc",       function() Snacks.picker.commands() end,         desc = "Commands" },
    { "<leader>fk",       function() Snacks.picker.keymaps() end,          desc = "Keymaps" },
    { "<leader>fh",       function() Snacks.picker.help() end,             desc = "Help Tags" },

    -- Other Snacks features
    { "<leader>n",        function() Snacks.notifier.show_history() end,   desc = "Notification History" },
    { "<leader>bd",       function() Snacks.bufdelete() end,               desc = "Delete Buffer" },

    -- Git
    { "<leader>gb",       function() Snacks.git.blame_line() end,          desc = "Git Blame Line" },
    { "<leader>gB",       function() Snacks.gitbrowse() end,               desc = "Git Browse" },
    { "<leader>gf",       function() Snacks.lazygit.log_file() end,        desc = "Lazygit Current File History" },
    { "<leader>gg",       function() Snacks.lazygit() end,                 desc = "Lazygit" },
    { "<leader>gl",       function() Snacks.lazygit.log() end,             desc = "Lazygit Log (cwd)" },

    -- Misc
    { "<leader>un",       function() Snacks.notifier.hide() end,           desc = "Dismiss All Notifications" },
    { "]]",               function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference" },
    { "[[",               function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for easier access
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create vim.ui.select and vim.ui.input wrappers
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
      end,
    })
  end,
}
