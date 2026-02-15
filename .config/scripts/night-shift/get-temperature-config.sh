#!/bin/bash

# Function to get color temperature configuration and calculate timing
# This script retrieves color temperature settings from theme config and creates
# smooth temperature transitions throughout the night from cooler to warmer colors

# Configuration variables
SCRIPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/scripts"
CONF_FILE="$HOME/.config/theme-switcher/theme.toml"
DEFAULT_TEMPERATURE=3000
MAX_TEMPERATURE=6500
MIN_TEMPERATURE=1000

# Function to log debug information
log_debug() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "[DEBUG] $1" >&2
    fi
}

# Function to validate temperature value (should be between 1000K and 6500K)
validate_temperature() {
    local temp=$1
    if [[ $temp -lt $MIN_TEMPERATURE ]]; then
        echo $MIN_TEMPERATURE
    elif [[ $temp -gt $MAX_TEMPERATURE ]]; then
        echo $MAX_TEMPERATURE
    else
        echo $temp
    fi
}

# Function to get current theme mode
get_current_mode() {
  echo "$("$SCRIPTS_DIR"/helpers/toml/helper-toml.sh read "$theme_file" current mode)"
}

# Function to get sunrise and sunset times
get_sun_times() {
    local retries=3
    for i in $(seq 1 $retries); do
        location_info=$(curl -s --connect-timeout 10 "http://ip-api.com/json/")
        if [[ $? -eq 0 && -n "$location_info" ]]; then
            latitude=$(echo "$location_info" | jq -r .lat 2>/dev/null)
            longitude=$(echo "$location_info" | jq -r .lon 2>/dev/null)
            timezone=$(echo "$location_info" | jq -r .timezone 2>/dev/null)
            
            if [[ -n "$latitude" && -n "$longitude" && -n "$timezone" && "$latitude" != "null" ]]; then
                break
            fi
        fi
        log_debug "Failed to get location info, retry $i/$retries"
        sleep 2
    done
    
    if [[ -z "$latitude" || "$latitude" == "null" ]]; then
        log_debug "Could not get location, using fallback times"
        echo "06:00 18:00"  # Fallback times
        return 1
    fi
    
    # Get sunrise/sunset data
    response=$(curl -s --connect-timeout 10 "https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&formatted=0")
    if [[ $? -ne 0 ]]; then
        log_debug "Failed to get sunrise/sunset data"
        echo "06:00 18:00"  # Fallback times
        return 1
    fi
    
    sunrise_utc=$(echo "$response" | jq -r .results.sunrise 2>/dev/null)
    sunset_utc=$(echo "$response" | jq -r .results.sunset 2>/dev/null)
    
    if [[ -z "$sunrise_utc" || "$sunrise_utc" == "null" ]]; then
        log_debug "Invalid sunrise/sunset data"
        echo "06:00 18:00"  # Fallback times
        return 1
    fi
    
    # Convert to local time
    sunrise_local=$(TZ="$timezone" date -d "$sunrise_utc" +"%H:%M" 2>/dev/null)
    sunset_local=$(TZ="$timezone" date -d "$sunset_utc" +"%H:%M" 2>/dev/null)
    
    if [[ -z "$sunrise_local" || -z "$sunset_local" ]]; then
        log_debug "Failed to convert times to local timezone"
        echo "06:00 18:00"  # Fallback times
        return 1
    fi
    
    echo "$sunrise_local $sunset_local"
    return 0
}

# Function to calculate the time when warmest temperature should be applied
# (halfway between sunset and next sunrise - typically midnight)
calculate_max_temp_time() {
    local sunset_time="$1"
    local sunrise_time="$2"
    
    # Convert times to minutes since midnight
    sunset_minutes=$(date -d "$sunset_time" +"%H" | sed 's/^0*//')
    sunset_minutes=$((${sunset_minutes:-0} * 60))
    sunset_minutes=$((sunset_minutes + $(date -d "$sunset_time" +"%M" | sed 's/^0*//')))
    
    sunrise_minutes=$(date -d "$sunrise_time" +"%H" | sed 's/^0*//')
    sunrise_minutes=$((${sunrise_minutes:-0} * 60))
    sunrise_minutes=$((sunrise_minutes + $(date -d "$sunrise_time" +"%M" | sed 's/^0*//')))
    
    # If sunrise is before sunset (next day), add 24 hours
    if [[ $sunrise_minutes -le $sunset_minutes ]]; then
        sunrise_minutes=$((sunrise_minutes + 1440))  # Add 24 hours in minutes
    fi
    
    # Calculate halfway point
    halfway_minutes=$(((sunset_minutes + sunrise_minutes) / 2))
    
    # Handle overflow (past midnight)
    if [[ $halfway_minutes -ge 1440 ]]; then
        halfway_minutes=$((halfway_minutes - 1440))
    fi
    
    # Convert back to HH:MM format
    halfway_hour=$((halfway_minutes / 60))
    halfway_min=$((halfway_minutes % 60))
    
    printf "%02d:%02d" $halfway_hour $halfway_min
}

# Function to get temperature configuration from theme file
get_temperature_config() {
    local mode="$1"
    local temperature=$DEFAULT_TEMPERATURE
    local from_time=""
    local till_time=""
    
    if [[ -e "$CONF_FILE" ]]; then
        if [[ "$mode" == "Light" ]]; then
            theme_section="light-theme"
        else
            theme_section="dark-theme"
        fi
        
        # Get temperature setting
        temp_config=$("$SCRIPTS_DIR"/helpers/toml/helper-toml.sh read "$CONF_FILE" "$theme_section" sunset-temperature)
        
        if [[ -n "$temp_config" ]]; then
            temperature=$(validate_temperature "$temp_config")
        fi
        
        # Get from-time setting
        from_time=$("$SCRIPTS_DIR"/helpers/toml/helper-toml.sh read "$CONF_FILE" "$theme_section" from-time)
        
        # Get till-time setting
        till_time=$("$SCRIPTS_DIR"/helpers/toml/helper-toml.sh read "$CONF_FILE" "$theme_section" till-time)
    fi
    
    echo "$temperature|$from_time|$till_time"
}

# Function to determine if we should use time-based or sun-based calculation
get_max_temp_timing() {
    local mode="$1"
    local config_result
    local temperature
    local from_time
    local till_time
    local max_temp_time
    
    config_result=$(get_temperature_config "$mode")
    IFS='|' read -r temperature from_time till_time <<< "$config_result"
    
    log_debug "Config result: temp=$temperature, from=$from_time, till=$till_time"
    
    # If both from-time and till-time are specified, use them
    if [[ -n "$from_time" && -n "$till_time" ]]; then
        max_temp_time=$(calculate_max_temp_time "$from_time" "$till_time")
        log_debug "Using configured times: $from_time to $till_time, max at $max_temp_time"
    else
        # Use sunrise/sunset times
        sun_times=$(get_sun_times)
        IFS=' ' read -r sunrise_time sunset_time <<< "$sun_times"
        max_temp_time=$(calculate_max_temp_time "$sunset_time" "$sunrise_time")
        log_debug "Using sun times: sunset=$sunset_time, sunrise=$sunrise_time, max at $max_temp_time"
    fi
    
    echo "$temperature|$max_temp_time"
}

# Function to get current time-based temperature
get_current_temperature() {
    local mode="$1"
    local current_time=$(date +"%H:%M")
    local result
    local min_temperature  # This is the warmest color (lowest Kelvin)
    local midnight_time
    local sunset_time
    local sunrise_time
    
    result=$(get_max_temp_timing "$mode")
    IFS='|' read -r min_temperature midnight_time <<< "$result"
    
    # Get sunset and sunrise times to define the night period
    local config_result
    config_result=$(get_temperature_config "$mode")
    IFS='|' read -r _ from_time till_time <<< "$config_result"
    
    if [[ -n "$from_time" && -n "$till_time" ]]; then
        sunset_time="$from_time"
        sunrise_time="$till_time"
        log_debug "Using configured night period: $sunset_time to $sunrise_time"
    else
        sun_times=$(get_sun_times)
        IFS=' ' read -r sunrise_time sunset_time <<< "$sun_times"
        log_debug "Using sun-based night period: $sunset_time to $sunrise_time"
    fi
    
    # Convert times to minutes for easier calculation
    current_minutes=$(date -d "$current_time" +"%H" | sed 's/^0*//')
    current_minutes=$((${current_minutes:-0} * 60))
    current_minutes=$((current_minutes + $(date -d "$current_time" +"%M" | sed 's/^0*//')))
    
    sunset_minutes=$(date -d "$sunset_time" +"%H" | sed 's/^0*//')
    sunset_minutes=$((${sunset_minutes:-0} * 60))
    sunset_minutes=$((sunset_minutes + $(date -d "$sunset_time" +"%M" | sed 's/^0*//')))
    
    sunrise_minutes=$(date -d "$sunrise_time" +"%H" | sed 's/^0*//')
    sunrise_minutes=$((${sunrise_minutes:-0} * 60))
    sunrise_minutes=$((sunrise_minutes + $(date -d "$sunrise_time" +"%M" | sed 's/^0*//')))
    
    midnight_minutes=$(date -d "$midnight_time" +"%H" | sed 's/^0*//')
    midnight_minutes=$((${midnight_minutes:-0} * 60))
    midnight_minutes=$((midnight_minutes + $(date -d "$midnight_time" +"%M" | sed 's/^0*//')))
    
    # Handle day wrap-around for sunrise
    if [[ $sunrise_minutes -le $sunset_minutes ]]; then
        sunrise_minutes=$((sunrise_minutes + 1440))
    fi
    
    # Handle day wrap-around for midnight
    if [[ $midnight_minutes -le $sunset_minutes ]]; then
        midnight_minutes=$((midnight_minutes + 1440))
    fi
    
    # Handle day wrap-around for current time if needed
    if [[ $current_minutes -lt $sunset_minutes ]]; then
        current_minutes=$((current_minutes + 1440))
    fi
    
    # Define temperature range: cool (higher Kelvin) to warm (lower Kelvin)
    local cool_temp=$((min_temperature + 1500))  # Cooler at sunset/sunrise
    cool_temp=$(validate_temperature "$cool_temp")
    local warm_temp="$min_temperature"           # Warmest at midnight
    
    # Calculate current temperature based on position in night cycle
    if [[ $current_minutes -ge $sunset_minutes && $current_minutes -le $midnight_minutes ]]; then
        # First half of night: sunset to midnight (cooling down / warming up colors)
        local progress=$(((current_minutes - sunset_minutes) * 100 / (midnight_minutes - sunset_minutes)))
        local temp_diff=$((cool_temp - warm_temp))
        current_temp=$((cool_temp - (temp_diff * progress / 100)))
        log_debug "First half of night: progress=${progress}%, cooling from ${cool_temp}K to ${warm_temp}K"
        
    elif [[ $current_minutes -gt $midnight_minutes && $current_minutes -le $sunrise_minutes ]]; then
        # Second half of night: midnight to sunrise (warming up / cooling down colors)
        local progress=$(((current_minutes - midnight_minutes) * 100 / (sunrise_minutes - midnight_minutes)))
        local temp_diff=$((cool_temp - warm_temp))
        current_temp=$((warm_temp + (temp_diff * progress / 100)))
        log_debug "Second half of night: progress=${progress}%, warming from ${warm_temp}K to ${cool_temp}K"
        
    else
        # During day time, use a neutral/higher temperature
        current_temp=$MAX_TEMPERATURE
        log_debug "Daytime: using max temperature ${current_temp}K"
    fi
    
    current_temp=$(validate_temperature "$current_temp")
    log_debug "Final temperature: ${current_temp}K at ${current_time}"
    echo "$current_temp"
}

# Main function
main() {
    local action="$1"
    local mode="${2:-$(get_current_theme_mode)}"
    
    case "$action" in
        "get-config")
            # Return temperature, from-time, till-time
            get_temperature_config "$mode"
            ;;
        "get-max-temp-time")
            # Return max temperature and time when it should be applied
            get_max_temp_timing "$mode"
            ;;
        "get-current-temp")
            # Return current temperature based on time
            get_current_temperature "$mode"
            ;;
        "get-sun-times")
            # Return sunrise and sunset times
            get_sun_times
            ;;
        *)
            echo "Usage: $0 {get-config|get-max-temp-time|get-current-temp|get-sun-times} [Light|Dark]"
            echo ""
            echo "Commands:"
            echo "  get-config       - Get temperature config from theme file"
            echo "  get-max-temp-time - Get max temperature and time to apply it"
            echo "  get-current-temp - Get current temperature based on time curve"
            echo "  get-sun-times    - Get sunrise and sunset times"
            echo ""
            echo "Theme modes: Light, Dark (default: current mode from cache)"
            echo ""
            echo "Environment variables:"
            echo "  DEBUG_MODE=true  - Enable debug output"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

