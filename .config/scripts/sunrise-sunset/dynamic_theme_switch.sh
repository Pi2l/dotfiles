#!/bin/bash

# Variables
theme_file="$HOME/.config/light-dark-theme/theme"
location_info=$(curl -s http://ip-api.com/json/)
latitude=$(echo "$location_info" | jq -r .lat)
longitude=$(echo "$location_info" | jq -r .lon)
timezone=$(echo "$location_info" | jq -r .timezone)

# Check location retrieval
if [[ -z "$latitude" || -z "$longitude" || -z "$timezone" ]]; then
    echo "Error: Could not retrieve location information."
    exit 1
fi

# Fetch sunrise and sunset times
response=$(curl -s "https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&formatted=0")
sunrise_utc=$(echo "$response" | jq -r .results.sunrise)
sunset_utc=$(echo "$response" | jq -r .results.sunset)

# Convert UTC to local time
sunrise_local=$(TZ="$timezone" date -d "$sunrise_utc" +"%H:%M")
sunset_local=$(TZ="$timezone" date -d "$sunset_utc" +"%H:%M")

# Get current time
current_time=$(date +"%H:%M")

# Determine next action
if [[ $(date -d "$current_time" +%s) -ge $(date -d "$sunrise_local" +%s) && $(date -d "$current_time" +%s) -le $(date -d "$sunset_local" +%s)  ]]; then
    mode="Light"
    next_trigger="$sunrise_local"
elif [[ $(date -d "$current_time" +%s) -ge $(date -d "$sunset_local" +%s) ]]; then
    mode="Dark"
    next_trigger="$sunset_local"
else
    mode="Dark"
    next_trigger=$(date -d "tomorrow $sunrise_local" +"%H:%M")
fi

# Apply the current theme
"$HOME/.config/hypr/scripts/theme_switch.sh" "$mode"

# Schedule next run
next_trigger_iso=$(date -d "$next_trigger" --iso-8601=seconds)
echo "Next trigger at: $next_trigger_iso"
systemctl --user set-property theme-switch.timer OnCalendar="$next_trigger_iso"
systemctl --user start theme-switch.timer

