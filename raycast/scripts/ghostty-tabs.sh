#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Ghostty Tab
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 👻
# @raycast.alias tabs
# @raycast.packageName GhosttyTabs
# @raycast.argument1 { "type": "text", "placeholder": "tab title (fuzzy)", "optional": false }

# Documentation:
# @raycast.description Fuzzy-search open Ghostty tabs by title and switch to the match.
# @raycast.author matthew_myrick
# @raycast.authorURL https://raycast.com/matthew_myrick

set -euo pipefail

QUERY="$1"

if ! command -v fzf &>/dev/null; then
    echo "fzf is not installed. Run: brew install fzf"
    exit 1
fi

# Enumerate Ghostty tab titles (each tab is an AX radio button under the
# window tab bar group; the AX name == tab title).
# Note: apostrophes (eg. "AppleScript's") trip bash parsing inside $()
# even in a quoted heredoc — so we concat manually instead of using
# `AppleScript's text item delimiters`.
TITLES=$(/usr/bin/osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
    tell process "Ghostty"
        if (count of windows) is 0 then return ""
        try
            set tabStr to ""
            repeat with t in (radio buttons of tab group "tab bar" of window 1)
                set tabStr to tabStr & (name of t) & linefeed
            end repeat
            return tabStr
        on error
            return ""
        end try
    end tell
end tell
APPLESCRIPT
)

if [[ -z "$TITLES" ]]; then
    echo "No Ghostty tabs (or accessibility permission missing for Raycast)"
    exit 1
fi

# Use fzf in filter-mode (non-interactive) to fuzzy-rank against the query
# and grab the top match.
PICKED=$(printf '%s\n' "$TITLES" | fzf --filter "$QUERY" | head -1)

if [[ -z "$PICKED" ]]; then
    echo "No tab matched: $QUERY"
    exit 1
fi

# Escape backslashes and double-quotes for the AppleScript string literal.
ESCAPED="${PICKED//\\/\\\\}"
ESCAPED="${ESCAPED//\"/\\\"}"

/usr/bin/osascript <<APPLESCRIPT >/dev/null
tell application "Ghostty" to activate
tell application "System Events"
    tell process "Ghostty"
        click (first radio button of tab group "tab bar" of window 1 whose name is "$ESCAPED")
    end tell
end tell
APPLESCRIPT

echo "→ $PICKED"
