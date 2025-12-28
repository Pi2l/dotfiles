#!/bin/bash

SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/"
HYPR_SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"

increase_brightness() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --brightness "+$step"
  else
    brightnessctl s "${step}%+"
    $SCRIPTS_DIR/notification/notify-user.sh brightness
  fi
}

decrease_brightness() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --brightness "-$step"
  else
    brightnessctl s "${step}%-"
    $SCRIPTS_DIR/notification/notify-user.sh brightness
  fi
}

command="$1"
step="$2"

if [[ -z "$step" ]]; then
  step="10"
fi

# Ensure the step is a valid number
if ! [[ "$step" =~ ^[0-9]+$ ]]; then
  echo "Error: Step value must be a positive integer."
  exit 1
fi

case "$command" in
increase)
  increase_brightness "$step"
  ;;
decrease)
  decrease_brightness "$step"
  ;;
*)
  echo "Usage: $0 {increase|decrease} <step>"
  ;;
esac
