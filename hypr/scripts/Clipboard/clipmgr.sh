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

# Clean empty lines
sed -i '/^[[:space:]]*$/d' "$PINNED_FILE"

# 3. Main Loop
while true; do
    action=$(echo -e "History\nPinned\nRefresh\nWipe" | rofi -dmenu -theme "$THEME" -p "Mode")
    
    if [ -z "$action" ]; then break; fi

    case "$action" in

        "History")
            while true; do
                selected=$(cliphist list | rofi -dmenu -theme "$THEME" -p "History" \
                    -kb-custom-1 "Alt+p" \
                    -kb-custom-2 "Alt+d")
                
                exit_code=$?
                if [ -z "$selected" ]; then break; fi 

                if [ "$exit_code" -eq 10 ]; then
                    # 🔥 Pin safely using base64
                    entry=$(echo "$selected" | cliphist decode | base64 -w 0)
                    grep -qxF "$entry" "$PINNED_FILE" || echo "$entry" >> "$PINNED_FILE"
                    notify-send "Clipboard" "Pinned"

                elif [ "$exit_code" -eq 11 ]; then
                    # Delete from history
                    echo "$selected" | cliphist delete

                else
                    # Copy normally
                    echo "$selected" | cliphist decode | wl-copy
                    exit 0
                fi
            done
            ;;

        "Pinned")
            while true; do
                # Build preview list (decoded first line)
                mapfile -t raw < "$PINNED_FILE"

                preview_list=()
                    for line in "${raw[@]}"; do
                    decoded=$(printf '%s' "$line" | base64 -d 2>/dev/null)
                    preview_list+=("$(echo "$decoded" | head -n 1)")
                done

                selected_preview=$(printf '%s\n' "${preview_list[@]}" | rofi -dmenu -theme "$THEME" -p "Pinned" \
                    -kb-custom-1 "Alt+d")

                exit_code=$?
                if [ -z "$selected_preview" ]; then break; fi

                # find matching index
                index=-1
                for i in "${!preview_list[@]}"; do
                    if [ "${preview_list[$i]}" = "$selected_preview" ]; then
                        index=$i
                        break
                    fi
                done

                [ "$index" -lt 0 ] && continue

                selected="${raw[$index]}"

                if [ "$exit_code" -eq 10 ]; then
                    tmp=$(mktemp)
                    for i in "${!raw[@]}"; do
                        if [ "$i" -ne "$index" ]; then
                            printf '%s\n' "${raw[$i]}" >> "$tmp"
                        fi
                    done
                    mv "$tmp" "$PINNED_FILE"

                else
                    printf '%s' "$selected" | base64 -d | wl-copy
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
