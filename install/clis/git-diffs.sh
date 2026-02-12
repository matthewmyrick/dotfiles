#!/bin/bash

# Install git-diffs CLI tool
# https://github.com/matthewmyrick/git-diffs

echo "  Installing git-diffs..."

# Check if Go is available
if ! command -v go &> /dev/null; then
    echo "  ⚠️  Go is not installed. Please install Go first."
    exit 1
fi

# Ensure GOPATH/bin is set up
GOPATH_BIN="$(go env GOPATH)/bin"

# Install git-diffs
go install github.com/matthewmyrick/git-diffs@latest

if [ $? -eq 0 ]; then
    echo "  ✅ git-diffs installed successfully"

    # Check if GOPATH/bin is in PATH
    if [[ ":$PATH:" != *":$GOPATH_BIN:"* ]]; then
        echo "  ℹ️  Make sure $GOPATH_BIN is in your PATH"
        echo "     Add to ~/.zshrc: export PATH=\"\$PATH:\$(go env GOPATH)/bin\""
    fi
else
    echo "  ❌ Failed to install git-diffs"
    exit 1
fi
