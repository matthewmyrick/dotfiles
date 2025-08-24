#!/bin/bash

echo "📦 Setting up Node.js environment..."

# Check Node.js version and upgrade if needed
if command -v node &>/dev/null; then
  NODE_VERSION=$(node --version | cut -d'v' -f2)
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'.' -f1)
  
  if [ "$NODE_MAJOR" -lt 20 ]; then
    echo "  ⚠️  Node.js version $NODE_VERSION is outdated (requires v20+)"
    echo "  📦 Upgrading Node.js..."
    brew upgrade node
    echo "  ✓ Node.js upgraded successfully"
  else
    echo "  ✓ Node.js version $NODE_VERSION is compatible"
  fi
else
  echo "  📦 Node.js not found, installing..."
  brew install node
  echo "  ✓ Node.js installed successfully"
fi

echo "✓ Node.js environment ready."