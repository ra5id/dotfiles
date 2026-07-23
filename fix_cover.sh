#!/bin/bash

MODE="cover"
RATIO="1:1"

# -------- HELP --------
show_help() {

echo "
Usage:
  ./fix_cover.sh [mode] [options] <file/folder>

Modes:
  --cover            Fix embedded album covers (default)
  --title            Clean filenames + MP3 titles

Options:
  -r WIDTH:HEIGHT    Cover ratio

Examples:

  # square cover
  ./fix_cover.sh song.mp3

  # widescreen cover
  ./fix_cover.sh --cover -r 16:9 song.mp3

  # vertical cover
  ./fix_cover.sh --cover -r 9:16 Music/

  # custom ratio
  ./fix_cover.sh --cover -r 7:5 song.mp3

  # clean titles
  ./fix_cover.sh --title Music/
"
}

# -------- ARG PARSING --------
while [[ $# -gt 0 ]]; do
  case "$1" in

    --help|-h|-help)
      show_help
      exit 0
      ;;

    # modes
    --title)
      MODE="title"
      shift
      ;;

    --cover)
      MODE="cover"
      shift
      ;;

    # ratio
    -r|--ratio)
      RATIO="$2"
      shift 2
      ;;

    *)
      TARGET="$1"
      shift
      ;;
  esac
done

# -------- CLEAN NAME --------
clean_name() {

  echo "$1" | sed -E \
    's/\[[^]]*\]//g;
     s/\([^)]*\)//g;
     s/  */ /g;
     s/^ *| *$//g'
}

# -------- TITLE MODE --------
process_title() {

  FILE="$1"

  DIR=$(dirname "$FILE")
  BASE=$(basename "$FILE" .mp3)

  echo "🧹 Cleaning: $BASE"

  CLEAN=$(clean_name "$BASE")

  NEW_FILE="$DIR/$CLEAN.mp3"

  mv -n "$FILE" "$NEW_FILE" 2>/dev/null || NEW_FILE="$FILE"

  TMP_FILE="${NEW_FILE%.mp3}.tmp.mp3"

  ffmpeg -y -i "$NEW_FILE" \
    -map 0 \
    -c copy \
    -metadata title="$CLEAN" \
    "$TMP_FILE" 2>/dev/null && \
    mv -f "$TMP_FILE" "$NEW_FILE"

  echo "✅ Done: $(basename "$NEW_FILE")"
}

# -------- COVER MODE --------
process_cover() {

  FILE="$1"

  DIR="$(dirname "$FILE")"
  BASENAME="$(basename "$FILE")"
  NAME="${BASENAME%.mp3}"

  ORIGINAL_COVER="$DIR/.original_cover.jpg"

  TMP_COVER="$DIR/cover_tmp.png"
  TMP_RATIO="$DIR/cover_ratio.jpg"

  OUT_FILE="$DIR/${NAME}_fixed.mp3"

  echo "🖼️ Processing: $FILE"

  # -------- COVER SOURCE --------

  # single-file mode:
  # keep permanent original backup

  if [ -f "$TARGET" ]; then

    if [ ! -f "$ORIGINAL_COVER" ]; then

      ffmpeg -y -i "$FILE" -an -vcodec copy "$ORIGINAL_COVER" 2>/dev/null || {

        echo "⚠️ Failed to extract cover"
        return
      }
    fi

    cp "$ORIGINAL_COVER" "$TMP_COVER"

  # folder mode:
  # temporary only

  else

    ffmpeg -y -i "$FILE" -an -vcodec copy "$TMP_COVER" 2>/dev/null || {

      echo "⚠️ Failed to extract cover"
      return
    }

  fi

  # -------- RATIO --------
  WIDTH=600

  case "$RATIO" in

    1:1)
      HEIGHT=600
      ;;

    16:9)
      HEIGHT=338
      ;;

    9:16)
      HEIGHT=1067
      ;;

    4:3)
      HEIGHT=450
      ;;

    3:4)
      HEIGHT=800
      ;;

    *)
      W=$(echo "$RATIO" | cut -d: -f1)
      H=$(echo "$RATIO" | cut -d: -f2)

      if [[ -z "$W" || -z "$H" ]]; then

        echo "❌ Invalid ratio"

        rm -f "$TMP_COVER"
        return
      fi

      HEIGHT=$((WIDTH * H / W))
      ;;
  esac

  # -------- IMAGE PROCESS --------
  ffmpeg -y -i "$TMP_COVER" \
    -vf "
      scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,
      crop=${WIDTH}:${HEIGHT}
    " \
    "$TMP_RATIO" 2>/dev/null || {

      echo "❌ Image processing failed"

      rm -f "$TMP_COVER"
      return
    }

  # -------- RE-EMBED --------
  ffmpeg -y -i "$FILE" -i "$TMP_RATIO" \
    -map 0:a \
    -map 1 \
    -c:a copy \
    -c:v mjpeg \
    -disposition:v:0 attached_pic \
    "$OUT_FILE" 2>/dev/null || {

      echo "❌ Embed failed"

      rm -f "$TMP_COVER"
      rm -f "$TMP_RATIO"

      return
    }

  mv -f "$OUT_FILE" "$FILE"

  rm -f "$TMP_COVER"
  rm -f "$TMP_RATIO"

  echo "✅ Done: $FILE"
}

# -------- MAIN --------

if [ -z "$TARGET" ]; then
  show_help
  exit 1
fi

if [ ! -e "$TARGET" ]; then
  echo "❌ Invalid path"
  exit 1
fi

run_mode() {

  FILE="$1"

  if [ "$MODE" = "title" ]; then
    process_title "$FILE"
  else
    process_cover "$FILE"
  fi
}

# -------- FILE --------
if [ -f "$TARGET" ]; then

  run_mode "$TARGET"

# -------- DIRECTORY --------
elif [ -d "$TARGET" ]; then

  find "$TARGET" -type f -iname "*.mp3" | while read -r file; do
    run_mode "$file"
  done

fi
