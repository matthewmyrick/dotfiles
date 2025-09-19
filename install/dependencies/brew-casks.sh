#!/bin/bash

echo "📦 Installing Homebrew cask packages..."

CASK_PACKAGES=(
  ghostty
  karabiner-elements
  nikitabobko/tap/aerospace
)

# Install or upgrade each cask package
for package in "${CASK_PACKAGES[@]}"; do
  # Extract the actual package name (handle tap format like nikitabobko/tap/aerospace)
  package_name="${package##*/}"
  
  if brew list --cask | grep -q "^${package_name}$"; then
    echo "  📦 ${package} already installed, checking for updates..."
    brew upgrade --cask "$package" 2>/dev/null || echo "    ✓ ${package} is up to date"
  else
    echo "  📦 Installing ${package}..."
    brew install --cask "$package"
  fi
done

# Handle tap packages
echo "  📦 Installing tap packages..."

# taproom
brew tap gromgit/brewtils
brew install gromgit/brewtils/taproom

# jqp
if ! brew list --formula | grep -q "^jqp$"; then
  echo "    Installing jqp from tap..."
  brew install noahgorstein/tap/jqp
else
  echo "    ✓ jqp already installed"
fi

echo "✓ Homebrew cask packages ready."

# Start AeroSpace if it was just installed
if brew list --cask | grep -q "^aerospace$"; then
  echo "🚀 Starting AeroSpace window manager..."
  if ! pgrep -x "AeroSpace" > /dev/null; then
    open -a AeroSpace
    echo "✓ AeroSpace started"
  else
    echo "✓ AeroSpace is already running"
  fi
fi