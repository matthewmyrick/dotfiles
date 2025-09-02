#!/bin/sh

# Simple space indicator - just highlight active space
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color=0xff4a4a4a
else
  sketchybar --set "$NAME" icon.color=0xffffffff
fi
