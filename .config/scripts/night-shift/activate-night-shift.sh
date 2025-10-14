#!/bin/bash

# Night Shift Activation Script
# This script applies color temperature changes using hyprsunset based on theme mode
# and configuration settings. It calculates the appropriate temperature based on 
# the time of day and applies it smoothly.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_SCRIPT="$SCRIPT_DIR/get-temperature-config.sh"

# Configuration
MIN_TEMP=1000
MAX_TEMP=6500
DEFAULT_TEMP=3000

# Function to log messages
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Function to check if hyprsunset is available
check_hyprsunset() {
    if ! command -v hyprsunset >/dev/null 2>&1; then
        log_error "hyprsunset is not installed or not in PATH"
        return 1
    fi
    return 0
}

# Function to get current theme mode
get_current_mode() {
    if [[ -f "$HOME/.cache/.theme_mode" ]]; then
        cat "$HOME/.cache/.theme_mode"
    else
        echo "Dark"
    fi
}

# Function to validate temperature
validate_temp() {
    local temp=$1
    if [[ $temp -lt $MIN_TEMP ]]; then
        echo $MIN_TEMP
    elif [[ $temp -gt $MAX_TEMP ]]; then
        echo $MAX_TEMP
    else
        echo $temp
    fi
}

# Function to safely kill existing hyprsunset processes
kill_hyprsunset() {
    local pids
    pids=$(pgrep hyprsunset 2>/dev/null)
    
    if [[ -n "$pids" ]]; then
        log_info "Stopping existing hyprsunset processes: $pids"
        pkill hyprsunset
        sleep 0.5
        
        # Force kill if still running
        pids=$(pgrep hyprsunset 2>/dev/null)
        if [[ -n "$pids" ]]; then
            log_info "Force killing stubborn hyprsunset processes"
            pkill -9 hyprsunset
            sleep 0.2
        fi
    fi
}

# Function to apply color temperature
apply_temperature() {
    local temp=$1
    local mode="$2"
    
    temp=$(validate_temp "$temp")
    
    log_info "Applying color temperature: ${temp}K for $mode mode"
    
    # Kill existing processes
    kill_hyprsunset
    
    # Start hyprsunset with new temperature
    if [[ "$mode" == "Light" && $temp -ge 6000 ]]; then
        # For light mode with high temperature, don't apply filter
        log_info "Light mode with high temperature (${temp}K), skipping filter"
        return 0
    fi
    
    # Apply temperature filter
    nohup hyprsunset -t "$temp" >/dev/null 2>&1 &
    local pid=$!
    
    # Check if it started successfully
    sleep 0.5
    if kill -0 "$pid" 2>/dev/null; then
        log_info "Successfully started hyprsunset (PID: $pid) with temperature ${temp}K"
        return 0
    else
        log_error "Failed to start hyprsunset"
        return 1
    fi
}

# Function to get appropriate temperature based on current time and config
get_appropriate_temperature() {
    local mode="$1"
    local temp
    
    if [[ -x "$CONFIG_SCRIPT" ]]; then
        temp=$(bash "$CONFIG_SCRIPT" get-current-temp "$mode" 2>/dev/null)
        if [[ $? -eq 0 && -n "$temp" && "$temp" =~ ^[0-9]+$ ]]; then
            echo "$temp"
            return 0
        else
            log_error "Failed to get temperature from config script"
        fi
    else
        log_error "Config script not found or not executable: $CONFIG_SCRIPT"
    fi
    
    # Fallback to default temperature
    echo "$DEFAULT_TEMP"
}

# Function to update color temperature based on theme mode
update_night_shift() {
    local mode="$1"
    local force_temp="$2"
    local temperature
    
    if [[ -n "$force_temp" ]]; then
        temperature="$force_temp"
        log_info "Using forced temperature: ${temperature}K"
    else
        temperature=$(get_appropriate_temperature "$mode")
        log_info "Calculated temperature for $mode mode: ${temperature}K"
    fi
    
    apply_temperature "$temperature" "$mode"
}

# Function to disable night shift
disable_night_shift() {
    log_info "Disabling night shift"
    kill_hyprsunset
}

# Function to get status
get_status() {
    local pids
    pids=$(pgrep hyprsunset 2>/dev/null)
    
    if [[ -n "$pids" ]]; then
        echo "Night shift is active (PID: $pids)"
        return 0
    else
        echo "Night shift is not active"
        return 1
    fi
}

# Function to show current configuration
show_config() {
    local mode
    mode=$(get_current_mode)
    
    echo "Current theme mode: $mode"
    
    if [[ -x "$CONFIG_SCRIPT" ]]; then
        echo "Configuration:"
        local config_result
        config_result=$(bash "$CONFIG_SCRIPT" get-config "$mode" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            IFS='|' read -r temp from_time till_time <<< "$config_result"
            echo "  Min temperature (warmest): ${temp}K"
            echo "  From time: ${from_time:-auto}"
            echo "  Till time: ${till_time:-auto}"
        fi
        
        local max_temp_result
        max_temp_result=$(bash "$CONFIG_SCRIPT" get-max-temp-time "$mode" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            IFS='|' read -r max_temp max_time <<< "$max_temp_result"
            echo "  Warmest temp time: $max_time"
        fi
        
        local current_temp
        current_temp=$(bash "$CONFIG_SCRIPT" get-current-temp "$mode" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo "  Current calculated temp: ${current_temp}K"
        fi
    else
        echo "Config script not available"
    fi
    
    get_status
}

# Main function
main() {
    local action="$1"
    local mode_or_temp="$2"
    local force_temp="$3"
    
    # Check dependencies
    if ! check_hyprsunset; then
        exit 1
    fi
    
    case "$action" in
        "enable"|"on"|"activate")
            local mode="${mode_or_temp:-$(get_current_mode)}"
            update_night_shift "$mode" "$force_temp"
            ;;
        "disable"|"off"|"deactivate")
            disable_night_shift
            ;;
        "update"|"refresh")
            local mode="${mode_or_temp:-$(get_current_mode)}"
            update_night_shift "$mode" "$force_temp"
            ;;
        "status")
            show_config
            ;;
        "temp")
            if [[ -n "$mode_or_temp" && "$mode_or_temp" =~ ^[0-9]+$ ]]; then
                local mode=$(get_current_mode)
                update_night_shift "$mode" "$mode_or_temp"
            else
                log_error "Invalid temperature value: $mode_or_temp"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {enable|disable|update|status|temp} [mode|temperature] [force_temp]"
            echo ""
            echo "Commands:"
            echo "  enable [Light|Dark] [temp]  - Enable night shift for specified mode"
            echo "  disable                     - Disable night shift"
            echo "  update [Light|Dark] [temp]  - Update/refresh night shift"
            echo "  status                      - Show current status and configuration"
            echo "  temp <value>                - Set specific temperature (1000-6500K)"
            echo ""
            echo "Examples:"
            echo "  $0 enable                   - Enable with current mode"
            echo "  $0 enable Dark              - Enable for dark mode"
            echo "  $0 enable Dark 3000         - Enable for dark mode with 3000K"
            echo "  $0 temp 2500                - Set temperature to 2500K"
            echo "  $0 status                   - Show current configuration"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"