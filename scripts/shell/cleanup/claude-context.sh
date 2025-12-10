#!/bin/bash

# Claude Code context cleanup script
# Removes project context folders that haven't been updated in 2 weeks
# Run silently on shell startup

CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
CLAUDE_CLEANUP_LOG="$HOME/.claude/cleanup.log"
MAX_AGE_DAYS=14

# Only run if the projects directory exists
if [[ -d "$CLAUDE_PROJECTS_DIR" ]]; then
  # Find and remove directories older than MAX_AGE_DAYS
  # Uses the directory's modification time
  find "$CLAUDE_PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +${MAX_AGE_DAYS} 2>/dev/null | while read -r dir; do
    dir_name=$(basename "$dir")
    # Skip hidden directories
    if [[ ! "$dir_name" =~ ^\. ]]; then
      rm -rf "$dir"
      # Log the cleanup
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Removed: $dir_name" >> "$CLAUDE_CLEANUP_LOG"
    fi
  done
fi
