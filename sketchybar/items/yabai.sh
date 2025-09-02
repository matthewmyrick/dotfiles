#!/bin/bash

sketchybar --add item yabai left \
           --set yabai update_freq=1 \
                       script="$PLUGIN_DIR/yabai.sh" \
                       icon.font="$FONT:Bold:16.0" \
                       label.drawing=off \
                       icon.width=30 \
                       icon="􀏜" \
                       icon.color=0xffffffff