#!/bin/bash

# apps-close - Select and close multiple running applications
# Usage: apps close

apps_close() {
    # Check if fzf is installed
    if ! command -v fzf >/dev/null 2>&1; then
        echo "❌ fzf is required for multi-select. Please install it first."
        echo "   brew install fzf"
        return 1
    fi

    # Get list of running applications using osascript
    local running_apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)' 2>/dev/null | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sort -u)

    if [[ -z "$running_apps" ]]; then
        echo "❌ No running applications found"
        return 1
    fi

    # Count running apps
    local app_count=$(echo "$running_apps" | wc -l | tr -d ' ')

    echo "🔍 Found $app_count running applications"
    echo ""

    # Use fzf for multi-select
    local selected_apps=$(echo "$running_apps" | fzf \
        --multi \
        --height=70% \
        --border=rounded \
        --header="🔴 Select apps to close (Tab to select multiple, Enter to confirm)" \
        --preview='echo "Will close: {}"' \
        --preview-window=up:1 \
        --prompt="Close ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --bind='ctrl-a:select-all' \
        --bind='ctrl-d:deselect-all' \
        --bind='ctrl-r:toggle-all' \
        --info=inline \
        --header-lines=0 \
        --tac)

    if [[ -z "$selected_apps" ]]; then
        echo "❌ No applications selected"
        return 0
    fi

    # Count selected apps
    local selected_count=$(echo "$selected_apps" | wc -l | tr -d ' ')

    echo ""
    echo "⚠️  About to close $selected_count application(s):"
    echo "$selected_apps" | sed 's/^/   • /'
    echo ""

    # Confirmation prompt
    read -p "Are you sure you want to close these apps? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        return 0
    fi

    # Close each selected application
    local failed_apps=""
    echo ""
    echo "$selected_apps" | while IFS= read -r app; do
        if [[ -n "$app" ]]; then
            echo -n "Closing $app..."
            if osascript -e "tell application \"$app\" to quit" 2>/dev/null; then
                echo " ✅"
            else
                echo " ❌ Failed"
                failed_apps+="$app"$'\n'
            fi
        fi
    done

    echo ""
    echo "✅ Done!"

    if [[ -n "$failed_apps" ]]; then
        echo ""
        echo "⚠️  Some apps may not have closed properly:"
        echo "$failed_apps" | sed 's/^/   • /' | grep -v '^   • $'
    fi
}

# Extension to the main apps function
apps_extended() {
    case "$1" in
        close)
            apps_close
            ;;
        *)
            # Fall back to original apps function if it exists
            if declare -f apps >/dev/null; then
                apps "$@"
            else
                echo "❌ Original apps function not found"
                echo "💡 Usage: apps close"
                return 1
            fi
            ;;
    esac
}

# If script is run directly, execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apps_close
fi