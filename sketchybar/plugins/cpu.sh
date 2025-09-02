#!/bin/bash

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v USER | awk '{cpu+=$1} END {print cpu}')
CPU_PERCENT=$(echo "scale=2; $CPU_SYS / $CORE_COUNT" | bc)

sketchybar --set $NAME label="$CPU_PERCENT%"