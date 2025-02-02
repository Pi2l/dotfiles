#!/usr/bin/env bash

# Configuration
WALLPAPER_DIR="$HOME/.local/share/walls"
CACHE_DIR="$HOME/.cache/wallpaper-selector"
SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
THUMBNAIL_WIDTH=250
THUMBNAIL_HEIGHT=135

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Function to generate thumbnail
generate_thumbnail() {
  ffmpeg -i "$1" -vf "scale=$THUMBNAIL_WIDTH:$THUMBNAIL_HEIGHT:force_original_aspect_ratio=decrease" -q:v 2 "$2" -y >/dev/null 2>&1
}

generate_menu() {

  for wallpaper_path in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    wallpaper_name=$(basename "$wallpaper_path")
    thumbnail_path="$CACHE_DIR/$wallpaper_name"

    # Generate thumbnail if it doesn't exist
    if [ ! -f "$thumbnail_path" ]; then
      generate_thumbnail "$wallpaper_path" "$thumbnail_path"
    fi

    # Displaying .gif to indicate animated images
    echo -en "img:$thumbnail_path\x00info:$(basename "$wallpaper_name")\x1f$wallpaper_name\n"
  done
}

THUMBNAIL_SIZE=32

# Use wofi to display grid of wallpapers
selected=$(
  generate_menu | wofi --show dmenu \
    --cache-file /dev/null \
    --conf ~/.config/wofi/wallpaper.conf
)

# Set wallpaper if one was selected
if [ -n "$selected" ]; then
  # Remove the img: prefix to get the cached thumbnail path
  thumbnail_path="${selected#img:}"

  # Get the original filename from the thumbnail path
  original_filename=$(basename "${thumbnail_path%.*}")

  # Find the corresponding original file in the wallpaper directory
  original_path=$(find "$WALLPAPER_DIR" -type f -name "${original_filename}.*" | head -n1)

  # Set wallpaper
  "$SCRIPTS_DIR"/change-wallpaper.sh load "$original_path"
  "$SCRIPTS_DIR"/change-wallpaper.sh unload-unused

  # Generating wallust templates
  wallust run ~/.local/share/walls/default -u
  "$SCRIPTS_DIR"/refresh.sh

  # Save the selection for persistence
  echo "$original_path" >"$HOME/.cache/current_wallpaper"

  # Optional: Notify user
  notify-send "Wallpaper" "Wallpaper has been updated: '$original_path'" -i "$original_path"
fi
