#!/bin/bash

echo "🌩️  Installing AWS CLI and tools..."

# Check if AWS CLI is already installed
if command -v aws >/dev/null 2>&1; then
    echo "✅ AWS CLI is already installed"
    aws --version
else
    echo "📦 Installing AWS CLI via Homebrew..."
    
    if command -v brew >/dev/null 2>&1; then
        brew install awscli
        echo "✅ AWS CLI installed successfully"
    else
        echo "❌ Homebrew not found. Please install Homebrew first."
        exit 1
    fi
fi

# Install additional AWS tools
echo "📦 Installing additional AWS tools..."

# Install AWS Session Manager plugin
if ! aws ssm describe-instance-information >/dev/null 2>&1 || ! command -v session-manager-plugin >/dev/null 2>&1; then
    echo "📦 Installing AWS Session Manager plugin..."
    brew install --cask session-manager-plugin
fi

# Install AWS SAM CLI (for serverless applications)
if ! command -v sam >/dev/null 2>&1; then
    echo "📦 Installing AWS SAM CLI..."
    brew install aws-sam-cli
fi

# Install eksctl for EKS management
if ! command -v eksctl >/dev/null 2>&1; then
    echo "📦 Installing eksctl..."
    brew install eksctl
fi

echo ""
echo "🎉 AWS tools installation completed!"
echo ""
echo "📋 Next Steps:"
echo "  1. Configure AWS credentials:"
echo "     aws configure"
echo "  2. Or use AWS SSO:"
echo "     aws configure sso"
echo "  3. Test the installation:"
echo "     aws sts get-caller-identity"
echo "  4. Use the new 'apr' command for AWS Private Resource discovery!"
echo ""
echo "💡 Available AWS commands:"
echo "  apr        - AWS Private Resource finder (interactive discovery)"
echo "  aws        - AWS CLI"
echo "  sam        - AWS SAM CLI"
echo "  eksctl     - EKS cluster management"
echo ""