#!/usr/bin/env zsh
# Ghostty tab switcher — fuzzy-find across all open Ghostty tabs by title.
#
# How it works:
#   • Ghostty's macOS tabs are AX `radio button`s under the window's tab group.
#     Their AX name == the tab title (the same string you see in the tab bar).
#   • We enumerate them via osascript, pipe to fzf, then click the chosen
#     radio button to switch — that's exactly what clicking the tab does.
#
# Requirements:
#   • Ghostty must have Accessibility permission for System Events
#     (System Settings → Privacy & Security → Accessibility → enable Ghostty).
#     macOS will prompt the first time `tabs` runs and silently fail otherwise.

# Lazy load guard
[[ -n "${_GHOSTTY_TABS_LOADED}" ]] && return
_GHOSTTY_TABS_LOADED=1

# tabs — fuzzy-pick a Ghostty tab by title and switch to it.
tabs() {
    # Enumerate tab titles, one per line. `tr` swaps the AppleScript list
    # separator (comma+space) into newlines because osascript joins lists.
    local titles
    titles=$(osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
    tell process "Ghostty"
        if (count of windows) is 0 then return ""
        try
            set tabNames to {}
            repeat with t in (radio buttons of tab group "tab bar" of window 1)
                set end of tabNames to name of t
            end repeat
            set AppleScript's text item delimiters to linefeed
            return tabNames as text
        on error
            return ""
        end try
    end tell
end tell
APPLESCRIPT
)

    if [[ -z "$titles" ]]; then
        echo "No Ghostty tabs found (or accessibility permission missing)." >&2
        return 1
    fi

    local picked
    picked=$(printf '%s\n' "$titles" | fzf \
        --height '40%' \
        --border 'rounded' \
        --prompt 'tab > ' \
        --header 'Ghostty tabs  •  Enter to switch  •  Esc to cancel')

    [[ -z "$picked" ]] && return 0

    # Click the matching radio button. AppleScript string-escape: we replace
    # backslash → \\ and double-quote → \" so titles with quotes still work.
    local escaped="${picked//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"

    osascript <<APPLESCRIPT >/dev/null 2>&1
tell application "Ghostty" to activate
tell application "System Events"
    tell process "Ghostty"
        click (first radio button of tab group "tab bar" of window 1 whose name is "$escaped")
    end tell
end tell
APPLESCRIPT
}
