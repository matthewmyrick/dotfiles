#!/usr/bin/env zsh
# Network Process Functions
# Functions for managing network processes

# Lazy load guard
[[ -n "${_NETWORK_PROCESSES_LOADED}" ]] && return
_NETWORK_PROCESSES_LOADED=1

lports() {
  command -v fzf >/dev/null || {
    echo "fzf required"
    return 1
  }
  
  # Get sudo permissions upfront to avoid interrupting fzf
  echo "Getting process information (requires sudo)..."
  if ! sudo -v; then
    echo "Sudo required for lsof"
    return 1
  fi
  
  local line pid
  line=$(
    sudo lsof -nP -iTCP@127.0.0.1 -sTCP:LISTEN |
      awk 'NR>1{printf "%-8s %-18s %-6s %s\n",$2,$1,$9,$NF}' |
      fzf --height=40% --layout=reverse --border \
          --with-nth=2,3 \
          --header='PID      CMD               ADDR:PORT  NAME'
  ) || return
  
  pid=$(awk '{print $1}' <<<"$line")
  [[ -n $pid ]] && sudo lsof -p "$pid"
}
