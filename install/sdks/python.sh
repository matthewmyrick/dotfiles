#!/bin/bash

echo "🐍 Setting up Python environment..."

# Check if pipx is available (preferred for macOS)
if ! command -v pipx &>/dev/null; then
  echo "  📦 Installing pipx for Python package management..."
  brew install pipx
  pipx ensurepath
fi

# Install rich using pipx or pip with break-system-packages
echo "  📦 Checking rich (Python formatter)..."

# Try to check if rich is available in PATH
if python3 -c "import rich" 2>/dev/null; then
  echo "    ✓ rich is available"
else
  echo "    Installing rich..."
  # Try pipx first (preferred)
  if command -v pipx &>/dev/null; then
    pipx install rich-cli 2>/dev/null || true
  fi

  # If rich still not available, use pip with break-system-packages flag
  if ! python3 -c "import rich" 2>/dev/null; then
    python3 -m pip install --user --break-system-packages rich 2>/dev/null || {
      echo "    ⚠️  Could not install rich automatically"
      echo "    Try: python3 -m pip install --user --break-system-packages rich"
    }
  fi
fi

# Setup Python virtual environment for Neovim
echo "  Setting up Python virtual environment for Neovim..."
if [ ! -d ~/.local/share/nvim/venv ]; then
  echo "    Creating new virtual environment..."
  python3 -m venv ~/.local/share/nvim/venv
else
  echo "    Virtual environment already exists."
fi

source ~/.local/share/nvim/venv/bin/activate

# Check if packages are installed and update/install them
if pip show xlrd pylightxl &>/dev/null; then
  echo "    Packages already installed. Updating to latest versions..."
  pip install --upgrade xlrd pylightxl
else
  echo "    Installing Python packages for Excel support..."
  pip install xlrd pylightxl
fi

echo "✓ Python environment configured."