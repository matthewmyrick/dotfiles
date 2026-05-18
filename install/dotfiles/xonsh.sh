#!/bin/bash

echo "🚀 Installing/Updating xonsh shell configuration"
echo "================================================"
echo

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
XONSH_DIR="$DOTFILES_DIR/xonsh"
RC_SRC="$XONSH_DIR/xonshrc"
RC_DEST="$HOME/.xonshrc"

# Check the source file exists
if [ ! -f "$RC_SRC" ]; then
    echo "❌ xonshrc not found at: $RC_SRC"
    exit 1
fi

# 1. Install xonsh via brew if missing
if ! command -v xonsh &> /dev/null; then
    echo "📦 xonsh not found — installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is required but not installed."
        exit 1
    fi
    brew install xonsh || {
        echo "❌ Failed to install xonsh via brew"
        exit 1
    }
    echo "✅ xonsh installed"
else
    echo "✅ xonsh already installed ($(xonsh --version))"
fi

# 2. Locate xonsh's bundled Python so xontribs/libs land in the right env
XONSH_PYTHON="$(brew --prefix xonsh 2>/dev/null)/libexec/bin/python"
if [ ! -x "$XONSH_PYTHON" ]; then
    # Fallback to system python3
    XONSH_PYTHON="$(command -v python3)"
    echo "⚠️  Could not find xonsh's bundled Python — falling back to: $XONSH_PYTHON"
else
    echo "🐍 xonsh Python: $XONSH_PYTHON"
fi

# 3. Install Python lib bundle (data, web, niceties)
echo ""
echo "📦 Installing Python library bundle..."
"$XONSH_PYTHON" -m pip install --quiet --upgrade \
    pandas polars duckdb \
    openpyxl xlsxwriter \
    requests httpx beautifulsoup4 lxml \
    rich typer ipython \
    python-dotenv pyyaml tqdm || {
    echo "⚠️  Warning: some Python libs failed to install"
}
echo "✅ Python libs installed"

# 4. Install xontribs (completion, fuzzy finding, prompt, command durations)
echo ""
echo "📦 Installing xontribs..."
"$XONSH_PYTHON" -m pip install --quiet --upgrade \
    xontrib-jedi \
    xontrib-fzf-widgets \
    xontrib-abbrevs \
    xontrib-cmd-durations \
    xontrib-readable-traceback \
    xontrib-argcomplete \
    xontrib-zoxide || {
    echo "⚠️  Warning: some xontribs failed to install"
}
echo "✅ xontribs installed"

# 5. Symlink ~/.xonshrc -> dotfiles/xonsh/xonshrc
echo ""
echo "🔗 Linking ~/.xonshrc..."
if [ -L "$RC_DEST" ]; then
    CURRENT_LINK=$(readlink "$RC_DEST")
    if [ "$CURRENT_LINK" = "$RC_SRC" ]; then
        echo "✅ ~/.xonshrc is already properly linked"
    else
        echo "🔄 Updating ~/.xonshrc symlink (was -> $CURRENT_LINK)"
        rm "$RC_DEST"
        ln -s "$RC_SRC" "$RC_DEST"
        echo "✅ Linked: ~/.xonshrc -> $RC_SRC"
    fi
elif [ -f "$RC_DEST" ]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$RC_DEST" "$RC_DEST.backup.$timestamp"
    echo "   📦 Backup of existing ~/.xonshrc saved to: ~/.xonshrc.backup.$timestamp"
    ln -s "$RC_SRC" "$RC_DEST"
    echo "✅ Linked: ~/.xonshrc -> $RC_SRC"
else
    ln -s "$RC_SRC" "$RC_DEST"
    echo "✅ Linked: ~/.xonshrc -> $RC_SRC"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Launch xonsh:  xonsh"
echo "   2. Type 'xhelp' for a reference card of aliases, AI helpers, and Python libs"
echo "   3. To make xonsh your default shell:"
echo "        sudo sh -c \"echo \$(which xonsh) >> /etc/shells\""
echo "        chsh -s \$(which xonsh)"
echo ""
