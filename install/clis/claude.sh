#!/bin/bash

echo "🤖 Setting up Claude CLI..."

# Install claude if not installed and look for any updates needed
if ! command -v claude &>/dev/null; then
  echo "  Installing claude-cli..."
  # Clean up any existing partial installations
  rm -rf /opt/homebrew/lib/node_modules/@anthropic-ai/.claude-code* 2>/dev/null || true
  npm install -g @anthropic-ai/claude-code
else
  echo "  claude-cli is already installed, checking for updates..."
  npm update -g @anthropic-ai/claude-code || {
    echo "    Update failed, attempting reinstall..."
    npm uninstall -g @anthropic-ai/claude-code
    rm -rf /opt/homebrew/lib/node_modules/@anthropic-ai/.claude-code* 2>/dev/null || true
    npm install -g @anthropic-ai/claude-code
  }
fi

echo "✓ Claude CLI ready."