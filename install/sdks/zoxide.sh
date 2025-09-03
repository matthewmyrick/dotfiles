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
  echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

# Check if already configured in .bashrc
if grep -q "eval.*zoxide init" ~/.bashrc 2>/dev/null; then
  echo "  ✓ zoxide already configured in .bashrc"
else
  echo "  Adding zoxide initialization to .bashrc..."
  echo "" >> ~/.bashrc
  echo "# Initialize zoxide (smart cd replacement)" >> ~/.bashrc
  echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
fi

# Also initialize zoxide in the current session if running in an interactive shell
if [[ $- == *i* ]] || [[ -n "$PS1" ]]; then
  echo "  Initializing zoxide in current shell session..."
  if [[ "$SHELL" == *"zsh"* ]] || [[ -n "$ZSH_VERSION" ]]; then
    eval "$(zoxide init zsh)"
    echo "  ✓ zoxide initialized for current zsh session"
  elif [[ "$SHELL" == *"bash"* ]] || [[ -n "$BASH_VERSION" ]]; then
    eval "$(zoxide init bash)"
    echo "  ✓ zoxide initialized for current bash session"
  fi
fi

echo "✓ Zoxide configured successfully."
echo "  Usage:"
echo "    z <dir>      # Jump to directories using zoxide"
echo "    z <query>    # Jump to directories matching query from anywhere"
echo "    zi           # Interactive directory picker"
echo "    cd <dir>     # Regular cd still works normally"
echo "  Note: Restart your shell or run 'exec zsh' to activate zoxide"