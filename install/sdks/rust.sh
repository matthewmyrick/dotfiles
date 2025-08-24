#!/bin/bash

echo "🦀 Setting up Rust environment..."

# Install rust-analyzer for Rust LSP support in Neovim
if command -v rustup &>/dev/null; then
  rustup component add rust-analyzer
  echo "  ✓ rust-analyzer installed successfully"
else
  echo "  ⚠️  rustup not found. Please install Rust toolchain first."
fi

echo "✓ Rust environment ready."