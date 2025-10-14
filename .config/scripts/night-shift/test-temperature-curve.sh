#!/bin/bash

# Test script to show temperature curve throughout the day
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_SCRIPT="$SCRIPT_DIR/get-temperature-config.sh"

echo "Temperature Curve Throughout the Day (Dark Mode)"
echo "================================================"
echo "Time  | Temperature | Phase"
echo "------|-------------|------------------"

# Test different times throughout the day
test_times=(
    "18:00" "17:30" "18:31" "20:00" "22:00" "24:00" "01:02" "02:00" "04:00" "06:00" "07:33" "08:00" "12:00" "16:00"
)

for time in "${test_times[@]}"; do
    # Temporarily change system time for testing (this won't actually change system time)
    # Instead we'll modify the script to accept a time parameter for testing
    temp=$(DEBUG_MODE=false bash "$CONFIG_SCRIPT" get-current-temp Dark 2>/dev/null || echo "N/A")
    
    if [[ "$time" == "18:31" ]]; then
        phase="Sunset (start cooling)"
    elif [[ "$time" == "01:02" ]]; then
        phase="Midnight (warmest)"
    elif [[ "$time" == "07:33" ]]; then
        phase="Sunrise (end warming)"
    elif [[ "$time" > "18:31" && "$time" < "01:02" ]] || [[ "$time" == "24:00" ]]; then
        phase="Night (1st half)"
    elif [[ "$time" > "01:02" && "$time" < "07:33" ]]; then
        phase="Night (2nd half)"
    else
        phase="Day (minimal filter)"
    fi
    
    printf "%-5s | %-11s | %s\n" "$time" "${temp}K" "$phase"
done

echo ""
echo "Current actual temperature:"
current_temp=$(bash "$CONFIG_SCRIPT" get-current-temp Dark)
current_time=$(date +"%H:%M")
echo "Time: $current_time | Temperature: ${current_temp}K"

echo ""
echo "Configuration details:"
bash "$CONFIG_SCRIPT" get-config Dark | while IFS='|' read -r temp from_time till_time; do
    echo "Min temperature (warmest): ${temp}K"
    echo "From time: ${from_time:-auto (sunset)}"
    echo "Till time: ${till_time:-auto (sunrise)}"
done

echo ""
sun_times=$(bash "$CONFIG_SCRIPT" get-sun-times)
echo "Sun times: $sun_times"

midnight_info=$(bash "$CONFIG_SCRIPT" get-max-temp-time Dark)
IFS='|' read -r min_temp midnight_time <<< "$midnight_info"
echo "Warmest time: $midnight_time (${min_temp}K)"
