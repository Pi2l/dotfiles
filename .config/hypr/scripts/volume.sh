#!/bin/bash

# Get the current sink (output device)
DEFAULT_SINK=$(pactl get-default-sink)

# Get the current volume percentage of the default sink
CURRENT_VOLUME=$(pactl get-sink-volume "$DEFAULT_SINK" | grep -oP '\d+%' | head -1 | tr -d '%')

# Get the current mute status
IS_MUTED=$(pactl get-sink-mute "$DEFAULT_SINK" | awk '{print $2}')

# Function to increase volume, capped at 100%
volume_up() {
    if (( CURRENT_VOLUME < 100 )); then
        pactl set-sink-volume "$DEFAULT_SINK" +5%
    fi
}

# Function to decrease volume and toggle mute if volume reaches 0%
volume_down() {
    if (( CURRENT_VOLUME > 0 )); then
        pactl set-sink-volume "$DEFAULT_SINK" -5%
        # Refresh volume after change
        CURRENT_VOLUME=$(pactl get-sink-volume "$DEFAULT_SINK" | grep -oP '\d+%' | head -1 | tr -d '%')
    fi

    # if (( CURRENT_VOLUME == 0 && "$IS_MUTED" == "no" )); then
    #         notify-send "CURRENT_VOLUME == 0 $(echo $("$IS_MUTED" == "no"))"
    #     pactl set-sink-mute "$DEFAULT_SINK" toggle
    # fi
}

# Parse command-line arguments.
case "$1" in
    up)
        volume_up
        ;;
    down)
        volume_down
        ;;
    *)
        echo "Usage: $0 {up|down}"
        ;;
esac

