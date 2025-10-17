#!/bin/bash

echo "🐍 Setting up Python environment..."

# Check if pipx is available (preferred for macOS)
if ! command -v pipx &>/dev/null; then
  echo "  📦 Installing pipx for Python package management..."
  brew install pipx
  pipx ensurepath
fi

# Install essential Python packages for development
echo "  📦 Installing essential Python packages..."

# Install rich (Python formatter)
if python3 -c "import rich" 2>/dev/null; then
  echo "    ✓ rich is available"
else
  echo "    Installing rich..."
  # Try pipx first (preferred)
  if command -v pipx &>/dev/null; then
    pipx install rich-cli 2>/dev/null || true
  fi
fi

# Install pg_activity for PostgreSQL monitoring
echo "  📦 Installing pg_activity..."
if command -v pipx &>/dev/null; then
  pipx install "pg_activity[psycopg]" 2>/dev/null || {
    echo "    ⚠️  Could not install pg_activity with pipx"
    echo "    Try: pipx install 'pg_activity[psycopg]'"
  }
else
  python3 -m pip install --user --break-system-packages "pg_activity[psycopg]" 2>/dev/null || {
    echo "    ⚠️  Could not install pg_activity automatically"
    echo "    Try: python3 -m pip install --user --break-system-packages 'pg_activity[psycopg]'"
  }

  # If rich still not available, use pip with break-system-packages flag
  if ! python3 -c "import rich" 2>/dev/null; then
    python3 -m pip install --user --break-system-packages rich 2>/dev/null || {
      echo "    ⚠️  Could not install rich automatically"
      echo "    Try: python3 -m pip install --user --break-system-packages rich"
    }
  fi
fi

# Install pynvim (Neovim Python provider)
if python3 -c "import pynvim" 2>/dev/null; then
  echo "    ✓ pynvim is available"
else
  echo "    Installing pynvim for Neovim Python provider..."
  python3 -m pip install --user --break-system-packages pynvim 2>/dev/null || {
    echo "    ⚠️  Could not install pynvim automatically"
    echo "    Try: python3 -m pip install --user --break-system-packages pynvim"
  }
fi

# Add Python user bin directory to PATH if not already present
PYTHON_USER_BIN="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin"
if [[ ":$PATH:" != *":$PYTHON_USER_BIN:"* ]]; then
  echo "    Adding Python user bin directory to PATH..."
  echo "export PATH=\"$PYTHON_USER_BIN:\$PATH\"" >> ~/.zshrc
  export PATH="$PYTHON_USER_BIN:$PATH"
fi

# Verify pynvim installation with system Python
echo "  🔍 Verifying Neovim Python provider setup..."
if /opt/homebrew/bin/python3 -c "import pynvim" 2>/dev/null; then
  echo "    ✓ pynvim is available to system Python"
else
  echo "    Installing pynvim for system Python..."
  /opt/homebrew/bin/python3 -m pip install --break-system-packages pynvim 2>/dev/null || {
    echo "    ⚠️  Could not install pynvim for system Python"
    echo "    Try: /opt/homebrew/bin/python3 -m pip install --break-system-packages pynvim"
  }
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