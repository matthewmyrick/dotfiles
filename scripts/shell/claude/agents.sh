#!/usr/bin/env zsh
# Claude Agent Launcher
# Interactive agent selection with fuzzy finder

# Lazy load guard
[[ -n "${_CLAUDE_AGENTS_LOADED}" ]] && return
_CLAUDE_AGENTS_LOADED=1

# Color definitions
_CA_GREEN='\033[0;32m'
_CA_YELLOW='\033[1;33m'
_CA_BLUE='\033[0;34m'
_CA_CYAN='\033[0;36m'
_CA_WHITE='\033[1;37m'
_CA_BOLD='\033[1m'
_CA_DIM='\033[2m'
_CA_NC='\033[0m'

# Base directory for claude agents
CLAUDE_AGENTS_DIR="$HOME/GitHub/matthewmyrick/agents/claude"

# fca (Fuzzy Claude Agent) - Two-step agent + project selector, then launch claude
fca() {
    # Check if agents directory exists
    if [[ ! -d "$CLAUDE_AGENTS_DIR" ]]; then
        echo -e "${_CA_YELLOW}Agents directory not found: $CLAUDE_AGENTS_DIR${_CA_NC}"
        return 1
    fi

    # Check if claude is installed
    if ! command -v claude >/dev/null 2>&1; then
        echo -e "${_CA_YELLOW}Claude CLI is not installed.${_CA_NC}"
        return 1
    fi

    # Export for fzf preview subshell
    export FZF_CA_AGENTS_DIR="$CLAUDE_AGENTS_DIR"

    # ── Step 1: Pick an agent ──
    local agent
    agent=$(ls -1 "$CLAUDE_AGENTS_DIR" \
        | fzf \
            --preview 'cat "$FZF_CA_AGENTS_DIR/{}/CLAUDE.md" 2>/dev/null || echo "No CLAUDE.md found"' \
            --preview-window 'right:60%:wrap' \
            --height '60%' \
            --border 'rounded' \
            --header 'Select Agent | ESC to cancel' \
            --prompt 'agent > ')

    # ESC or empty = abort
    if [[ -z "$agent" ]]; then
        return 0
    fi

    echo -e "${_CA_BOLD}${_CA_BLUE}Agent: ${_CA_CYAN}$agent${_CA_NC}"

    local agent_path="$CLAUDE_AGENTS_DIR/$agent"
    local agent_claude_md="$agent_path/CLAUDE.md"
    local agent_settings="$agent_path/settings.json"

    # ── Step 2: Pick a project (optional) ──
    local search_path="$HOME/GitHub"
    export FZF_CA_SEARCH_PATH="$search_path"

    local selected
    selected=$( (echo "── standalone (no project) ──"; fd --type d --max-depth 2 . "$search_path" --hidden --exclude .git --exclude node_modules | sed "s|^$search_path/||") \
        | fzf \
            --preview '[[ {} == "──"* ]] && cat "$FZF_CA_AGENTS_DIR/'"$agent"'/CLAUDE.md" 2>/dev/null || eza --tree --color=always --icons=always --level=2 "$FZF_CA_SEARCH_PATH/{}" 2>/dev/null || ls -la "$FZF_CA_SEARCH_PATH/{}"' \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header "Select Project | ESC to cancel | Agent: $agent" \
            --prompt 'project > ')

    # ESC or empty = abort
    if [[ -z "$selected" ]]; then
        return 0
    fi

    # ── Build claude command ──
    local claude_args=()

    # Append agent soul as system prompt
    if [[ -f "$agent_claude_md" ]]; then
        claude_args+=(--append-system-prompt "$(cat "$agent_claude_md")")
    fi

    # Load agent-specific settings
    if [[ -f "$agent_settings" ]]; then
        claude_args+=(--settings "$agent_settings")
    fi

    # Set session name for easy resume
    claude_args+=(--name "$agent")

    # Navigate to project or agent dir
    if [[ "$selected" == "──"* ]]; then
        # Standalone mode — run in agent directory
        echo -e "${_CA_BOLD}${_CA_GREEN}Launching ${_CA_WHITE}$agent${_CA_GREEN} agent (standalone)${_CA_NC}"
        cd "$agent_path"
    else
        # Project mode — run in project directory
        local project_path="$search_path/$selected"
        local project_name=$(basename "$selected")

        echo -e "${_CA_BOLD}${_CA_GREEN}Launching ${_CA_WHITE}$agent${_CA_GREEN} agent in ${_CA_WHITE}$project_name${_CA_NC}"
        cd "$project_path"

        # Set terminal tab name
        if command -v ttn &>/dev/null; then
            ttn "$agent:$project_name"
        fi
    fi

    # Launch claude
    claude "${claude_args[@]}"
}
