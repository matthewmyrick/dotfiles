#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.color=0x44ffffff \
                                 icon.color=0xffffffff \
                                 icon.font="$FONT:Black:13.0" \
                                 label.color=0xffffffff \
                                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched