#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROFILE=$(printf "balanced\npower-saver\nperformance" | wofi --dmenu -p "Power profile")

[ -z "$PROFILE" ] && exit 0

gdbus call --system \
    --dest net.hadess.PowerProfiles \
    --object-path /net/hadess/PowerProfiles \
    --method org.freedesktop.DBus.Properties.Set \
    'net.hadess.PowerProfiles' 'ActiveProfile' "<'$PROFILE'>" > /dev/null

notify-send "Power Profile" "Switched to: $PROFILE" -i battery

HOOK_DIR="$SCRIPT_DIR/hook/$PROFILE"
if [ ! -d "$HOOK_DIR" ] && [ "$PROFILE" = "balanced" ] && [ -d "$SCRIPT_DIR/hook/balance" ]; then
    HOOK_DIR="$SCRIPT_DIR/hook/balance"
fi

if [ -d "$HOOK_DIR" ]; then
    # shopt -s nullglob
    for hook in "$HOOK_DIR"/*; do
        if [ -f "$hook" ] && [ -x "$hook" ]; then
            echo "Running hook: $(basename "$hook")"
            "$hook" "$PROFILE"
        fi
    done
    # shopt -u nullglob
fi
