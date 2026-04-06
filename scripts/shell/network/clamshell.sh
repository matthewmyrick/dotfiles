#!/usr/bin/env zsh
# Clamshell mode — keep laptop awake with lid closed for SSH access

# Enable clamshell mode (laptop stays awake when closed)
clamshell-on() {
    sudo pmset -a disablesleep 1
    echo "Clamshell mode ON — laptop will stay awake with lid closed"
    echo "  SSH: ssh matthewmyrick@$(/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4 2>/dev/null || echo '<tailscale-ip>')"
}

# Disable clamshell mode (normal sleep behavior)
clamshell-off() {
    sudo pmset -a disablesleep 0
    echo "Clamshell mode OFF — normal sleep resumed"
}

# Check current clamshell status
clamshell-status() {
    local sleep_val=$(pmset -g | grep disablesleep | awk '{print $2}')
    if [[ "$sleep_val" == "1" ]]; then
        echo "Clamshell mode: ON (laptop stays awake when closed)"
    else
        echo "Clamshell mode: OFF (normal sleep)"
    fi
    echo ""
    echo "Tailscale IP: $(/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4 2>/dev/null || echo 'not connected')"
    echo "Tailscale:    $(/Applications/Tailscale.app/Contents/MacOS/Tailscale status 2>/dev/null | head -1 || echo 'stopped')"
}
