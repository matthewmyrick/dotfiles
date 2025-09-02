#!/bin/bash

sketchybar --add item wifi right \
           --set wifi script="$PLUGIN_DIR/wifi.sh" \
                      icon=􀙇 \
                      background.padding_right=0 \
           --subscribe wifi wifi_change