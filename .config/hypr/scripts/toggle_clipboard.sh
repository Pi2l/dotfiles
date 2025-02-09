#!/bin/bash

if [[ -n $1 ]]; then
  if [[ "$1" = "disable" ]]; then
    pkill wl-copy && pkill wl-paste
    notify-send "Clipboard" "Clipboard disabled"
  elif [ "$1" = "enable" ]; then
    wl-paste --watch cliphist store &
    notify-send "Clipboard" "Clipboard enabled"
  fi
else
  echo "Usage: toggle_clipboard.sh [enable|disable]"
fi

# To wipe:
# cliphist wipe
