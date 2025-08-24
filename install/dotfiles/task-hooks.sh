#!/bin/bash

echo "📋 Setting up task hooks..."

# Get the directory where the main install script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Remove old hooks
rm -rf ~/.task/hooks

# Setup task hooks
if [ -d "$DOTFILES_DIR/task/hooks" ]; then
  echo "  Setting up task hooks..."
  mkdir -p ~/.task/hooks

  # Copy all hook scripts from task/hooks to ~/.task/hooks
  for hook in "$DOTFILES_DIR"/task/hooks/*.sh; do
    if [ -f "$hook" ]; then
      hook_name=$(basename "$hook" .sh)
      echo "    Installing hook: $hook_name"
      cp "$hook" ~/.task/hooks/"$hook_name"
      chmod +x ~/.task/hooks/"$hook_name"
    fi
  done

  echo "  ✓ Task hooks installed successfully"
else
  echo "  ⚠️  No task hooks found to install"
fi