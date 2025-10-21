#!/bin/bash

# Install Homebrew if it's not already installed
echo "📦 Setting up Homebrew..."

if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for the current session
  if [ -f "/opt/homebrew/bin/brew" ]; then # For Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then # For Intel Macs
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "  ✓ Homebrew installed successfully!"
else
  echo "  ✓ Homebrew is already installed."
  
  # Check for updates
  echo "  📦 Checking for Homebrew updates..."
  brew update
  
  # Check if Homebrew itself needs upgrading
  if brew outdated --formula | grep -q "homebrew"; then
    echo "  📦 Upgrading Homebrew..."
    brew upgrade homebrew
  else
    echo "  ✓ Homebrew is up to date."
  fi
fi

echo "✓ Homebrew setup completed!"