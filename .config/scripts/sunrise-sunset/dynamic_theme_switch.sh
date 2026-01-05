#!/bin/bash

time_to_min() {
  local h m
  IFS=: read -r h m <<<"$1"
  echo $((10#$h * 60 + 10#$m))
}

MAX=${MAX:-5}
for i in $(seq 1 "$MAX"); do
  # Variables
  theme_file="$HOME/.config/light-dark-theme/theme"
  location_info=$(curl -s http://ip-api.com/json/)
  latitude=$(echo "$location_info" | jq -r .lat)
  longitude=$(echo "$location_info" | jq -r .lon)
  timezone=$(echo "$location_info" | jq -r .timezone)

  if [[ -n "$latitude" && -n "$longitude" && -n "$timezone" ]]; then
    break
  fi
  echo "Network not ready. Retrying in 5 seconds... ($i/$MAX)"
  sleep 5
done

# Check location retrieval
if [[ -z "$latitude" || -z "$longitude" || -z "$timezone" ]]; then
  echo "Error: Could not retrieve location information."
  echo "Failed due to: latitude: '$latitude'; longitude: '$longitude'; timezone: '$timezone'"
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
ct=$(time_to_min "$current_time")
sr=$(time_to_min "$sunrise_local")
ss=$(time_to_min "$sunset_local")

# Determine next action
if ((ct < ss && (sr <= ct || ct <= sr))); then
  mode="Light"
  next_trigger="$sunset_local"
else
  mode="Dark"
  next_trigger="$sunrise_local"
fi

# Apply the current theme
"$HOME/.config/hypr/scripts/theme_switch.sh" "$mode"

# Schedule the next trigger
next_trigger_iso="*-*-* $(date -d "$next_trigger" +"%H:%M")"

# Dynamically create the timer file
timer_file="$HOME/.config/systemd/user/theme-switch.timer"
cat >"$timer_file" <<EOF
[Unit]
Description=Dynamic Theme Switcher

[Timer]
Unit=theme-switch.service
OnCalendar=$next_trigger_iso
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload systemd and restart the timer
systemctl --user daemon-reload
systemctl --user restart theme-switch.timer

echo "Next trigger at: $next_trigger_iso"
