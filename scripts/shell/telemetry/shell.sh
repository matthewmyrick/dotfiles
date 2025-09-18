#!/usr/bin/env zsh

# --- Always-on colored Top-3 for zprof ---
# Requires: zmodload zsh/zprof (put that near the top of your zshrc)
zprof() {
  emulate -L zsh
  setopt pipefail

  # Run the real/builtin zprof and capture output
  local _tmp
  _tmp=$(mktemp)
  builtin zprof >|"$_tmp" # store to file
  # Skip showing the full table - we only want the top 3 summary

  # Parse the first table's top 3 entries: rank, name, total, self
  local _top
  _top="$(
    awk '
      /^[[:space:]]*[0-9]+\)/ {
        # Example row:
        #  1)    2   533.17   266.59   78.46%   290.42   145.21   42.74%  nvm
        rank=$1; gsub(/\)/,"",rank)
        calls=$2
        total=$3      # "time" total
        self=$4       # "self" total
        name=$NF      # function name
        printf "%s\t%s\t%s\t%s\n", rank, name, total, self
        ++count; if (count==3) exit
      }
    ' "$_tmp"
  )"

  # Pretty summary (only color if TTY)
  local _c1=""
  local _c2=""
  local _c3=""
  local _cn=""
  if [[ -t 1 ]]; then
    _c1=$'%F{red}'
    _c2=$'%F{yellow}'
    _c3=$'%F{blue}'
    _cn=$'%f'
  fi

  print "\nTop 3 slowest (by total time):"
  local _line _rank _name _tot _self
  local _i=0
  while IFS=$'\t' read -r _rank _name _tot _self; do
    ((++_i))
    local _c=$_cn
    ((_i == 1)) && _c=$_c1
    ((_i == 2)) && _c=$_c2
    ((_i == 3)) && _c=$_c3
    print -P "${_c}#${_rank} ${_name}${_cn}   total=${_tot}ms   self=${_self}ms"
  done <<<"$_top"

  rm -f "$_tmp"
}
