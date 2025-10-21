#!/bin/bash

echo "🐍 Installing Latest Python via Homebrew..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install the latest Python
echo "  📦 Installing python@3.13 (latest)..."
brew install python@3.13

# Update PATH and link
echo "  🔗 Setting up Python links..."
brew link --force python@3.13

# Verify installation
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ✅ Python installed successfully: $PYTHON_VERSION"
    echo "  📍 Location: $(which python3)"
else
    echo "  ❌ Python installation verification failed"
    exit 1
fi

echo "✓ Python installation completed!"