#!/bin/bash

echo "🐹 Installing Latest Go via Homebrew..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install Go
echo "  📦 Installing go..."
brew install go

# Verify installation
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo "  ✅ Go installed successfully: $GO_VERSION"
    echo "  📍 Location: $(which go)"
    echo "  🏠 GOPATH: $(go env GOPATH)"
    echo "  🏠 GOROOT: $(go env GOROOT)"
else
    echo "  ❌ Go installation verification failed"
    exit 1
fi

echo "✓ Go installation completed!"