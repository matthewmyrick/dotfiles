#!/usr/bin/env zsh
# AWS Auto-Prompt Continuous Mode
# Keeps you in AWS auto-prompt mode without exiting after each command

# Lazy load guard
[[ -n "${_AWS_AUTO_PROMPT_LOADED}" ]] && return
_AWS_AUTO_PROMPT_LOADED=1

# Continuous AWS auto-prompt wrapper
aws-auto-prompt() {
    # Check if AWS CLI is installed
    if ! command -v aws >/dev/null 2>&1; then
        echo "❌ AWS CLI is not installed. Please install it first."
        return 1
    fi

    echo "🔄 Starting continuous AWS auto-prompt mode"
    echo "💡 Press Ctrl+C to exit"
    echo ""

    # Keep running aws --cli-auto-prompt in a loop
    while true; do
        # Run AWS CLI with auto-prompt
        aws --cli-auto-prompt

        # Check the exit status
        local exit_status=$?

        # If user pressed Ctrl+C (exit status 130), break the loop
        if [[ $exit_status -eq 130 ]]; then
            echo ""
            echo "👋 Exited AWS auto-prompt mode"
            break
        fi

        # Small delay to prevent rapid looping on errors
        sleep 0.1
    done
}
