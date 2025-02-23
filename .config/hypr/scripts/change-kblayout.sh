#!/usr/bin/bash

KB_DEVICE="at-translated-set-2-keyboard"

get_current_layout() {
  echo $(hyprctl devices -j | jq '.keyboards.[] | select(.main == true).active_keymap')
}

notify_current_kb_layout() {
  notify-send -u low -t 500 "$(get_current_layout)"
  # $SCRIPTS_DIR/notification/notify-user.sh kblayout $(get_current_layout)
}

toggle_kb_layout() {
  hyprctl switchxkblayout "$KB_DEVICE" next
}

change_kb_layout() {
  local kb_index="$1"
  hyprctl switchxkblayout "$KB_DEVICE" "$kb_index"
}

case "$1" in
notify)
  notify_current_kb_layout
  ;;
toggle)
  toggle_kb_layout
  notify_current_kb_layout
  ;;
change-kb)
  change_kb_layout "$1"
  notify_current_kb_layout
  ;;
*)
  echo "Usage: $0 {toggle|change-kb <kb_index>}"
  ;;
esac
