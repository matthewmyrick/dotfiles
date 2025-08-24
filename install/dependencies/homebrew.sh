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
fi