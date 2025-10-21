#!/bin/bash

# apps - Fuzzy search and launch applications
# Usage: apps [search_term]

apps() {
    local search_term="$1"
    local app_dirs=(
        "/Applications"
        "/System/Applications" 
        "/System/Applications/Utilities"
        "$HOME/Applications"
        "/Applications/Utilities"
    )
    
    # Get all .app bundles from common directories
    local apps_list=""
    for dir in "${app_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            apps_list+=$(find "$dir" -maxdepth 2 -name "*.app" -type d 2>/dev/null | sed 's|.*/||; s|\.app$||' | sort -u)$'\n'
        fi
    done
    
    # Remove duplicates and empty lines
    apps_list=$(echo "$apps_list" | sort -u | grep -v '^$')
    
    if [[ -z "$apps_list" ]]; then
        echo "❌ No applications found"
        return 1
    fi
    
    local selected_app
    
    if [[ -n "$search_term" ]]; then
        # If search term provided, try exact or partial match
        selected_app=$(echo "$apps_list" | grep -i "$search_term" | head -1)
        if [[ -z "$selected_app" ]]; then
            echo "❌ No app found matching '$search_term'"
            echo "💡 Available apps matching pattern:"
            echo "$apps_list" | grep -i "$search_term" | head -5
            return 1
        fi
    else
        # Use fzf for interactive selection
        if command -v fzf >/dev/null 2>&1; then
            selected_app=$(echo "$apps_list" | fzf \
                --height=50% \
                --border=rounded \
                --header="🚀 Select an application to launch" \
                --preview='echo "Launch: {}"' \
                --preview-window=up:1 \
                --prompt="App ❯ " \
                --pointer="▶" \
                --marker="✓")
        else
            echo "📱 Available applications:"
            echo "$apps_list" | nl
            echo ""
            read -p "Enter app number or name: " input
            
            if [[ "$input" =~ ^[0-9]+$ ]]; then
                selected_app=$(echo "$apps_list" | sed -n "${input}p")
            else
                selected_app=$(echo "$apps_list" | grep -i "$input" | head -1)
            fi
        fi
    fi
    
    if [[ -z "$selected_app" ]]; then
        echo "❌ No application selected"
        return 1
    fi
    
    echo "🚀 Launching $selected_app..."
    
    # Try to open the app
    if open -a "$selected_app" 2>/dev/null; then
        echo "✅ Successfully launched $selected_app"
    else
        echo "❌ Failed to launch $selected_app"
        return 1
    fi
}

# Source the apps-close functionality if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/apps-close.sh" ]]; then
    source "$SCRIPT_DIR/apps-close.sh"
fi

# Extended apps function with subcommands
apps_main() {
    case "$1" in
        close)
            if declare -f apps_close >/dev/null; then
                apps_close
            else
                echo "❌ apps close command not available"
                return 1
            fi
            ;;
        help|--help|-h)
            echo "📱 apps - Application launcher and manager"
            echo ""
            echo "Usage:"
            echo "  apps              - Interactive app launcher with fuzzy search"
            echo "  apps [name]       - Launch app by name"
            echo "  apps close        - Select and close multiple running apps"
            echo "  apps help         - Show this help message"
            echo ""
            echo "Shortcuts in 'apps close':"
            echo "  Tab              - Select/deselect an app"
            echo "  Ctrl+A           - Select all"
            echo "  Ctrl+D           - Deselect all"
            echo "  Ctrl+R           - Toggle all"
            echo "  Enter            - Confirm selection"
            ;;
        *)
            # Default behavior - launch apps
            apps "$@"
            ;;
    esac
}

# If script is run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apps_main "$@"
else
    # When sourced, make apps_main available as 'apps'
    # Remove any existing apps alias first to avoid conflicts
    unalias apps 2>/dev/null || true
    alias apps=apps_main
fi
