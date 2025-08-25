#!/bin/bash

echo "🧭 Setting up Zoxide (smart cd replacement)..."

# Verify zoxide is installed
if command -v zoxide &>/dev/null; then
  echo "  ✓ zoxide is already installed"
else
  echo "  ⚠️  zoxide not found - should be installed by brew-packages.sh"
fi

# Initialize zoxide in shell configs
echo "  Setting up zoxide integration in shell configs..."

# Check if already configured in .zshrc
if grep -q "eval.*zoxide init" ~/.zshrc 2>/dev/null; then
  echo "  ✓ zoxide already configured in .zshrc"
else
  echo "  Adding zoxide initialization to .zshrc..."
  echo "" >> ~/.zshrc
  echo "# Initialize zoxide (smart cd replacement)" >> ~/.zshrc
  echo 'eval "$(zoxide init --cmd cd zsh)"' >> ~/.zshrc
fi

# Check if already configured in .bashrc
if grep -q "eval.*zoxide init" ~/.bashrc 2>/dev/null; then
  echo "  ✓ zoxide already configured in .bashrc"
else
  echo "  Adding zoxide initialization to .bashrc..."
  echo "" >> ~/.bashrc
  echo "# Initialize zoxide (smart cd replacement)" >> ~/.bashrc
  echo 'eval "$(zoxide init --cmd cd bash)"' >> ~/.bashrc
fi

echo "✓ Zoxide configured successfully."
echo "  Usage:"
echo "    cd <dir>     # Works like normal cd, but also adds to zoxide database"
echo "    cd <query>   # Jump to directories matching query from anywhere"
echo "    zi           # Interactive directory picker"
echo "  Note: Restart your shell or run 'exec zsh' to activate zoxide"