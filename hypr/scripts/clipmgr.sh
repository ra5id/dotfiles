#!/bin/bash

# 1. Toggle: Kill if already open
if pgrep -x "rofi" > /dev/null; then
    pkill -x rofi
    exit 0
fi

# 2. Setup
THEME="$HOME/.config/rofi/launchers/type-1/style-1.rasi"
PINNED_FILE="$HOME/.config/rofi/pinned.txt"
touch "$PINNED_FILE"

# Clean up empty lines immediately
sed -i '/^[[:space:]]*$/d' "$PINNED_FILE"

# 3. Main Loop
while true; do
    action=$(echo -e "History\nPinned\nRefresh\nWipe" | rofi -dmenu -theme "$THEME" -p "Mode")
    
    if [ -z "$action" ]; then break; fi

    case "$action" in

        "History")
            while true; do
                # 🔥 IMPORTANT: NO cut -f2-
                selected=$(cliphist list | rofi -dmenu -theme "$THEME" -p "History" \
                    -kb-custom-1 "Alt+p" \
                    -kb-custom-2 "Alt+d")
                
                exit_code=$?
                if [ -z "$selected" ]; then break; fi 

                if [ "$exit_code" -eq 10 ]; then
                    # ✅ Pin FULL content
                    echo "$selected" | cliphist decode >> "$PINNED_FILE"
                    notify-send "Clipboard" "Pinned"

                elif [ "$exit_code" -eq 11 ]; then
                    # ✅ Delete correctly using ID
                    echo "$selected" | cliphist delete

                else
                    # ✅ Copy FULL content
                    echo "$selected" | cliphist decode | wl-copy
                    exit 0
                fi
            done
            ;;

        "Pinned")
            while true; do
                selected=$(cat "$PINNED_FILE" | rofi -dmenu -theme "$THEME" -p "Pinned" \
                    -kb-custom-1 "Alt+d")
                
                exit_code=$?
                if [ -z "$selected" ]; then break; fi 

                if [ "$exit_code" -eq 10 ]; then
                    grep -vxF "$selected" "$PINNED_FILE" > "$PINNED_FILE.tmp" && mv "$PINNED_FILE.tmp" "$PINNED_FILE"
                    sed -i '/^[[:space:]]*$/d' "$PINNED_FILE"
                else
                    echo -n "$selected" | wl-copy
                    exit 0
                fi
            done
            ;;

        "Refresh")
            pkill wl-paste; pkill cliphist
            wl-paste --type text --watch cliphist store -max-items 1000 -max-store-size 10MiB &
            notify-send "Clipboard" "Refreshed"
            break
            ;;

        "Wipe")
            cliphist wipe && notify-send "Clipboard" "Wiped"
            break
            ;;
    esac
done
