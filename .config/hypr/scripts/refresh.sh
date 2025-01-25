# Kill already running processes
_ps=(waybar wofi swaync)
for _prs in "${_ps[@]}"; do
  if pidof "${_prs}" >/dev/null; then
    pkill "${_prs}"
  fi
done

# sleep 0.5
#Restart waybar
waybar &

# relaunch swaync
swaync >/dev/null 2>&1 &
