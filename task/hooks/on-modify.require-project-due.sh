#!/usr/bin/env bash
set -euo pipefail

# on-modify receives two JSON docs on stdin: OLD then NEW
read -r old
read -r new

project="$(jq -r '.project // empty' <<<"$new")"
due="$(jq -r '.due // empty' <<<"$new")"

if [[ -z "$project" || -z "$due" ]]; then
  echo "❌ Policy: tasks must keep a project and a due date." >&2
  echo "   Tip: add them with  task <id> modify project:<name> due:<date>  (e.g., due:friday)" >&2
  exit 1
fi

# Accept: pass modified task through
echo "$old"
echo "$new"
