#!/bin/bash

# ============================================================================
# POKEMON CATCHING SYSTEM
# ============================================================================
# Advanced Pokemon catching mechanics with command tracking and escape logic
# Integrates with pokemon-colorscripts and catch-pokemon CLI tools

# --- POKEMON ENCOUNTER SYSTEM ---

# Generate a new Pokemon encounter
pokemon_encounter() {
    # Get random pokemon
    local pokemon_output=$(pokemon-colorscripts -r)
    local current_pokemon=$(echo "$pokemon_output" | head -1)
    
    # Store current pokemon and reset states
    export CURRENT_WILD_POKEMON="$current_pokemon"
    export POKEMON_ESCAPED=false
    export POKEMON_RAN_AWAY=false
    export POKEMON_CAUGHT=false
    
    # Display with highlighted name
    echo -e "A wild \033[1;33m$current_pokemon\033[0m appeared!"
    echo "$pokemon_output" | tail -n +2
    echo -e "\033[2mUse 'catch' to attempt capture!\033[0m"
}

# --- CLI-BASED POKEMON MANAGEMENT ---
# The catch-pokemon CLI now handles escape logic internally

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
    
    # Run the command with tee to show output live AND capture it
    catch-pokemon catch "$CURRENT_WILD_POKEMON" --hide-pokemon 2>&1 | tee "$temp_output"
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
        echo -e "\033[1;33m⚡ The Pokemon broke free! Try again before it escapes!\033[0m"
    fi
    
    return $catch_result
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

# --- HELP FUNCTION ---

pokemon_help() {
    echo -e "\033[1;36m🎮 Pokemon Catching System Commands:\033[0m"
    echo -e "  \033[1;33mcatch\033[0m           - Attempt to catch the current wild Pokemon"
    echo -e "  \033[1;33mpokemon_status\033[0m  - Show current Pokemon status"
    echo -e "  \033[1;33mpokemon_new\033[0m     - Force a new Pokemon encounter"
    echo -e "  \033[1;33mpokemon_clear\033[0m   - Clear current Pokemon (for testing)"
    echo -e "  \033[1;33mpokemon_help\033[0m    - Show this help message"
    echo ""
    echo -e "\033[2mNote: Pokemon may escape based on CLI behavior!\033[0m"
    echo -e "\033[2mGame ends when Pokemon is caught or runs away.\033[0m"
}