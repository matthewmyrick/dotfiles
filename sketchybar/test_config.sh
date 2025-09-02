#!/bin/bash

# Kill any existing sketchybar instance
killall sketchybar 2>/dev/null

# Start sketchybar with a simple visible configuration
sketchybar --bar height=32 \
                 color=0xff1e1e2e \
                 position=top \
                 sticky=on \
                 padding_left=10 \
                 padding_right=10 \
                 y_offset=0 \
                 margin=0 \
                 blur_radius=0 \
                 corner_radius=0

# Add a simple clock item to make sure something is visible
sketchybar --add item clock center \
           --set clock update_freq=1 \
                      label.color=0xffffffff \
                      label.font="SF Pro:Semibold:14.0" \
                      script='sketchybar --set clock label="$(date +"%I:%M %p")"'

# Add a simple text item
sketchybar --add item test left \
           --set test label="SketchyBar Working!" \
                     label.color=0xff00ff00 \
                     label.font="SF Pro:Bold:16.0"

# Update all items
sketchybar --update

echo "Test configuration loaded. You should see:"
echo "1. A dark bar at the top of your screen"
echo "2. Green text saying 'SketchyBar Working!' on the left"
echo "3. The current time in the center"
echo ""
echo "If you don't see anything, check:"
echo "1. System Settings > Privacy & Security > Accessibility"
echo "2. Make sure 'sketchybar' is in the list and checked"