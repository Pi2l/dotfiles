#!/bin/bash

SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/"

increase_brightness() {
  local step=$1
  brightnessctl s "${step}%+"
}

decrease_brightness() {
  local step=$1
  brightnessctl s "${step}%-"
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
  $SCRIPTS_DIR/notification/notify-user.sh brightness
  ;;
decrease)
  decrease_brightness "$step"
  $SCRIPTS_DIR/notification/notify-user.sh brightness
  ;;
*)
  echo "Usage: $0 {increase|decrease} <step>"
  ;;
esac
