#!/bin/bash

notify() {
  local timeout=$1
  local icon=$2
  local notify_send_hint=$3
  local title=$4
  local message=$5

  # notify-send "timeout: $timeout; icon: $icon; hint: $notify_send_hint; message: $message"
  notify-send -u low -t "$timeout" -i "$icon" -h "$notify_send_hint" "$title" "$message"
}

notify_volume() {
  # Get volume and mute state
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1 | tr -d '%')
  is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

  # Determine icon and message
  if [ "$is_muted" = "yes" ]; then
    icon="audio-volume-muted"
    message="Muted"
  elif [ "$volume" -le 33 ]; then
    icon="audio-volume-low"
    message="Volume: $volume%"
  elif [ "$volume" -le 66 ]; then
    icon="audio-volume-medium"
    message="Volume: $volume%"
  else
    icon="audio-volume-high"
    message="Volume: $volume%"
  fi

  # Send notification
  notify "3000" "$icon" "string:x-canonical-private-synchronous:volume" "Volume" "$message"
}

notify_mic() {
  volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1 | tr -d '%')
  is_muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

  # Determine icon and message
  if [ "$is_muted" = "yes" ]; then
    icon="microphone-sensitivity-muted"
    message="Muted"
  elif [ "$volume" -le 33 ]; then
    icon="microphone-sensitivity-low"
    message="Microphone: $volume%"
  elif [ "$volume" -le 66 ]; then
    icon="microphone-sensitivity-medium"
    message="Microphone: $volume%"
  else
    icon="microphone-sensitivity-high"
    message="Microphone: $volume%"
  fi

  # Send notification
  notify-send -u low -t 3000 -i "$icon" -h string:x-canonical-private-synchronous:mic "Microphone" "$message"
}

notify_brightness() {
  # Get current brightness percentage
  brightness=$(brightnessctl g)
  max_brightness=$(brightnessctl m)
  brightness_percent=$((brightness * 100 / max_brightness))

  # Determine icon based on brightness level
  if [ "$brightness_percent" -le 20 ]; then
    icon="display-brightness-low"
  elif [ "$brightness_percent" -le 60 ]; then
    icon="display-brightness-medium"
  else
    icon="display-brightness-high"
  fi

  # Send notification
  notify "3000" "$icon" "string:x-canonical-private-synchronous:brightness" "Brightness" "Level: $brightness_percent%"
}

case "$1" in
volume)
  notify_volume
  ;;
microphone)
  notify_mic
  ;;
brightness)
  notify_brightness
  ;;
*) ;;
esac
