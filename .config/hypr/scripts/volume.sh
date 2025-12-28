#!/bin/bash

SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts/"
HYPR_SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/"
# Get the current sink (output device)
DEFAULT_SINK=$(pactl get-default-sink)

# Get the current volume percentage of the default sink
CURRENT_VOLUME=$(pactl get-sink-volume "$DEFAULT_SINK" | grep -oP '\d+%' | head -1 | tr -d '%')

command="$1"
step="$2"

if [[ -z "$step" ]]; then
  step="5"
fi

# Ensure the step is a valid number
if ! [[ "$step" =~ ^[0-9]+$ ]]; then
  echo "Error: Step value must be a positive integer."
  exit 1
fi

# Function to increase volume, capped at 100%
volume_up() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --output-volume "$step"
  else
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
      pactl set-sink-mute @DEFAULT_SINK@ 0
    fi

    if ((CURRENT_VOLUME < 100)); then
      pactl set-sink-volume "$DEFAULT_SINK" +"$step"%
    fi
    $SCRIPTS_DIR/notification/notify-user.sh volume
  fi
}

volume_up_pipewire() {
  local step=$1

  if "$(wpctl get-volume @DEFAULT_SINK@)" | grep 'MUTED'; then
    wpctl set-mute @DEFAULT_SINK@ 0
  fi

  local CURRENT_VOLUME=$(wpctl get-volume "$DEFAULT_SINK" | awk '{print $2}')
  local step_float=$(awk -v s="$step" 'BEGIN { printf "%.4f", s / 100 }')

  # Only increase if below 1.0 (100%)
  if awk -v vol="$CURRENT_VOLUME" 'BEGIN { exit !(vol < 1.0) }'; then
    wpctl set-volume "$DEFAULT_SINK" "+$step_float"
  fi
}

# Function to decrease volume and toggle mute if volume reaches 0%
volume_down() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --output-volume "-$step"
  else
    pactl set-sink-volume "$DEFAULT_SINK" -"$step"%
    if ((CURRENT_VOLUME > 0)); then
      # Refresh volume after change
      CURRENT_VOLUME=$(pactl get-sink-volume "$DEFAULT_SINK" | grep -oP '\d+%' | head -1 | tr -d '%')
    fi

    if [[ $CURRENT_VOLUME -eq 0 && "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: no" ]]; then
      # pactl set-sink-mute "$DEFAULT_SINK" toggle
      toggle_volume
    fi
    $SCRIPTS_DIR/notification/notify-user.sh volume
  fi
}

toggle_volume() {
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --output-volume mute-toggle
  else
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    $SCRIPTS_DIR/notification/notify-user.sh volume
  fi
}

toggle_microphone() {
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --input-volume mute-toggle
  else
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    $SCRIPTS_DIR/notification/notify-user.sh microphone
  fi
}

mute() {
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --input-volume mute-toggle
  else
    pactl set-sink-mute @DEFAULT_SINK@ 1
    $SCRIPTS_DIR/notification/notify-user.sh volume
  fi
}

unmute() {
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --input-volume mute-toggle
  else
    pactl set-sink-mute @DEFAULT_SINK@ 0
    $SCRIPTS_DIR/notification/notify-user.sh volume
  fi
}

microphone_volume_up() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --input-volume "$step"
  else
    DEFAULT_SOURCE=$(pactl info | grep 'Default Source' | awk '{print $3}')
    CURRENT_MIC_VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')

    if [ "$(pactl get-source-mute @DEFAULT_SOURCE@)" = "Mute: yes" ]; then
      # pactl set-source-mute @DEFAULT_SOURCE@ 0
      return
    fi

    if ((CURRENT_MIC_VOLUME < 100)); then
      pactl set-source-volume "$DEFAULT_SOURCE" +"$step"%
    fi
    $SCRIPTS_DIR/notification/notify-user.sh microphone
  fi
}

microphone_volume_down() {
  local step=$1
  $HYPR_SCRIPTS_DIR/shared/shared/osd.sh has-swayosd

  if echo $?; then
    swayosd-client --input-volume "-$step"
  else
    DEFAULT_SOURCE=$(pactl info | grep 'Default Source' | awk '{print $3}')
    CURRENT_MIC_VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')

    if [ "$(pactl get-source-mute @DEFAULT_SOURCE@)" = "Mute: yes" ]; then
      return
    fi

    if ((CURRENT_MIC_VOLUME > 0)); then
      pactl set-source-volume "$DEFAULT_SOURCE" -"$step"%
      # Refresh volume after change
      CURRENT_MIC_VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')
    fi

    if [[ $CURRENT_MIC_VOLUME -eq 0 && "$(pactl get-source-mute @DEFAULT_SOURCE@)" = "Mute: no" ]]; then
      toggle_microphone
    fi
    $SCRIPTS_DIR/notification/notify-user.sh microphone
  fi

}
# Parse command-line arguments.
case "$1" in
up)
  volume_up "$step"
  ;;
down)
  volume_down "$step"
  ;;
toggle-volume)
  toggle_volume
  ;;
toggle-microphone)
  toggle_microphone
  ;;
mute)
  mute
  ;;
unmute)
  unmute
  ;;
mic-up)
  microphone_volume_up "$step"
  ;;
mic-down)
  microphone_volume_down "$step"
  ;;
*)
  echo "Usage: $0 {(up|down [<step>])|toggle-volume|unmute|mute|toggle-microphone}"
  ;;
esac
