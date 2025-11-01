#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Gmail Chrome
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📧
# @raycast.alias gmail
# @raycast.packageName ChromeGmail

# Documentation:
# @raycast.description Uses chrome-cli to focus or open a Gmail tab.
# @raycast.author matthew_myrick
# @raycast.authorURL https://raycast.com/matthew_myrick

# Check for chrome-cli
if ! command -v chrome-cli &> /dev/null; then
    echo "chrome-cli is not installed. Run: brew install chrome-cli"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Run: brew install jq"
  exit 1
fi

# Find the first tab URL that contains "mail.google.com"
gmail_tab_id=$(OUTPUT_FORMAT=json chrome-cli list tabs | jq -r '.tabs[] | select(.url | contains("mail.google.com")) | .id' | head -n 1)

if [ -n "$gmail_tab_id" ]; then
    echo "Found an existing Gmail Tab"
    chrome-cli activate -t "$gmail_tab_id" --focus
else
    echo "No existing Gmail Tabs, loading a new one"
    chrome-cli open "https://mail.google.com/"
fi
