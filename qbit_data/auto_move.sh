#!/bin/bash
TORRENT_PATH="$1"
CATEGORY="$2"
TORRENT_NAME="$3"
DEST_ROOT="/media_final"
LOG="/config/debug.log"

echo "--- SCRIPT TRIGGERED ---" > "$LOG"
echo "1. Path received: $TORRENT_PATH" >> "$LOG"
echo "2. Category received: $CATEGORY" >> "$LOG"
echo "3. Name received: $TORRENT_NAME" >> "$LOG"

# Map qBittorrent categories to Jellyfin folders
case "$CATEGORY" in
  "movies") FINAL_DIR="$DEST_ROOT/videos" ;;
  "animated") FINAL_DIR="$DEST_ROOT/animated" ;;
  "shows") FINAL_DIR="$DEST_ROOT/shows" ;;
  "musics") FINAL_DIR="$DEST_ROOT/musics" ;;
  *)
    echo "ABORTED: Category '$CATEGORY' did not match our list." >> "$LOG"
    exit 0
    ;;
esac

echo "4. Destination mapped to: $FINAL_DIR" >> "$LOG"

# Create the folder and COPY the file
mkdir -p "$FINAL_DIR"
echo "5. Copying files..." >> "$LOG"
cp -rv "$TORRENT_PATH" "$FINAL_DIR/" >> "$LOG" 2>&1
chmod -R 777 "$FINAL_DIR" >> "$LOG" 2>&1

echo "6. SUCCESS! Script finished." >> "$LOG"
