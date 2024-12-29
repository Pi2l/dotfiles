#!/bin/bash

# File containing fan status (replace this with the actual path)
FAN_STATUS_FILE="/proc/acpi/ibm/fan"

# Read the file
if [[ -f "$FAN_STATUS_FILE" ]]; then
  # Extract data from the file
  status=$(grep "status:" "$FAN_STATUS_FILE" | awk '{print $2}')
  speed=$(grep "speed:" "$FAN_STATUS_FILE" | awk '{print $2}')
  level=$(grep "level:" "$FAN_STATUS_FILE" | awk '{print $2}')

  icon=""

  # Output for Waybar
  echo "{\"text\": \"$icon $speed RPM\", \"tooltip\": \"Status: $status\nSpeed: $speed\nLevel: $level\", \"class\": \"$status\", \"icon\": \"$icon\"}"
else
  echo "{\"text\": \"Error\", \"tooltip\": \"Fan status file not found\", \"class\": \"error\", \"icon\": \"❗\"}"
fi
