#!/bin/bash

echo "🔧 Installing custom development tools..."

echo "  Installing catch-pokemon..."
if command -v catch-pokemon &>/dev/null; then
  CURRENT_VERSION=$(catch-pokemon --version 2>/dev/null | awk '{print $2}')
  echo "    📦 catch-pokemon v$CURRENT_VERSION installed, updating..."
  catch-pokemon update
else
  echo "    Installing catch-pokemon via install script..."
  curl -sSL https://raw.githubusercontent.com/matthewmyrick/catch-pokemon/main/install.sh | bash
fi

echo "  Installing Go tools..."
go install github.com/MatthewMyrick/bluetooth-tui@latest
go install github.com/matthewmyrick/azure-searcher@latest

echo "  Installing Python tools via pipx..."
if command -v pipx &>/dev/null; then
  # Install or upgrade ptpython
  if pipx list | grep -q "ptpython"; then
    echo "    📦 ptpython already installed, checking for updates..."
    pipx upgrade ptpython 2>/dev/null || echo "    ✓ ptpython is up to date"
  else
    echo "    📦 Installing ptpython..."
    pipx install ptpython
  fi
else
  echo "    ⚠️  pipx not found, skipping Python tools"
fi

echo "✓ Custom development tools installed."
