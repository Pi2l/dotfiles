#!/bin/bash

SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts"

load() {
  local WALL="$1"

  if [[ "$WALL" == "~/.local/share/walls/default" ]]; then
    exit 0
  fi

  hyprctl hyprpaper preload "$WALL"
  hyprctl hyprpaper wallpaper ",$WALL"
  # hyprctl hyprpaper wallpaper mon , path "$WALL"

  echo "changing to $WALL"
  write_background_into_settings "$WALL"
  ln -sfv "$WALL" ~/.local/share/walls/default
}

unload_unused() {
  hyprctl hyprpaper unload unused
}

write_background_into_settings() {
  local wall="$1"
  theme_file="$HOME/.config/theme-switcher/theme.toml"

  mode=$("$SCRIPTS_DIR"/helpers/toml/helper-toml.sh read "$theme_file" current mode)
  echo "mode: $mode"

  if [[ "$mode" == "Light" || "$mode" == "light" ]]; then
    section="light-theme"
  elif [[ "$mode" == "Dark" || "$mode" == "dark" ]]; then
    section="dark-theme"
  else
    echo "Unknown mode: $mode"
    exit 1
  fi

  "$SCRIPTS_DIR"/helpers/toml/helper-toml.sh write "$theme_file" "$section" background "$wall"
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
