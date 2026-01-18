#!/bin/bash

# sudo vim /etc/udev/rules.d/99-thinkpad-leds.rules:
# SUBSYSTEM=="leds", KERNEL=="platform::micmute", ACTION=="add", RUN+="/bin/chmod 666 /sys/class/leds/%k/brightness"
# or sudo chmod 666 /sys/devices/platform/thinkpad_acpi/leds/platform::micmute/brightness

IS_MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
LED_PATH="/sys/devices/platform/thinkpad_acpi/leds/platform::micmute/brightness"

if [ "$IS_MUTED" = "yes" ]; then
  echo 1 >"$LED_PATH"
else
  echo 0 >"$LED_PATH"
fi
