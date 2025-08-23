#!/usr/bin/env zsh
# Go Runtime Measurement Tools
# Functions for measuring Go program execution times without code modification

# Lazy load guard
[[ -n "${_GO_TELEMETRY_LOADED}" ]] && return
_GO_TELEMETRY_LOADED=1

# Enhanced Go timing with hyperfine (preferred method)
gotime() {
  if ! command -v hyperfine >/dev/null 2>&1; then
    echo "⚠️  hyperfine not found. Install with: brew install hyperfine"
    echo "Falling back to basic timing..."
    echo "🚀 Timing Go execution..."
    /usr/bin/time -l go run "$@"
    return
  fi

  if [[ $# -eq 0 ]]; then
    echo "Usage: gotime <go-file> [args...]"
    echo "Example: gotime main.go"
    echo "Example: gotime server.go --port 8080"
    return 1
  fi

  echo "🚀 Benchmarking Go execution with statistical analysis..."
  hyperfine --warmup 1 --min-runs 3 "go run $*"
}

# Compare multiple Go implementations
gocompare() {
  if ! command -v hyperfine >/dev/null 2>&1; then
    echo "⚠️  hyperfine required for comparison. Install with: brew install hyperfine"
    return 1
  fi

  if [[ $# -lt 2 ]]; then
    echo "Usage: gocompare <file1.go> <file2.go> [file3.go...]"
    echo "Example: gocompare version1.go version2.go optimized.go"
    return 1
  fi

  echo "🏁 Comparing Go implementations..."
  local commands=()
  for file in "$@"; do
    commands+=("go run $file")
  done
  
  hyperfine --warmup 1 "${commands[@]}"
}

# Detailed Go timing with memory stats (no external deps)
godetail() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: godetail <go-file> [args...]"
    echo "Shows detailed timing and memory usage"
    return 1
  fi

  echo "📊 Detailed Go execution analysis..."
  echo "File: $1"
  echo "Arguments: ${@:2}"
  echo "---"
  
  # Use macOS time with detailed stats
  /usr/bin/time -l go run "$@"
}

# Go execution with garbage collection tracing
gogc() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: gogc <go-file> [args...]"
    echo "Shows Go execution with GC timing information"
    return 1
  fi

  echo "🗑️  Go execution with GC tracing..."
  GODEBUG=gctrace=1 go run "$@"
}

# Quick Go timing (simplest option)
goquick() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: goquick <go-file> [args...]"
    return 1
  fi

  echo "⚡ Quick Go timing..."
  time go run "$@"
}