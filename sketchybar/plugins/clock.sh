#!/bin/sh

# Simple clock with EST time in 12-hour format
sketchybar --set "$NAME" label="$(TZ='America/New_York' date '+%I:%M %p')"

