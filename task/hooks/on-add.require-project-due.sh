#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"

project="$(jq -r '.project // empty' <<<"$payload")"
due="$(jq -r '.due // empty' <<<"$payload")"

if [[ -z "$project" || -z "$due" ]]; then
  echo "❌ Policy: every task must include a project and a due date." >&2
  echo "   Example: task add \"Write ADR\" project:apollo-iac due:friday" >&2
  exit 1
fi

# Accept: pass through unchanged
echo "$payload"
