#!/bin/bash

sketchybar --add item apple left \
           --set apple icon="$APPLE" \
                       icon.font="$FONT:Black:16.0" \
                       label.drawing=off \
                       background.color=$RED \
                       background.padding_right=8 \
                       background.padding_left=8 \
                       click_script="$PLUGIN_DIR/apple.sh"