#!/bin/bash

echo "🔧 Installing custom development tools..."

echo "  Installing Rust tools..."
cargo install --git https://github.com/MatthewMyrick/quill

echo "  Installing Go tools..."
go install github.com/MatthewMyrick/bluetooth-tui@latest
go install github.com/matthewmyrick/azure-searcher@latest

echo "✓ Custom development tools installed."