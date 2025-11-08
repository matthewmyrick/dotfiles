#!/bin/bash

echo "🔧 Installing custom development tools..."

echo "  Installing Rust tools..."
if command -v catch-pokemon &>/dev/null; then
  # Get current installed version
  CURRENT_VERSION=$(catch-pokemon --version 2>/dev/null | awk '{print $2}')

  # Get latest version from GitHub (check latest release or main branch commit)
  LATEST_VERSION=$(curl -s https://api.github.com/repos/matthewmyrick/catch-pokemon/releases/latest 2>/dev/null | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/v//')

  # If no releases, fall back to checking commits or just reinstall
  if [[ -z "$LATEST_VERSION" ]]; then
    echo "    ⚠️  Could not fetch latest version from GitHub, checking commit hash..."
    # Could also check commit hash or just skip version check
    LATEST_VERSION="unknown"
  fi

  if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" && "$LATEST_VERSION" != "unknown" ]]; then
    echo "    📦 Updating catch-pokemon from v$CURRENT_VERSION to v$LATEST_VERSION..."
    cargo install --git https://github.com/matthewmyrick/catch-pokemon
  else
    echo "    ✓ catch-pokemon v$CURRENT_VERSION already installed and up to date"
  fi
else
  echo "    Installing catch-pokemon..."
  cargo install --git https://github.com/matthewmyrick/catch-pokemon
fi

echo "  Installing Go tools..."
go install github.com/MatthewMyrick/bluetooth-tui@latest
go install github.com/matthewmyrick/azure-searcher@latest

echo "✓ Custom development tools installed."