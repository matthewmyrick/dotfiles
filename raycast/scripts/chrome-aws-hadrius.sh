
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Aws Chrome
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☁️
# @raycast.alias aws
# @raycast.packageName ChromeAws

# Documentation:
# @raycast.description Uses chrome-cli to focus or open a Aws tab.
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

aws_tab_id=$(OUTPUT_FORMAT=json chrome-cli list tabs | jq -r '.tabs[] | select(.url | contains("hadrius.awsapps.com")) | .id' | head -n 1)

if [ -n "$aws_tab_id" ]; then
    echo "Found an existing Aws Tab"
    chrome-cli activate -t "$aws_tab_id" --focus
else
    echo "No existing Aws Tabs, loading a new one"
    chrome-cli open "https://hadrius.awsapps.com/start/#/"
fi
