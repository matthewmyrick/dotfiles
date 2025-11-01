#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Gemini Chrome
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.alias gemini
# @raycast.packageName BrowserGemini

# Documentation:
# @raycast.description Uses chrome-cli to focus or open a Gemini tab.
# @raycast.author matthew_myrick
# @raycast.authorURL https://raycast.com/matthew_myrick

# Check if chrome-cli is installed
if ! command -v chrome-cli &> /dev/null; then
    echo "chrome-cli is not installed. Run: brew install chrome-cli"
    exit 1
fi

# Find the first tab with "gemini.google.com" in the URL
# grep -m 1 stops after the first match
# gemini_tab_line=$(OUTPUT_FORMAT=json chrome-cli list tabs | jq -r ".tabs[].url")
gemini_tab_id=$(OUTPUT_FORMAT=json chrome-cli list tabs | jq -r '.tabs[] | select(.url | contains("gemini.google.com")) | .id' | head -n 1)

if [ -n "$gemini_tab_id" ]; then
    # FOUND: Activate the tab
    echo "found $gemini_tab_id"
    chrome-cli activate -t "$gemini_tab_id" --focus
else
    # NOT FOUND: Open a new tab
    echo "not found"
    chrome-cli open "https://gemini.google.com/"
fi
