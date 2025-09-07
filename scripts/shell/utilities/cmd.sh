#!/usr/bin/env zsh
# Command Cache System
# Save and fuzzy find frequently used commands

# Lazy load guard
[[ -n "${_CMD_LOADED}" ]] && return
_CMD_LOADED=1

# Command cache directory
CMD_CACHE_DIR="$HOME/.config/cmds"

# Initialize cache directory
_cmd_init() {
    if [[ ! -d "$CMD_CACHE_DIR" ]]; then
        mkdir -p "$CMD_CACHE_DIR"
        echo "✅ Created command cache directory: $CMD_CACHE_DIR"
    fi
    
    # Create cache file if it doesn't exist
    if [[ ! -f "$CMD_CACHE_DIR/commands.txt" ]]; then
        touch "$CMD_CACHE_DIR/commands.txt"
    fi
}

# Main cmd function
cmd() {
    _cmd_init
    
    local subcommand="$1"
    
    case "$subcommand" in
        "add")
            if [[ -z "$2" ]]; then
                echo "Usage: cmd add \"<command>\""
                echo "Example: cmd add \"docker ps -a | grep myapp\""
                return 1
            fi
            
            # Get the full command (everything after 'add')
            local command_to_add="${*:2}"
            
            # Add timestamp and command to cache
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "$timestamp | $command_to_add" >> "$CMD_CACHE_DIR/commands.txt"
            
            echo "✅ Command saved: $command_to_add"
            ;;
            
        "list"|"ls")
            if [[ ! -s "$CMD_CACHE_DIR/commands.txt" ]]; then
                echo "No commands saved yet. Use 'cmd add \"<command>\"' to save commands."
                return 0
            fi
            
            echo "📋 Saved Commands:"
            echo "=================="
            cat -n "$CMD_CACHE_DIR/commands.txt" | sed 's/^[[:space:]]*//; s/[[:space:]]*|/ →/'
            ;;
            
        "clear")
            if [[ -f "$CMD_CACHE_DIR/commands.txt" ]]; then
                > "$CMD_CACHE_DIR/commands.txt"
                echo "✅ Command cache cleared"
            else
                echo "Command cache is already empty"
            fi
            ;;
            
        "edit")
            if [[ ! -f "$CMD_CACHE_DIR/commands.txt" ]]; then
                echo "No commands file found. Add some commands first."
                return 1
            fi
            
            # Open in default editor
            ${EDITOR:-vim} "$CMD_CACHE_DIR/commands.txt"
            ;;
            
        "help"|"-h"|"--help")
            echo "Command Cache System"
            echo "===================="
            echo ""
            echo "Usage:"
            echo "  cmd                    - Fuzzy find and execute saved commands"
            echo "  cmd add \"<command>\"    - Save a command to cache"
            echo "  cmd list              - List all saved commands"
            echo "  cmd clear             - Clear command cache"
            echo "  cmd edit              - Edit command cache file"
            echo "  cmd help              - Show this help"
            echo ""
            echo "Examples:"
            echo "  cmd add \"docker ps -a | grep myapp\""
            echo "  cmd add \"kubectl get pods -n production\""
            echo "  cmd add \"find . -name '*.js' -type f | head -20\""
            ;;
            
        "")
            # Default behavior: fuzzy find and execute
            if [[ ! -s "$CMD_CACHE_DIR/commands.txt" ]]; then
                echo "No commands saved yet. Use 'cmd add \"<command>\"' to save commands."
                echo "Example: cmd add \"docker ps -a\""
                return 0
            fi
            
            # Extract just the commands (everything after the timestamp and |)
            local selected_line=$(cat "$CMD_CACHE_DIR/commands.txt" | \
                fzf --height=60% \
                    --border=rounded \
                    --prompt="Select command> " \
                    --preview-window=bottom:3:wrap \
                    --preview='echo "Command: {}" | sed "s/.*| //" | fold -w 80' \
                    --header="Press ENTER to execute, ESC to cancel" \
                    --reverse)
                    
            if [[ -n "$selected_line" ]]; then
                # Extract just the command part (after timestamp and |)
                local command_to_execute=$(echo "$selected_line" | sed 's/.*| //')
                
                echo "🚀 Executing: $command_to_execute"
                echo ""
                
                # Execute the command
                eval "$command_to_execute"
            fi
            ;;
            
        *)
            echo "Unknown subcommand: $subcommand"
            echo "Run 'cmd help' for usage information"
            return 1
            ;;
    esac
}