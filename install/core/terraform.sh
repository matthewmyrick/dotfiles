#!/bin/bash

echo "🏗️ Installing Terraform via Homebrew..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Install Terraform
echo "  📦 Installing terraform..."
brew install terraform

# Install Terraform docs (optional but useful)
echo "  📦 Installing terraform-docs..."
brew install terraform-docs

# Install tflint for linting (optional but recommended)
echo "  📦 Installing tflint..."
brew install tflint

# Verify installation
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version | head -n1)
    echo "  ✅ Terraform installed successfully: $TERRAFORM_VERSION"
    echo "  📍 Location: $(which terraform)"
    
    # Check optional tools
    if command -v terraform-docs &> /dev/null; then
        echo "  ✅ terraform-docs: $(terraform-docs version)"
    fi
    
    if command -v tflint &> /dev/null; then
        echo "  ✅ tflint: $(tflint --version)"
    fi
else
    echo "  ❌ Terraform installation verification failed"
    exit 1
fi

echo "✓ Terraform installation completed!"