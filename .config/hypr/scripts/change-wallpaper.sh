#!/bin/bash

load() {
  local WALL="$1"
  hyprctl hyprpaper preload "$WALL"
  hyprctl hyprpaper wallpaper ",$WALL"

  ln -sfv "$WALL" ~/.local/share/walls/default
}

unload_unused() {
  hyprctl hyprpaper unload unused
}

WALLPAPER="$2"

if [[ -z $WALLPAPER || ! -f $WALLPAPER ]]; then
  WALLPAPER=~/.local/share/walls/default
fi

# Parse command-line arguments.
case "$1" in
load)
  load "$WALLPAPER"
  ;;
unload-unused)
  unload_unused
  ;;
*)
  echo "Usage: $0 [load <absolute path to wallpaper>|unload-unused]"
  ;;
esac
