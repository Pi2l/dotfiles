#!/bin/bash

# Night Shift Daemon
# Continuously monitors theme changes and updates color temperature automatically

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
ACTIVATE_SCRIPT="$SCRIPT_DIR/activate-night-shift.sh"
THEME_CACHE="$HOME/.cache/.theme_mode"
TEMP_CACHE="$HOME/.cache/.night_shift_temp"
UPDATE_INTERVAL=60  # Update every 60 seconds
THEME_CHECK_INTERVAL=5  # Check theme changes every 5 seconds

# Function to log messages with timestamp
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Function to get current theme mode
get_current_mode() {
    if [[ -f "$THEME_CACHE" ]]; then
        cat "$THEME_CACHE"
    else
        echo "Dark"
    fi
}

# Function to get last applied temperature
get_last_temp() {
    if [[ -f "$TEMP_CACHE" ]]; then
        cat "$TEMP_CACHE"
    else
        echo "0"
    fi
}

# Function to save last applied temperature
save_last_temp() {
    echo "$1" > "$TEMP_CACHE"
}

# Function to check if hyprsunset is running
is_hyprsunset_running() {
    pgrep hyprsunset >/dev/null 2>&1
}

# Function to update night shift
update_night_shift() {
    local mode="$1"
    local force_update="$2"
    
    if [[ ! -x "$ACTIVATE_SCRIPT" ]]; then
        log_error "Activate script not found or not executable: $ACTIVATE_SCRIPT"
        return 1
    fi
    
    # Get current calculated temperature
    local current_temp
    current_temp=$(bash "$SCRIPT_DIR/get-temperature-config.sh" get-current-temp "$mode" 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$current_temp" ]]; then
        log_error "Failed to get current temperature"
        return 1
    fi
    
    local last_temp
    last_temp=$(get_last_temp)
    
    # Check if update is needed
    local temp_diff=$((current_temp - last_temp))
    temp_diff=${temp_diff#-}  # Get absolute value
    
    if [[ "$force_update" == "true" ]] || [[ $temp_diff -ge 50 ]] || ! is_hyprsunset_running; then
        log_info "Updating night shift: $mode mode, ${current_temp}K (was ${last_temp}K)"
        
        if bash "$ACTIVATE_SCRIPT" update "$mode" >/dev/null 2>&1; then
            save_last_temp "$current_temp"
            log_info "Successfully updated to ${current_temp}K"
        else
            log_error "Failed to update night shift"
            return 1
        fi
    fi
    
    return 0
}

# Function to handle cleanup on exit
cleanup() {
    log_info "Night shift daemon stopping..."
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Main daemon loop
main() {
    log_info "Night shift daemon starting..."
    
    # Initial variables
    local last_mode
    local current_mode
    local last_update=0
    local theme_check_counter=0
    
    # Get initial mode
    last_mode=$(get_current_mode)
    log_info "Initial theme mode: $last_mode"
    
    # Force initial update
    update_night_shift "$last_mode" "true"
    
    while true; do
        current_mode=$(get_current_mode)
        local current_time=$(date +%s)
        
        # Check for theme mode changes every few seconds
        if [[ $theme_check_counter -ge $THEME_CHECK_INTERVAL ]]; then
            if [[ "$current_mode" != "$last_mode" ]]; then
                log_info "Theme mode changed: $last_mode -> $current_mode"
                update_night_shift "$current_mode" "true"
                last_mode="$current_mode"
                last_update=$current_time
            fi
            theme_check_counter=0
        fi
        
        # Regular temperature updates
        if [[ $((current_time - last_update)) -ge $UPDATE_INTERVAL ]]; then
            if update_night_shift "$current_mode" "false"; then
                last_update=$current_time
            fi
        fi
        
        # Sleep and increment counter
        sleep 1
        ((theme_check_counter++))
    done
}

# Check dependencies
if ! command -v hyprsunset >/dev/null 2>&1; then
    log_error "hyprsunset is not installed or not in PATH"
    exit 1
fi

# Start daemon
main "$@"
