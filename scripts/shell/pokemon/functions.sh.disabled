#!/bin/bash

# ============================================================================
# POKEMON CATCHING SYSTEM
# ============================================================================
# Advanced Pokemon catching mechanics with command tracking and escape logic
# Integrates with pokemon-colorscripts and catch-pokemon CLI tools

# --- POKEMON ENCOUNTER SYSTEM ---

# Generate a new Pokemon encounter using weighted encounter rates
pokemon_encounter() {
    local current_pokemon
    local category=""

    local is_shiny="false"

    # Use catch-pokemon encounter for weighted random selection if available
    if command -v catch-pokemon &>/dev/null; then
        # Use --show-pokemon to get both name, shiny status, and category in one call
        local encounter_output
        encounter_output=$(catch-pokemon encounter --show-pokemon 2>/dev/null)
        current_pokemon=$(echo "$encounter_output" | head -1)
        # Extract shiny status (second line)
        is_shiny=$(echo "$encounter_output" | sed -n '2p' | sed 's/Shiny: //')
        # Extract category, stripping ANSI color codes
        category=$(echo "$encounter_output" | grep "^Category:" | sed 's/Category: //' | sed 's/\x1b\[[0-9;]*m//g' | tr '[:upper:]' '[:lower:]')
        # Extract type line (keep ANSI colors for display)
        local pokemon_type
        pokemon_type=$(echo "$encounter_output" | grep "^Type:")
    fi

    # Fallback to pokemon-colorscripts random if catch-pokemon is not available
    if [[ -z "$current_pokemon" ]]; then
        local pokemon_output=$(pokemon-colorscripts -r)
        current_pokemon=$(echo "$pokemon_output" | head -1)
    fi

    # Store current pokemon and reset states
    export CURRENT_WILD_POKEMON="$current_pokemon"
    export POKEMON_IS_SHINY="$is_shiny"
    export POKEMON_ATTEMPT=1
    export POKEMON_ESCAPED=false
    export POKEMON_RAN_AWAY=false
    export POKEMON_CAUGHT=false

    # Shiny tag only appears if shiny
    local shiny_tag=""
    if [[ "$is_shiny" == "true" ]]; then
        shiny_tag=" \033[1;33m[Shiny]\033[0m"
    fi

    # Display announcement based on category
    if [[ "$category" == "legendary" ]]; then
        echo ""
        echo -e "\033[1;5;31m⚡ A LEGENDARY POKEMON HAS APPEARED! ⚡\033[0m"
        echo -e "\033[1;31m════════════════════════════════════════\033[0m"
        echo -e "A wild \033[1;31m$current_pokemon\033[0m appeared! \033[1;31m[Legendary]\033[0m$shiny_tag"
    elif [[ "$category" == "mythical" ]]; then
        echo ""
        echo -e "\033[1;5;35m✨ A MYTHICAL POKEMON HAS APPEARED! ✨\033[0m"
        echo -e "\033[1;35m════════════════════════════════════════\033[0m"
        echo -e "A wild \033[1;35m$current_pokemon\033[0m appeared! \033[1;35m[Mythical]\033[0m$shiny_tag"
    elif [[ "$category" == "pseudo-legendary" ]]; then
        echo ""
        echo -e "A wild \033[1;33m$current_pokemon\033[0m appeared! \033[1;33m[Pseudo-Legendary]\033[0m$shiny_tag"
    elif [[ "$category" == "starter" ]]; then
        echo -e "A wild \033[1;32m$current_pokemon\033[0m appeared! \033[1;32m[Starter]\033[0m$shiny_tag"
    elif [[ "$category" == "starter evolution" ]]; then
        echo -e "A wild \033[1;32m$current_pokemon\033[0m appeared! \033[1;32m[Starter Evolution]\033[0m$shiny_tag"
    elif [[ "$category" == "rare" ]]; then
        echo -e "A wild \033[1;36m$current_pokemon\033[0m appeared! \033[1;36m[Rare]\033[0m$shiny_tag"
    elif [[ "$category" == "baby" ]]; then
        echo -e "A wild \033[1;35m$current_pokemon\033[0m appeared! \033[1;35m[Baby]\033[0m$shiny_tag"
    elif [[ "$category" == "uncommon" ]]; then
        echo -e "A wild \033[1;33m$current_pokemon\033[0m appeared! \033[2m[Uncommon]\033[0m$shiny_tag"
    else
        echo -e "A wild \033[1;33m$current_pokemon\033[0m appeared! \033[2m[Common]\033[0m$shiny_tag"
    fi

    # Display the Pokemon sprite (shiny version if shiny)
    if command -v pokemon-colorscripts &>/dev/null; then
        if [[ "$is_shiny" == "true" ]]; then
            pokemon-colorscripts -n "$current_pokemon" --no-title -s 2>/dev/null
        else
            pokemon-colorscripts -n "$current_pokemon" --no-title 2>/dev/null
        fi
    fi

    # Display type
    if [[ -n "$pokemon_type" ]]; then
        echo -e "$pokemon_type"
    fi

    # Check if we already have this Pokemon
    if command -v catch-pokemon &>/dev/null; then
        local ownership_status
        ownership_status=$(catch-pokemon status "$current_pokemon" --boolean 2>/dev/null)

        if [[ "$ownership_status" == "true" ]]; then
            echo -e "\033[1;32m📖 You already have this Pokemon in your collection!\033[0m"
        else
            echo -e "\033[2m📝 This Pokemon is not in your collection yet.\033[0m"
        fi
    fi

    echo -e "\033[2mUse 'catch' to attempt capture!\033[0m"
}

# --- CATCH MECHANICS ---

# Attempt to catch the current wild Pokemon
catch() {
    if [[ -z "$CURRENT_WILD_POKEMON" ]]; then
        echo -e "\033[1;31m❌ No wild Pokemon to catch!\033[0m"
        return 1
    fi

    if [[ "$POKEMON_ESCAPED" == "true" ]]; then
        echo -e "\033[1;31m💨 The Pokemon already escaped!\033[0m"
        return 1
    fi

    if [[ "$POKEMON_RAN_AWAY" == "true" ]]; then
        echo -e "\033[1;31m💨 The Pokemon already ran away! Open a new terminal for a new encounter.\033[0m"
        return 1
    fi

    if [[ "$POKEMON_CAUGHT" == "true" ]]; then
        echo -e "\033[1;32m🎉 You already caught a Pokemon this session! Open a new terminal for a new encounter.\033[0m"
        return 1
    fi

    # Attempt to catch the current pokemon
    echo -e "\033[1;36m🎯 Attempting to catch $CURRENT_WILD_POKEMON...\033[0m"

    # Use a temporary file to capture output while still showing it live
    local temp_output=$(mktemp)

    # Build catch command with attempt count and shiny flag
    local catch_cmd="catch-pokemon catch $CURRENT_WILD_POKEMON --hide-pokemon --attempt $POKEMON_ATTEMPT"
    if [[ "$POKEMON_IS_SHINY" == "true" ]]; then
        catch_cmd="$catch_cmd --shiny"
    fi

    # Run the command with tee to show output live AND capture it
    eval "$catch_cmd" 2>&1 | tee "$temp_output"
    local catch_result=${PIPESTATUS[0]}

    # Read the captured output for analysis
    local catch_output=$(cat "$temp_output")
    rm -f "$temp_output"

    # Check if the Pokemon ran away based on the CLI output
    if echo "$catch_output" | grep -i "ran away\|broke free and ran away" > /dev/null; then
        echo -e "\033[1;31m💨 The Pokemon has fled! No more attempts possible this session.\033[0m"
        export POKEMON_ESCAPED=true
        export POKEMON_RAN_AWAY=true
        export CURRENT_WILD_POKEMON=""
    elif echo "$catch_output" | grep -i "caught\|captured\|success" > /dev/null; then
        echo -e "\033[1;32m🎉 Pokemon caught successfully!\033[0m"
        export POKEMON_ESCAPED=true
        export POKEMON_CAUGHT=true
        export CURRENT_WILD_POKEMON=""
    else
        # Pokemon broke free but didn't run away - can try again
        export POKEMON_ATTEMPT=$((POKEMON_ATTEMPT + 1))
        echo -e "\033[1;33m⚡ The Pokemon broke free! Try again before it escapes!\033[0m"
        echo -e "\033[2mAttempt $POKEMON_ATTEMPT next throw - flee chance increases!\033[0m"
    fi

    return $catch_result
}

# --- PC SHORTCUT ---

# View your Pokemon collection (shortcut for catch-pokemon pc)
pc() {
    if command -v catch-pokemon &>/dev/null; then
        catch-pokemon pc "$@"
    else
        echo -e "\033[1;31m❌ catch-pokemon CLI not found\033[0m"
        return 1
    fi
}

# --- UTILITY FUNCTIONS ---

# Show current Pokemon status
pokemon_status() {
    if [[ -n "$CURRENT_WILD_POKEMON" && "$POKEMON_ESCAPED" != "true" && "$POKEMON_RAN_AWAY" != "true" && "$POKEMON_CAUGHT" != "true" ]]; then
        echo -e "Wild Pokemon: \033[1;33m$CURRENT_WILD_POKEMON\033[0m"
        echo -e "\033[2mUse 'catch' to attempt capture!\033[0m"
    elif [[ "$POKEMON_RAN_AWAY" == "true" ]]; then
        echo -e "\033[1;31m💨 The Pokemon ran away from this session\033[0m"
        echo -e "\033[2mOpen a new terminal for a new encounter\033[0m"
    elif [[ "$POKEMON_CAUGHT" == "true" ]]; then
        echo -e "\033[1;32m🎉 Pokemon was successfully caught!\033[0m"
        echo -e "\033[2mOpen a new terminal for a new encounter\033[0m"
    else
        echo -e "\033[2mNo wild Pokemon currently available\033[0m"
        echo -e "\033[2mUse 'pokemon_new' to force a new encounter\033[0m"
    fi
}

# Force a new Pokemon encounter
pokemon_new() {
    echo -e "\033[2mForcing new Pokemon encounter...\033[0m"
    pokemon_encounter
}

# Clear current Pokemon (for testing/debugging)
pokemon_clear() {
    export CURRENT_WILD_POKEMON=""
    export POKEMON_ESCAPED=true
    export POKEMON_RAN_AWAY=false
    export POKEMON_CAUGHT=false
    echo -e "\033[2mPokemon encounter cleared\033[0m"
}

# Check if you own a specific Pokemon
pokemon_check() {
    local pokemon_name="$1"

    if [[ -z "$pokemon_name" ]]; then
        echo -e "\033[1;31m❌ Please specify a Pokemon name\033[0m"
        echo -e "\033[2mUsage: pokemon_check <pokemon_name>\033[0m"
        return 1
    fi

    if command -v catch-pokemon &>/dev/null; then
        local ownership_status
        ownership_status=$(catch-pokemon status "$pokemon_name" --boolean 2>/dev/null)

        if [[ "$ownership_status" == "true" ]]; then
            echo -e "\033[1;32m📖 You have \033[1;33m$pokemon_name\033[1;32m in your collection!\033[0m"
        else
            echo -e "\033[1;31m📝 You don't have \033[1;33m$pokemon_name\033[1;31m in your collection yet.\033[0m"
        fi
    else
        echo -e "\033[1;31m❌ catch-pokemon CLI not found\033[0m"
        return 1
    fi
}

# --- HELP FUNCTION ---

pokemon_help() {
    echo -e "\033[1;36m🎮 Pokemon Catching System Commands:\033[0m"
    echo -e "  \033[1;33mcatch\033[0m               - Attempt to catch the current wild Pokemon"
    echo -e "  \033[1;33mpc\033[0m                  - View your Pokemon collection"
    echo -e "  \033[1;33mpokemon_status\033[0m      - Show current Pokemon status"
    echo -e "  \033[1;33mpokemon_check <name>\033[0m - Check if you own a specific Pokemon"
    echo -e "  \033[1;33mpokemon_new\033[0m         - Force a new Pokemon encounter"
    echo -e "  \033[1;33mpokemon_clear\033[0m       - Clear current Pokemon (for testing)"
    echo -e "  \033[1;33mpokemon_help\033[0m        - Show this help message"
    echo ""
    echo -e "\033[2mNote: Pokemon may escape based on CLI behavior!\033[0m"
    echo -e "\033[2mGame ends when Pokemon is caught or runs away.\033[0m"
    echo -e "\033[2mOwnership status is shown when wild Pokemon appear.\033[0m"
}
