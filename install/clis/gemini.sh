#!/bin/bash

echo "💎 Setting up Gemini CLI..."

# Install gemini if not installed and look for any updates needed
if ! command -v gemini &>/dev/null; then
  echo "  Installing gemini-cli..."
  npm install -g @google/gemini-cli
else
  echo "  gemini-cli is already installed, checking for updates..."
  npm update -g @google/gemini-cli || echo "    ✓ gemini-cli is up to date"
fi

echo "✓ Gemini CLI ready."