#!/bin/bash

echo "📦 Installing Homebrew packages..."

# Add taps for special packages
echo "🔗 Adding Homebrew taps..."
brew tap xo/xo

# List of required packages
BREW_PACKAGES=(
  git eza fd fzf zoxide
  zsh-autosuggestions zsh-syntax-highlighting
  bat kubectx k9s neovim
  blueutil xmlstarlet golangci-lint
  jq ripgrep gh lazygit lazydocker
  btop lnav ripgrep nvm libpq
  go node pipx task bandwhich htop watch
  grc nmap iproute2mac hyperfine gdu dua-cli
  xplr shpotify wireshark imagemagick otree
  xo/xo/usql chrome-cli terminal-notifier
  lazysql
)



# Install or upgrade each package
for package in "${BREW_PACKAGES[@]}"; do
  if brew list --formula | grep -q "^${package}$"; then
    echo "  📦 ${package} already installed, checking for updates..."
    brew upgrade "$package" 2>/dev/null || echo "    ✓ ${package} is up to date"
  else
    echo "  📦 Installing ${package}..."
    brew install "$package"
  fi
done

brew link --force libpq

echo "✓ Homebrew packages ready."
