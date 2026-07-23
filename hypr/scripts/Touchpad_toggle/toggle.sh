#!/usr/bin/env bash

# Your exact touchpad device name
TOUCHPAD="ven_04f3:00-04f3:31e2-touchpad"
STATE_FILE="$XDG_RUNTIME_DIR/touchpad.status"

# Read state from file or initialize
if [ ! -f "$STATE_FILE" ]; then
    echo "true" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "true" ]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" false
    echo "false" > "$STATE_FILE"
    notify-send "Touchpad" "Disabled" -i input-touchpad
else
    hyprctl keyword "device[$TOUCHPAD]:enabled" true
    echo "true" > "$STATE_FILE"
    notify-send "Touchpad" "Enabled" -i input-touchpad
fi
