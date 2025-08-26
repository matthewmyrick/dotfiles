#!/bin/bash

echo "📦 Setting up Node.js environment..."

# Function to compare version numbers
version_compare() {
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

# Check if Node.js is installed
if command -v node &>/dev/null; then
  CURRENT_VERSION=$(node --version | cut -d'v' -f2)
  echo "  📋 Current Node.js version: v$CURRENT_VERSION"
  
  # Get the latest version available via brew
  echo "  🔍 Checking for latest version..."
  LATEST_VERSION=$(brew info node --json | grep -o '"versions":{[^}]*}' | grep -o '"stable":"[^"]*"' | cut -d'"' -f4)
  
  if [ -n "$LATEST_VERSION" ]; then
    echo "  📋 Latest available version: v$LATEST_VERSION"
    
    version_compare "$CURRENT_VERSION" "$LATEST_VERSION"
    case $? in
      0) echo "  ✅ Node.js is up to date (v$CURRENT_VERSION)" ;;
      2) 
        echo "  🚀 Upgrading Node.js from v$CURRENT_VERSION to v$LATEST_VERSION..."
        brew upgrade node
        if [ $? -eq 0 ]; then
          NEW_VERSION=$(node --version | cut -d'v' -f2)
          echo "  ✅ Node.js upgraded successfully to v$NEW_VERSION"
        else
          echo "  ❌ Failed to upgrade Node.js"
        fi
        ;;
      1) echo "  ⚠️  Current version (v$CURRENT_VERSION) is newer than available (v$LATEST_VERSION)" ;;
    esac
  else
    echo "  ⚠️  Could not determine latest version, skipping upgrade check"
    echo "  ✅ Node.js v$CURRENT_VERSION is installed"
  fi
else
  echo "  📦 Node.js not found, installing latest version..."
  brew install node
  if [ $? -eq 0 ]; then
    NEW_VERSION=$(node --version | cut -d'v' -f2 2>/dev/null || echo "unknown")
    echo "  ✅ Node.js v$NEW_VERSION installed successfully"
  else
    echo "  ❌ Failed to install Node.js"
  fi
fi

# Verify npm is working
if command -v npm &>/dev/null; then
  NPM_VERSION=$(npm --version)
  echo "  ✅ npm v$NPM_VERSION is ready"
else
  echo "  ⚠️  npm not found after Node.js installation"
fi

echo "✅ Node.js environment setup complete."