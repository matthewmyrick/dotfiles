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

# AWS shell mode - supports pipes, redirects, and shell operators
awsh() {
    # Check if AWS CLI is installed
    if ! command -v aws >/dev/null 2>&1; then
        echo "❌ AWS CLI is not installed. Please install it first."
        return 1
    fi

    echo "🐚 Starting AWS shell mode (supports pipes, redirects, etc.)"
    echo "💡 Press Ctrl+C or Ctrl+D to exit"
    echo "💡 Examples:"
    echo "   aws ec2 describe-vpcs --output yaml > vpcs.yaml"
    echo "   aws ec2 describe-vpcs --output json | jq '.Vpcs[] | .VpcId'"
    echo "   aws s3 ls && aws ec2 describe-instances"
    echo ""

    # Keep running in a loop
    while true; do
        # Use vared for line editing with syntax highlighting
        local cmd=""

        # Print prompt
        print -n "aws> "

        # Use vared for line editing (gets syntax highlighting from zsh-syntax-highlighting)
        vared -p "" -c cmd

        # Check the exit status
        local read_status=$?

        # If user pressed Ctrl+C or Ctrl+D, break the loop
        if [[ $read_status -ne 0 ]]; then
            echo ""
            echo "👋 Exited AWS shell mode"
            break
        fi

        # Skip empty commands
        [[ -z "$cmd" ]] && continue

        # Execute command through shell (supports all shell operators)
        eval "$cmd"

        # Small delay to prevent rapid looping
        sleep 0.1
    done
}
