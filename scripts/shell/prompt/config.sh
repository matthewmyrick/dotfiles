#!/usr/bin/env zsh
# Prompt Configuration
# Custom prompt setup - always loaded for shell appearance

# Note: No lazy load guard here as prompt needs to be always available

# Source git functions for prompt (lightweight, needed for prompt)
source "$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/git/functions.sh"

# --- Original Prompt Configuration (commented out) ---
# prompt_header() {
#     local header='%B';
# 
#     header+='%F{166}%n%f'; # username
#     header+=' at ';
#     header+='%F{136}%m%f'; # host
#     header+=' in ';
#     header+='%F{64}%~%f'; # working directory
#     if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#         # add git info if the current directory is in a repo
#         header+=' on ';
#         local branch=$(git_branch 2>/dev/null)
#         local status=$(git_status 2>/dev/null)
#         header+="%F{61}${branch}%f"; # git branch
#         header+="%F{33}${status}%f"; # git status
#     fi
#     header+='%b';
# 
#     echo -e "${header}";
# }

# --- New Cool Prompt Configuration ---
prompt_header() {
    local header='';
    
    # Cool prompt with icons and better formatting
    # First line: User and host info with icon
    header+='%F{white}╭─%f '; # Start with a nice bracket in white
    header+='%F{white}󰀄 %f'; # User icon in white
    header+='%B%F{green}%n%f%b'; # username in bold green
    header+='%F{241} @ %f'; # @ in gray
    header+='%B%F{216}%m%f%b'; # hostname in soft orange
    
    # Python virtual environment (if active)
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name="${VIRTUAL_ENV##*/}"  # Get just the venv name
        header+=' %F{241}•%f '; # separator dot before venv
        header+='🐍 '; # Python snake emoji
        header+="%F{22}(${venv_name})%f"; # venv name in darker green (less bright)
    fi
    
    # Directory with icon
    if [[ -z "$VIRTUAL_ENV" ]]; then
        header+=' %F{241}•%f '; # separator dot only if no venv
    else
        header+=' '; # just space if venv is shown
    fi
    header+='%F{cyan}%f'; # folder icon in cyan
    header+='%B%F{blue}%~%f%b'; # working directory in blue
    
    # Git info on same line if in repo
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git_branch 2>/dev/null)
        # Removed git_status call - just show branch
        header+=' %F{241}•%f '; # separator
        header+='%F{magenta}%f'; # git icon in magenta
        header+="%B%F{183}${branch}%f%b"; # branch in soft light purple
        # Removed status display
    fi
    
    # Add NYC weather (if we can get it)
    # This will be populated by a background job to avoid slowing prompt
    if [[ -n "${NYC_WEATHER_CACHE}" ]]; then
        header+=' %F{241}•%f '; # separator
        header+="${NYC_WEATHER_CACHE}";
    fi
    
    echo -e "${header}";
}

# Weather function for NYC (always try API first, cache as fallback)
update_nyc_weather() {
    local cache_file="/tmp/.nyc_weather_cache"
    
    # Always try the API first with 1.5 second timeout
    local weather_data=$(curl -s --max-time 1.5 "wttr.in/NYC?format=%t+%C" 2>/dev/null)
    
    if [[ -n "$weather_data" ]]; then
        # Successfully got fresh weather data
        local temp=$(echo "$weather_data" | cut -d' ' -f1)
        local condition=$(echo "$weather_data" | cut -d' ' -f2-)
        
        # Choose icon based on condition
        local weather_icon="🌡"
        [[ "$condition" == *"Clear"* ]] && weather_icon="☀️"
        [[ "$condition" == *"Sunny"* ]] && weather_icon="☀️"
        [[ "$condition" == *"Cloud"* ]] && weather_icon="☁️"
        [[ "$condition" == *"Overcast"* ]] && weather_icon="☁️"
        [[ "$condition" == *"Rain"* ]] && weather_icon="🌧️"
        [[ "$condition" == *"Snow"* ]] && weather_icon="❄️"
        [[ "$condition" == *"Thunder"* ]] && weather_icon="⛈️"
        [[ "$condition" == *"Fog"* ]] && weather_icon="🌫️"
        
        # Create formatted weather string
        local formatted_weather="%F{yellow}${weather_icon} NYC ${temp}%f"
        export NYC_WEATHER_CACHE="$formatted_weather"
        
        # Save to cache for future fallback
        echo "$formatted_weather" > "$cache_file"
    else
        # API failed, try to use cached data
        if [[ -f "$cache_file" ]]; then
            export NYC_WEATHER_CACHE=$(cat "$cache_file")
        else
            # No cache available either
            export NYC_WEATHER_CACHE="%F{yellow}🌡 NYC no data%f"
        fi
    fi
}

# prompt function to add to precmd_functions
prompt_precmd() {
    # Update weather in background
    update_nyc_weather
    
    echo # add newline before prompt header
    print -rP "$(prompt_header)"
}

# Add to precmd_functions array instead of defining precmd directly
if [[ ! " ${precmd_functions[@]} " =~ " prompt_precmd " ]]; then
    precmd_functions+=(prompt_precmd)
fi

# Original PROMPT (commented out)
# PROMPT="%B%F{15}$%f%b ";
# PS2="%B%F{136}→%f%b ";

# New cool PROMPT with continuation line
PROMPT="%F{white}╰─%f%F{green}❯%f ";  # White bracket with green arrow tip
PS2="%F{248}   %f%F{71}→%f ";