#!/usr/bin/env zsh
# Command Discovery and Cache System
# Show all available commands or manage cached commands

# Lazy load guard
[[ -n "${_CMD_LOADED}" ]] && return
_CMD_LOADED=1

# Command cache directory
CMD_CACHE_DIR="$HOME/.config/cmds"
# Dotfiles directory
DOTFILES_DIR="$HOME/GitHub/matthewmyrick/dotfiles"

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

# Show all available commands with descriptions
_show_all_commands() {
    local temp_file=$(mktemp /tmp/all_commands.XXXXXX)

    echo "📚 Collecting all available commands..."
    echo ""

    # Header
    {
        echo "COMMAND|TYPE|DESCRIPTION"
        echo "-------|----|-----------"

        # Aliases from .aliases file
        if [[ -f "$DOTFILES_DIR/.aliases" ]]; then
            while IFS= read -r line; do
                # Skip comments and empty lines
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "$line" ]] && continue

                # Extract alias definitions
                if [[ "$line" =~ ^alias[[:space:]]+([^=]+)=\'([^\']+)\'$ ]] || [[ "$line" =~ ^alias[[:space:]]+([^=]+)=\"([^\"]+)\"$ ]]; then
                    local alias_name="${match[1]}"
                    local alias_value="${match[2]}"
                    echo "$alias_name|alias|$alias_value"
                fi
            done < "$DOTFILES_DIR/.aliases"
        fi

        # Shell functions from loaded modules
        echo ""
        echo "# Shell Functions"

        # Git functions
        command -v ghc >/dev/null && echo "ghc|function|GitHub clone - fuzzy search and clone repos"
        command -v ffgn >/dev/null && echo "ffgn|function|Find file in git repository by name"
        command -v fpr >/dev/null && echo "fpr|function|Fuzzy find and checkout pull requests"

        # Navigation functions
        command -v ff >/dev/null && echo "ff|function|Fuzzy file finder"
        command -v ffn >/dev/null && echo "ffn|function|Fuzzy file finder by name"
        command -v fft >/dev/null && echo "fft|function|Fuzzy file finder by type"
        command -v fftg >/dev/null && echo "fftg|function|Fuzzy file finder with tree view"
        command -v fch >/dev/null && echo "fch|function|Fuzzy change directory"
        command -v y >/dev/null && echo "y|function|Yazi file manager with directory tracking"

        # Utility functions
        command -v k_port >/dev/null && echo "k_port|function|Kill process by port number"
        command -v brewf >/dev/null && echo "brewf|function|Fuzzy search and install brew packages"
        command -v togglenetskope >/dev/null && echo "togglenetskope|function|Toggle Netskope VPN"
        command -v r_xml >/dev/null && echo "r_xml|function|Format and view XML files"
        command -v ttn >/dev/null && echo "ttn|function|Set terminal tab name"
        command -v tatn >/dev/null && echo "tatn|function|Auto set terminal tab name from directory"
        command -v apps >/dev/null && echo "apps|function|Fuzzy search and launch applications"
        command -v apps_close >/dev/null && echo "apps_close|function|Select and close running applications"

        # Network/API functions
        command -v curl_with_jqp >/dev/null && echo "curl_with_jqp|function|Curl with automatic JSON detection and jqp viewer"
        command -v curlv >/dev/null && echo "curlv|function|Curl with tshark network packet analysis"

        # Observability functions
        command -v ddsl >/dev/null && echo "ddsl|function|Datadog service logs viewer"
        command -v ddc >/dev/null && echo "ddc|function|Datadog clear configuration"

        # Cloud functions
        command -v azv >/dev/null && echo "azv|function|Azure Key Vault fuzzy finder"
        command -v apr >/dev/null && echo "apr|function|AWS private resource finder"

        # Pokemon functions
        command -v catch >/dev/null && echo "catch|function|Catch a Pokemon"
        command -v pokemon_status >/dev/null && echo "pokemon_status|function|View Pokemon collection status"
        command -v pokemon_help >/dev/null && echo "pokemon_help|function|Show Pokemon system help"

        # Profiling functions
        command -v zprofile_on >/dev/null && echo "zprofile_on|function|Enable zsh profiling"
        command -v zprofile_off >/dev/null && echo "zprofile_off|function|Disable zsh profiling"
        command -v pzprof >/dev/null && echo "pzprof|function|Pretty print zsh profiling results"

        # Module management
        command -v shell_modules >/dev/null && echo "shell_modules|function|List all available shell modules"
        command -v shell_loaded >/dev/null && echo "shell_loaded|function|Show loaded shell modules"
        command -v shell_reload >/dev/null && echo "shell_reload|function|Reload all shell modules"

        # Command cache (cmdl)
        echo "cmdl|function|Cached command manager (list/add/execute saved commands)"

    } > "$temp_file"

    # Use fzf to show the commands with descriptions
    cat "$temp_file" | column -t -s '|' | fzf \
        --height=90% \
        --border=rounded \
        --header="📋 All Available Commands (Press ESC to exit)" \
        --preview='echo {}' \
        --preview-window=hidden \
        --prompt="Search> " \
        --reverse \
        --no-select-1 \
        --bind 'enter:become(echo {1})'

    rm -f "$temp_file"
}

# Main cmd function - unified command discovery and cache
cmd() {
    local subcommand="$1"

    case "$subcommand" in
        "-c"|"--cache")
            # Access cached commands
            shift  # Remove the -c/--cache flag
            _cmd_cache "$@"
            ;;
        "-h"|"--help"|"help")
            echo "Command Discovery & Cache System"
            echo "================================="
            echo ""
            echo "Usage:"
            echo "  cmd                    - Browse all available commands (aliases & functions)"
            echo "  cmd -c, --cache        - Browse and execute cached commands"
            echo "  cmd -c add \"<cmd>\"     - Save a command to cache"
            echo "  cmd -c list            - List all cached commands"
            echo "  cmd -c edit            - Edit cached commands file"
            echo "  cmd -c clear           - Clear command cache"
            echo "  cmd -h, --help         - Show this help"
            echo ""
            echo "Examples:"
            echo "  cmd                                      # Browse all commands"
            echo "  cmd -c                                   # Execute a cached command"
            echo "  cmd -c add \"docker ps -a | grep myapp\"  # Save command"
            echo "  cmd -c list                              # List saved commands"
            ;;
        "")
            # Default: show all available commands
            _show_all_commands
            ;;
        *)
            echo "Unknown option: $subcommand"
            echo "Run 'cmd --help' for usage information"
            return 1
            ;;
    esac
}

# Handle cached commands
_cmd_cache() {
    _cmd_init

    local subcommand="$1"

    case "$subcommand" in
        "add")
            if [[ -z "$2" ]]; then
                echo "Usage: cmd -c add \"<command>\""
                echo "Example: cmd -c add \"docker ps -a | grep myapp\""
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
                echo "No commands saved yet. Use 'cmd -c add \"<command>\"' to save commands."
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
            echo "  cmd -c                 - Fuzzy find and execute saved commands"
            echo "  cmd -c add \"<command>\" - Save a command to cache"
            echo "  cmd -c list            - List all saved commands"
            echo "  cmd -c clear           - Clear command cache"
            echo "  cmd -c edit            - Edit command cache file"
            echo ""
            echo "Examples:"
            echo "  cmd -c add \"docker ps -a | grep myapp\""
            echo "  cmd -c add \"kubectl get pods -n production\""
            echo "  cmd -c add \"find . -name '*.js' -type f | head -20\""
            ;;

        "")
            # Default behavior: fuzzy find and execute cached commands
            if [[ ! -s "$CMD_CACHE_DIR/commands.txt" ]]; then
                echo "No commands saved yet. Use 'cmd -c add \"<command>\"' to save commands."
                echo "Example: cmd -c add \"docker ps -a\""
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
            echo "Run 'cmd -c help' for usage information"
            return 1
            ;;
    esac
}

# Keep cmdl as an alias for cmd -c for backwards compatibility
cmdl() {
    cmd -c "$@"
}