#!/bin/bash

echo "🚀 Installing/Updating Git Tools"
echo "===================================================="
echo

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LAZYGIT_DIR="$DOTFILES_DIR/lazygit"
CRON_FILE="$LAZYGIT_DIR/cron.txt"

# ============================================================================
# STEP 1: Install/upgrade gh, git, lazygit via Homebrew
# ============================================================================

echo "📦 Installing/upgrading git tools via Homebrew..."
echo ""

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

for tool in gh git lazygit; do
    if brew list "$tool" &> /dev/null; then
        echo "   🔄 Upgrading $tool..."
        brew upgrade "$tool" 2>/dev/null || echo "   ✅ $tool is already up to date"
    else
        echo "   📥 Installing $tool..."
        brew install "$tool"
    fi
done

echo ""

# ============================================================================
# STEP 2: Symlink lazygit config
# ============================================================================

echo "🔗 Setting up lazygit configuration..."

LAZYGIT_CONFIG_DIR="$HOME/Library/Application Support/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR"

if [ -L "$LAZYGIT_CONFIG_DIR/config.yml" ]; then
    CURRENT_LINK=$(readlink "$LAZYGIT_CONFIG_DIR/config.yml")
    if [ "$CURRENT_LINK" = "$LAZYGIT_DIR/config.yml" ]; then
        echo "   ✅ Lazygit config already symlinked"
    else
        echo "   🔄 Updating lazygit config symlink..."
        rm "$LAZYGIT_CONFIG_DIR/config.yml"
        ln -sf "$LAZYGIT_DIR/config.yml" "$LAZYGIT_CONFIG_DIR/config.yml"
        echo "   ✅ Symlink updated"
    fi
elif [ -f "$LAZYGIT_CONFIG_DIR/config.yml" ]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv "$LAZYGIT_CONFIG_DIR/config.yml" "$LAZYGIT_CONFIG_DIR/config.yml.backup.$timestamp"
    echo "   📦 Backup saved to: config.yml.backup.$timestamp"
    ln -sf "$LAZYGIT_DIR/config.yml" "$LAZYGIT_CONFIG_DIR/config.yml"
    echo "   ✅ Symlink created"
else
    ln -sf "$LAZYGIT_DIR/config.yml" "$LAZYGIT_CONFIG_DIR/config.yml"
    echo "   ✅ Symlink created"
fi

echo ""

# ============================================================================
# STEP 3: Check gh auth
# ============================================================================

if ! gh auth status &> /dev/null; then
    echo "⚠️  GitHub CLI is not authenticated. Please run 'gh auth login' first."
    echo "   Skipping auto-fetch setup."
    exit 1
fi

# ============================================================================
# STEP 4: Interactive repo selection for auto-fetch
# ============================================================================

echo "🔄 Setting up auto-fetch for repositories..."
echo ""

# Show existing auto-fetch cron jobs
existing_entries=$(grep -v "^#" "$CRON_FILE" 2>/dev/null | grep -v "^$")
if [ -n "$existing_entries" ]; then
    echo "📋 Current auto-fetch repos:"
    echo "$existing_entries" | while IFS= read -r line; do
        path=$(echo "$line" | sed -n 's/.*git -C \(.*\) fetch.*/\1/p')
        interval=$(echo "$line" | sed -n 's/^\*\/\([0-9]*\) .*/\1/p')
        [ -n "$path" ] && echo "   - $path (every ${interval} min)"
    done
    echo ""
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "❌ fzf is required for interactive selection. Install with: brew install fzf"
    exit 1
fi

add_another=true
while $add_another; do
    echo "📂 Select an organization/user:"
    echo ""

    # Get local orgs from ~/GitHub
    local_orgs=""
    if [ -d "$HOME/GitHub" ]; then
        local_orgs=$(find "$HOME/GitHub" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)
    fi

    # Let user pick org (local first, with option to fetch from GitHub)
    if [ -n "$local_orgs" ]; then
        selected_org=$(
            {
                echo "$local_orgs"
                echo "--- Fetch from GitHub ---"
            } | fzf --prompt="Select an organization > " --height="40%" --border
        )

        if [[ "$selected_org" == "--- Fetch from GitHub ---" ]]; then
            echo "🔍 Fetching organizations from GitHub..."
            github_orgs=$(gh api user/orgs --jq '.[].login' 2>/dev/null | sort)
            current_user=$(gh api user --jq '.login' 2>/dev/null)
            all_orgs=$({ [ -n "$current_user" ] && echo "$current_user"; [ -n "$github_orgs" ] && echo "$github_orgs"; } | sort -u)

            if [ -z "$all_orgs" ]; then
                echo "❌ Failed to fetch organizations."
                break
            fi

            selected_org=$(echo "$all_orgs" | fzf --prompt="Select a GitHub organization > " --height="40%" --border)
        fi
    else
        echo "🔍 Fetching organizations from GitHub..."
        github_orgs=$(gh api user/orgs --jq '.[].login' 2>/dev/null | sort)
        current_user=$(gh api user --jq '.login' 2>/dev/null)
        all_orgs=$({ [ -n "$current_user" ] && echo "$current_user"; [ -n "$github_orgs" ] && echo "$github_orgs"; } | sort -u)

        if [ -z "$all_orgs" ]; then
            echo "❌ Failed to fetch organizations."
            break
        fi

        selected_org=$(echo "$all_orgs" | fzf --prompt="Select a GitHub organization > " --height="40%" --border)
    fi

    if [ -z "$selected_org" ]; then
        echo "❌ No organization selected."
        break
    fi

    echo "   Selected org: $selected_org"
    echo ""

    # Fetch repos for the selected org
    echo "🔍 Fetching repositories for '$selected_org'..."
    repo_list=$(gh repo list "$selected_org" --limit 1000 2>/dev/null)

    if [ -z "$repo_list" ]; then
        echo "❌ No repositories found for '$selected_org'."
        break
    fi

    selected_repo=$(echo "$repo_list" | fzf --prompt="Select a repository > " --height="50%" --border)

    if [ -z "$selected_repo" ]; then
        echo "❌ No repository selected."
        break
    fi

    # Extract repo name
    repo_full_name=$(echo "$selected_repo" | awk '{print $1}')
    repo_name=$(basename "$repo_full_name")
    repo_path="$HOME/GitHub/$selected_org/$repo_name"

    echo "   Selected repo: $selected_org/$repo_name"
    echo "   Local path: $repo_path"
    echo ""

    # Check if the repo exists locally
    if [ ! -d "$repo_path/.git" ]; then
        echo "⚠️  Repository not found locally at $repo_path"
        read -p "   Clone it now? (y/n) " -n 1 clone_reply
        echo ""
        if [[ $clone_reply =~ ^[Yy]$ ]]; then
            mkdir -p "$HOME/GitHub/$selected_org"
            gh repo clone "$selected_org/$repo_name" "$repo_path"
            if [ $? -ne 0 ]; then
                echo "❌ Failed to clone repository."
                continue
            fi
            echo "   ✅ Repository cloned"
        else
            echo "   Skipping this repo."
            continue
        fi
    fi

    # Select fetch interval
    echo "⏱️  Select auto-fetch interval:"
    selected_interval=$(printf "5 min\n15 min\n30 min" | fzf --prompt="Fetch interval > " --height="20%" --border)

    if [ -z "$selected_interval" ]; then
        echo "❌ No interval selected."
        break
    fi

    interval_min=$(echo "$selected_interval" | awk '{print $1}')
    echo "   Selected interval: every $interval_min minutes"
    echo ""

    # Build the cron entry
    cron_entry="*/$interval_min * * * * git -C $repo_path fetch origin 2>/dev/null"

    # Check if repo already exists in cron.txt
    existing_line=$(grep "git -C $repo_path fetch" "$CRON_FILE" 2>/dev/null)
    if [ -n "$existing_line" ]; then
        existing_interval=$(echo "$existing_line" | sed -n 's/^\*\/\([0-9]*\) .*/\1/p')
        if [ "$existing_interval" = "$interval_min" ]; then
            echo "   ✅ Auto-fetch already configured for $selected_org/$repo_name (every ${interval_min} min)"
        else
            # Update the interval - replace the old line
            sed -i '' "\|git -C $repo_path fetch|d" "$CRON_FILE"
            echo "$cron_entry" >> "$CRON_FILE"
            echo "   🔄 Updated auto-fetch for $selected_org/$repo_name: ${existing_interval} min → ${interval_min} min"
        fi
    else
        echo "$cron_entry" >> "$CRON_FILE"
        echo "   ✅ Added auto-fetch for $selected_org/$repo_name (every ${interval_min} min)"
    fi

    echo ""
    read -p "Add another repository? (y/n) " -n 1 another_reply
    echo ""
    if [[ ! $another_reply =~ ^[Yy]$ ]]; then
        add_another=false
    fi
    echo ""
done

# ============================================================================
# STEP 5: Install cron jobs
# ============================================================================

echo ""
echo "⏰ Installing cron jobs..."

# Read existing crontab (if any), remove our managed entries, then append new ones
existing_cron=$(crontab -l 2>/dev/null || true)

# Remove any previously managed git auto-fetch entries
cleaned_cron=$(echo "$existing_cron" | grep -v "# dotfiles-git-autofetch" | grep -v "^$" || true)

# Build new cron entries from cron.txt
new_entries=""
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    new_entries+="$line # dotfiles-git-autofetch"$'\n'
done < "$CRON_FILE"

if [ -n "$new_entries" ]; then
    # Combine existing + new
    {
        [ -n "$cleaned_cron" ] && echo "$cleaned_cron"
        echo "$new_entries"
    } | crontab -
    echo "   ✅ Cron jobs installed"
    echo ""
    echo "📋 Active auto-fetch repos:"
    grep -v "^#" "$CRON_FILE" | grep -v "^$" | while IFS= read -r line; do
        path=$(echo "$line" | sed -n 's/.*git -C \(.*\) fetch.*/\1/p')
        [ -n "$path" ] && echo "   - $path"
    done
else
    echo "   ℹ️  No repos configured for auto-fetch"
fi

echo ""
echo "✅ Git tools installation complete!"
echo ""
echo "📋 What was installed:"
echo "   - gh (GitHub CLI)"
echo "   - git"
echo "   - lazygit (with config symlinked)"
echo "   - Auto-fetch cron jobs (every 15 min)"
echo ""
echo "💡 Tips:"
echo "   - Run 'crontab -l' to see active cron jobs"
echo "   - Run 'install.sh --install git' again to add more repos"
echo "   - Edit lazygit/cron.txt to manually manage auto-fetch repos"
echo ""
