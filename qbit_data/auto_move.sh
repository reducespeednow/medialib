#!/bin/bash
TORRENT_PATH="$1"
CATEGORY="${2,,}"
TORRENT_NAME="$3"
DEST_ROOT="/media_final"
LOG="/config/debug.log"

exec >>"$LOG" 2>&1
echo "--- SCRIPT TRIGGERED $(date '+%F %T') as $(id -un) ($(id -u):$(id -g)) ---" > "$LOG"
echo "1. Path received: $TORRENT_PATH"
echo "2. Category received: $CATEGORY"
echo "3. Name received: $TORRENT_NAME"

if [ ! -e "$TORRENT_PATH" ]; then
    echo "FAILED: '$TORRENT_PATH' does not exist (run this inside the qbittorrent container)"
    exit 1
fi

# Map qBittorrent categories to Jellyfin folders
case "$CATEGORY" in
  "movies") FINAL_DIR="$DEST_ROOT/videos" ;;
  "animated") FINAL_DIR="$DEST_ROOT/animated" ;;
  "shows") FINAL_DIR="$DEST_ROOT/shows" ;;
  "musics") FINAL_DIR="$DEST_ROOT/musics" ;;
  *)
    echo "ABORTED: Category '$CATEGORY' did not match our list. Set the torrent's category in qBittorrent."
    exit 1
    ;;
esac

echo "4. Destination mapped to: $FINAL_DIR"

# Create the folder and COPY the file
echo "5. Copying files..."
if ! mkdir -p "$FINAL_DIR" || cp -rv "$TORRENT_PATH" "$FINAL_DIR/"; then
    echo "FAILED: could not copy into $FINAL_DIR (check PUID/PGID and ownership of shared_media/)"
    exit 1
fi

cp -rv "$TORRENT_PATH" "$FINAL_DIR/"
rc=$?
if [ "$rc" -ne 0 ]; then
    echo "FAILED: cp exited with code $rc while copying into $FINAL_DIR (check PUID/PGID and ownership of shared_media/)"
    exit 1
fi

echo "6. SUCCESS! Script finished."
