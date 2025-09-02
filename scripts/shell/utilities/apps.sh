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

# If script is run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apps "$@"
fi