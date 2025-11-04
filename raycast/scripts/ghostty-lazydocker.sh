
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Ghostty Lazydocker
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐳
# @raycast.alias docker
# @raycast.packageName GhosttyLazydocker

# Documentation:
# @raycast.description Opens Lazydocker in a ghostty terminal
# @raycast.author matthew_myrick
# @raycast.authorURL https://raycast.com/matthew_myrick

if ! command -v lazydocker &> /dev/null; then
    echo "lazydocker is not installed. Run: brew install lazydocker"
    exit 1
fi

if ! command -v ghostty &> /dev/null; then
    echo "ghostty is not installed"
    exit 1
fi

# Open a new Ghostty tab and run lazydocker
open -a Ghostty --args --new-tab -e lazydocker

echo "Opened Ghostty with lazydocker"
