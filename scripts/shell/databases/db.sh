#!/usr/bin/env zsh
# Database Functions
# Enhanced usql wrapper with connection management

# Lazy load guard
[[ -n "${_DATABASE_LOADED}" ]] && return
_DATABASE_LOADED=1

# Ensure jq is available (prefer Homebrew, fallback to Mason)
if ! command -v jq >/dev/null 2>&1; then
    export PATH="$PATH:$HOME/.local/share/nvim/mason/bin"
fi

DB_CONFIG_FILE="$HOME/.db_connections.json"

# Initialize config file if it doesn't exist
init_config() {
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        cat > "$DB_CONFIG_FILE" << 'EOF'
{
  "connections": {
    "local_postgres": {
      "url": "postgres://localhost/postgres",
      "description": "Local PostgreSQL default database"
    },
    "local_sqlite": {
      "url": "sqlite:///tmp/test.db",
      "description": "Local SQLite test database"
    }
  }
}
EOF
        echo "📄 Created config file at $DB_CONFIG_FILE"
    fi
}

# Parse JSON file to get connection info
get_connection() {
    local name="$1"
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        echo "❌ Config file not found. Run 'db init' first."
        return 1
    fi
    
    # Use jq to extract the URL for the given connection name
    local url=$(jq -r ".connections.\"$name\".url // empty" "$DB_CONFIG_FILE" 2>/dev/null)
    
    if [[ -n "$url" && "$url" != "null" ]]; then
        echo "$url"
        return 0
    fi
    
    return 1
}

# List all connections
list_connections() {
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        echo "❌ Config file not found. Run 'db init' first."
        return 1
    fi
    
    echo "📋 Available database connections:"
    echo ""
    
    # Use jq to parse and format connections
    local connections=$(jq -r '.connections | keys[]' "$DB_CONFIG_FILE" 2>/dev/null)
    
    if [[ -z "$connections" ]]; then
        echo "  No connections found."
        return
    fi
    
    echo "$connections" | while read -r name; do
        local url=$(jq -r ".connections.\"$name\".url" "$DB_CONFIG_FILE")
        local description=$(jq -r ".connections.\"$name\".description // empty" "$DB_CONFIG_FILE")
        
        printf "  %s\n" "$name"
        printf "    URL: %s\n" "$url"
        [[ -n "$description" && "$description" != "null" ]] && printf "    Description: %s\n" "$description"
        echo ""
    done
}

# Get list of connection names for fuzzy finder
get_connection_names() {
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        return 1
    fi
    
    jq -r '.connections | keys[]' "$DB_CONFIG_FILE" 2>/dev/null
}

# Helper function for fzf preview
_db_preview() {
    local conn_name="$1"
    echo "Connection: $conn_name"
    echo "URL: $(jq -r ".connections.\"$conn_name\".url // \"Not found\"" "$DB_CONFIG_FILE")"
}

# Get formatted list for fuzzy finder (name + description)
get_connections_for_fzf() {
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        return 1
    fi
    
    local connections=$(jq -r '.connections | keys[]' "$DB_CONFIG_FILE" 2>/dev/null)
    
    echo "$connections" | while read -r name; do
        local description=$(jq -r ".connections.\"$name\".description // empty" "$DB_CONFIG_FILE")
        
        if [[ -n "$description" && "$description" != "null" ]]; then
            printf "%s | %s\n" "$name" "$description"
        else
            printf "%s\n" "$name"
        fi
    done
}

# URL encode special characters in passwords
url_encode_password() {
    local url="$1"
    
    # Extract password part (between : and @)
    if [[ "$url" =~ ://[^:]+:([^@]+)@ ]]; then
        local password="${BASH_REMATCH[1]}"
        local encoded_password="$password"
        
        # Replace common special characters that break URLs
        encoded_password="${encoded_password//#/%23}"    # hash
        encoded_password="${encoded_password//@/%40}"    # at symbol
        encoded_password="${encoded_password//&/%26}"    # ampersand
        encoded_password="${encoded_password//\?/%3F}"   # question mark
        encoded_password="${encoded_password// /%20}"    # space
        
        # Replace the password in the original URL
        url="${url//:$password@/:$encoded_password@}"
    fi
    
    echo "$url"
}

# Save a new connection
save_connection() {
    local name="$1"
    local url="$2"
    local description="$3"
    
    if [[ -z "$name" || -z "$url" ]]; then
        echo "❌ Usage: db save <name> <connection_string> [description]"
        return 1
    fi
    
    # Auto-encode special characters in the URL
    url=$(url_encode_password "$url")
    
    init_config
    
    # Check if connection already exists
    if get_connection "$name" >/dev/null 2>&1; then
        echo "⚠️  Connection '$name' already exists. Overwriting..."
    fi
    
    # Create the new connection object
    local conn_obj="{\"url\": \"$url\""
    if [[ -n "$description" ]]; then
        conn_obj+=", \"description\": \"$description\""
    fi
    conn_obj+="}"
    
    # Use jq to add/update the connection
    local temp_file=$(mktemp)
    jq ".connections.\"$name\" = $conn_obj" "$DB_CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$DB_CONFIG_FILE"
    
    echo "✅ Saved connection '$name'"
}

# Remove a connection
remove_connection() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        echo "❌ Usage: db remove <name>"
        return 1
    fi
    
    if [[ ! -f "$DB_CONFIG_FILE" ]]; then
        echo "❌ Config file not found."
        return 1
    fi
    
    # Use jq to remove the connection
    local temp_file=$(mktemp)
    jq "del(.connections.\"$name\")" "$DB_CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$DB_CONFIG_FILE"
    
    echo "✅ Removed connection '$name'"
}

# Main function
db() {
    case "$1" in
        init)
            init_config
            ;;
        save)
            save_connection "$2" "$3" "$4"
            ;;
        list|ls)
            list_connections
            ;;
        connect|c)
            # Interactive fuzzy finder for connections
            init_config
            
            local connections
            connections=$(get_connections_for_fzf)
            
            if [[ -z "$connections" ]]; then
                echo "❌ No connections found. Add some with 'db save <name> <url>'"
                return 1
            fi
            
            local selected_line
            if command -v fzf >/dev/null 2>&1; then
                selected_line=$(echo "$connections" | fzf \
                    --height=50% \
                    --border=rounded \
                    --header="🗄️  Select a database connection" \
                    --delimiter=' | ' \
                    --preview='echo "Connection: {1}" && echo "URL:" && jq -r ".connections.\"{1}\".url" "$HOME/.db_connections.json"' \
                    --preview-window=up:3 \
                    --prompt="DB ❯ " \
                    --pointer="▶" \
                    --marker="✓")
            else
                echo "🗄️  Available connections:"
                echo "$connections" | nl
                echo ""
                read -p "Enter connection number: " input
                
                if [[ "$input" =~ ^[0-9]+$ ]]; then
                    selected_line=$(echo "$connections" | sed -n "${input}p")
                fi
            fi
            
            if [[ -z "$selected_line" ]]; then
                echo "❌ No connection selected"
                return 1
            fi
            
            # Extract connection name (everything before the first " | ")
            local selected_connection="${selected_line%% |*}"
            
            local connection_url
            connection_url=$(get_connection "$selected_connection")
            
            if [[ -z "$connection_url" ]]; then
                echo "❌ Connection '$selected_connection' not found"
                return 1
            fi
            
            echo "🚀 Connecting to $selected_connection..."
            usql "$connection_url"
            ;;
        remove|rm)
            remove_connection "$2"
            ;;
        edit)
            local editor="${EDITOR:-vim}"
            if command -v "$editor" >/dev/null; then
                "$editor" "$DB_CONFIG_FILE"
            else
                echo "❌ No editor found. Set \$EDITOR environment variable or install vim."
                echo "💡 Available editors:"
                for ed in nano vim vi code; do
                    command -v "$ed" >/dev/null && echo "  - $ed"
                done
            fi
            ;;
        help|--help|-h)
            echo "🗄️  db - Enhanced usql wrapper with connection management"
            echo ""
            echo "Usage:"
            echo "  db                    - Interactive connection selector"
            echo "  db connect            - Interactive fuzzy finder (shows name + description)"
            echo "  db <name>             - Connect to saved connection by name"
            echo "  db save <name> <url>  - Save a new connection"
            echo "  db list               - List all saved connections"
            echo "  db remove <name>      - Remove a saved connection"
            echo "  db edit               - Edit connections config file"
            echo "  db help               - Show this help"
            echo ""
            echo "Connection string examples:"
            echo "  postgres://user:pass@localhost:5432/dbname"
            echo "  mysql://user:pass@localhost:3306/dbname"
            echo "  sqlite:///path/to/database.db"
            echo "  sqlserver://user:pass@localhost/dbname"
            echo ""
            echo "Config file: $DB_CONFIG_FILE"
            ;;
        "")
            # Default behavior - use the enhanced fuzzy finder
            db connect
            ;;
        *)
            # Direct connection by name
            init_config
            
            local connection_url
            connection_url=$(get_connection "$1")
            
            if [[ -z "$connection_url" ]]; then
                echo "❌ Connection '$1' not found"
                echo "💡 Available connections:"
                get_connection_names | sed 's/^/  /'
                return 1
            fi
            
            echo "🚀 Connecting to $1..."
            usql "$connection_url"
            ;;
    esac
}

# If script is run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    db "$@"
fi