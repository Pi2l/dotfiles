# Night Shift Scripts Documentation

This directory contains bash scripts for managing color temperature based on theme mode and time of day.

## Scripts

### 1. `get-temperature-config.sh`
This script retrieves color temperature configuration and calculates timing based on theme mode and sunrise/sunset times.

#### Usage
```bash
./get-temperature-config.sh {get-config|get-max-temp-time|get-current-temp|get-sun-times} [Light|Dark]
```

#### Commands
- `get-config` - Get temperature config from theme file
- `get-max-temp-time` - Get max temperature and time when it should be applied
- `get-current-temp` - Get current temperature based on time curve
- `get-sun-times` - Get sunrise and sunset times

#### Examples
```bash
# Get current configuration for Dark mode
./get-temperature-config.sh get-config Dark
# Output: 4700||  (temperature|from-time|till-time)

# Get maximum temperature time
./get-temperature-config.sh get-max-temp-time Dark
# Output: 4700|01:02  (max-temp|time-to-apply)

# Get current calculated temperature
./get-temperature-config.sh get-current-temp Dark
# Output: 2094

# Get sunrise and sunset times
./get-temperature-config.sh get-sun-times
# Output: 07:33 18:31
```

### 2. `activate-night-shift.sh`
This script applies color temperature changes using hyprsunset based on the configuration.

#### Usage
```bash
./activate-night-shift.sh {enable|disable|update|status|temp} [mode|temperature] [force_temp]
```

#### Commands
- `enable [Light|Dark] [temp]` - Enable night shift for specified mode
- `disable` - Disable night shift
- `update [Light|Dark] [temp]` - Update/refresh night shift
- `status` - Show current status and configuration
- `temp <value>` - Set specific temperature (1000-6500K)

#### Examples
```bash
# Enable with current mode
./activate-night-shift.sh enable

# Enable for dark mode
./activate-night-shift.sh enable Dark

# Enable for dark mode with specific temperature
./activate-night-shift.sh enable Dark 3000

# Set specific temperature
./activate-night-shift.sh temp 2500

# Show current status and configuration
./activate-night-shift.sh status

# Disable night shift
./activate-night-shift.sh disable
```

## Configuration File

The scripts read configuration from `$HOME/.config/theme-switcher/theme.toml`.

### Format
```ini
[dark-theme]
gtk-theme='Theme-Name-Dark'
gtk-icon='Icon-Name-Dark'
sunset-temperature='4700'
# Optional: custom time range instead of sunrise/sunset
# from-time='20:00'
# till-time='06:00'

[light-theme]
gtk-theme='Theme-Name-Light'
gtk-icon='Icon-Name-Light'
sunset-temperature='6000'
# Optional: custom time range instead of sunrise/sunset
# from-time='18:00'
# till-time='08:00'
```

### Configuration Options

- `sunset-temperature` - Maximum color temperature in Kelvin (1000-6500)
- `from-time` - Start time for night shift (optional, uses sunset if not specified)
- `till-time` - End time for night shift (optional, uses sunrise if not specified)

## How It Works

### Temperature Calculation
1. **Theme-based**: Each theme mode (Light/Dark) can have its own minimum temperature setting (warmest colors)
2. **Time-based**: If `from-time` and `till-time` are specified, uses those times instead of sunrise/sunset
3. **Sun-based**: Automatically fetches sunrise/sunset times based on your location
4. **Night curve**: Creates smooth temperature transitions throughout the night period
5. **Natural flow**: Cooler colors at sunset/sunrise, warmest colors at midnight

### Temperature Curve
The script creates a natural night temperature curve:
- **Sunset**: Starts with cooler colors (higher Kelvin, e.g., 5200K)
- **First half of night** (sunset → midnight): Gradually warms up to minimum temperature (e.g., 4700K → warmest)
- **Midnight**: Reaches the warmest/most amber colors (lowest Kelvin from config)
- **Second half of night** (midnight → sunrise): Gradually cools back down
- **Sunrise**: Returns to cooler colors (higher Kelvin)
- **Daytime**: Uses maximum temperature (6500K) - minimal filtering

### Location Detection
- Uses `ip-api.com` to detect your location
- Falls back to default times (06:00 sunrise, 18:00 sunset) if location detection fails
- Automatically converts UTC times to your local timezone

## Environment Variables

- `DEBUG_MODE=true` - Enable debug output to see detailed calculations

## Dependencies

- `hyprsunset` - For applying color temperature
- `curl` - For fetching location and sunrise/sunset data  
- `jq` - For parsing JSON responses
- `awk` - For parsing configuration files

## Integration

### With Theme Switcher
The activation script can be called from your theme switching script:

```bash
# In your theme_switch.sh
source /path/to/activate-night-shift.sh
update_night_shift "$NEXT_MODE"
```

### With Systemd (Automatic Updates)

The scripts include pre-configured systemd user services for automatic operation:

#### Timer Service (Recommended)
Updates every 15 minutes with minimal resource usage:
```bash
# Enable timer-based updates
./manage-services.sh enable-timer

# Check status
./manage-services.sh status

# View logs
journalctl --user -u night-shift.service -f
```

#### Daemon Service (Advanced)
Continuous monitoring with instant theme change detection:
```bash
# Enable daemon-based updates
./manage-services.sh enable-daemon

# Check status and logs
./manage-services.sh logs daemon
```

#### Service Management
```bash
# Show current status
./manage-services.sh status

# Disable all automatic services
./manage-services.sh disable

# Restart active service
./manage-services.sh restart
```

The systemd services are configured to:
- Keep `hyprsunset` running after service completion (`RemainAfterExit=yes`)
- Automatically restart on failure
- Use proper session detachment (`setsid`) to prevent process cleanup
- Update temperature every 15 minutes (timer) or continuously (daemon)

### Manual Usage
```bash
# Quick temperature adjustment
./activate-night-shift.sh temp 2000

# Check current status
./activate-night-shift.sh status

# Refresh based on current time
./activate-night-shift.sh update
```
