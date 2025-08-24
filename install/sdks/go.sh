#!/bin/bash

echo "🐹 Setting up Go environment..."

# Fix Go linking if needed
if ! brew list go &>/dev/null; then
  echo "  Go not installed via Homebrew, skipping link fix."
else
  echo "  Ensuring Go is properly linked..."
  brew link --overwrite go 2>/dev/null || true
fi

echo "✓ Go environment ready."