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

if ! command -v chrome-cli &> /dev/null; then
    echo "chrome-cli is not installed. Run: brew install chrome-cli"
    exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Run: brew install jq"
  exit 1
fi

gemini_tab_id=$(OUTPUT_FORMAT=json chrome-cli list tabs | jq -r '.tabs[] | select(.url | contains("gemini.google.com")) | .id' | head -n 1)

if [ -n "$gemini_tab_id" ]; then
    echo "Found an existing Gemini Tab"
    chrome-cli activate -t "$gemini_tab_id" --focus
else
    echo "No existing Gemini Tabs, loading a new one"
    chrome-cli open "https://gemini.google.com/"
fi
