# Night Shift System - Complete Setup Guide

This is a fully automated color temperature management system that works with your theme switching setup.

## 🎯 What It Does

- **Smooth Temperature Transitions**: Creates natural color temperature curves throughout the night
- **Theme Integration**: Different temperature settings for Light/Dark modes
- **Automatic Updates**: Systemd timer updates temperature every 15 minutes
- **Location Aware**: Uses your location for accurate sunrise/sunset times
- **Robust**: Handles network failures, service restarts, and theme changes

## 🚀 Quick Start

### 1. Enable Automatic Updates
```bash
cd ~/.dotfiles/.config/scripts/night-shift
./manage-services.sh enable-timer
```

### 2. Check Status
```bash
./manage-services.sh status
```

### 3. Manual Control (Optional)
```bash
# Set specific temperature
./activate-night-shift.sh temp 3000

# Update based on current time
./activate-night-shift.sh update

# Show current configuration
./activate-night-shift.sh status
```

## 📊 Current System Status

**Configuration File**: `~/.config/theme-switcher/theme.toml`
```ini
[dark-theme]
sunset-temperature=4700  # Warmest colors (lowest Kelvin)

[light-theme]  
sunset-temperature=6000  # Less warm for light theme
```

**Temperature Curve** (Dark Mode Example):
- **Sunset (18:31)**: 6200K (cooler colors)
- **Evening (21:00)**: ~5500K (gradually warming)
- **Late Night (01:02)**: 4700K (warmest/most amber)
- **Early Morning (04:00)**: ~5500K (cooling back down)
- **Sunrise (07:33)**: 6200K (cool colors)
- **Daytime**: 6500K (minimal filtering)

## 🔧 System Components

### Scripts
- `get-temperature-config.sh` - Core calculation engine
- `activate-night-shift.sh` - Main control script  
- `manage-services.sh` - Systemd service manager
- `night-shift-daemon.sh` - Continuous monitoring daemon

### Systemd Services
- `night-shift.timer` - Runs every 15 minutes (enabled)
- `night-shift.service` - Updates color temperature
- `night-shift-daemon.service` - Alternative continuous monitoring

### Configuration
- `~/.config/theme-switcher/theme.toml` - Main config file
- `~/.cache/.night_shift_temp` - Last applied temperature

## 🎮 Service Management

### Enable/Disable Services
```bash
# Enable timer (recommended - low resource usage)
./manage-services.sh enable-timer

# Enable daemon (advanced - instant theme detection)  
./manage-services.sh enable-daemon

# Disable all automatic services
./manage-services.sh disable
```

### Monitoring
```bash
# Show complete status
./manage-services.sh status

# View service logs
./manage-services.sh logs timer

# Check timer schedule
systemctl --user list-timers night-shift.timer
```

## 🛠️ Troubleshooting

### Service Issues
```bash
# Restart active service
./manage-services.sh restart

# Check service status
systemctl --user status night-shift.service

# View detailed logs
journalctl --user -u night-shift.service -f
```

### Manual Testing
```bash
# Test temperature calculation
./get-temperature-config.sh get-current-temp Dark

# Test sunrise/sunset detection  
./get-temperature-config.sh get-sun-times

# Apply specific temperature
./activate-night-shift.sh temp 3000
```

### Common Issues

1. **hyprsunset not running after timer**: Fixed with `setsid` and `RemainAfterExit=yes`
2. **Temperature not changing**: Check timer schedule with `systemctl --user list-timers`
3. **Wrong colors**: Verify config file syntax and temperature values (1000-6500K)

## 📈 Integration Examples

### With Theme Switcher
Your existing `theme_switch.sh` can trigger immediate updates:
```bash
# At the end of theme_switch.sh
~/.dotfiles/.config/scripts/night-shift/activate-night-shift.sh update "$NEXT_MODE"
```

### Custom Time Ranges
Override sunrise/sunset with fixed times in config:
```ini
[dark-theme]
sunset-temperature=4000
from-time=20:00
till-time=06:00
```

### Debug Mode
Enable detailed logging:
```bash
DEBUG_MODE=true ./get-temperature-config.sh get-current-temp Dark
```

## ✅ Verification

Your system is working correctly when:
- Timer shows next scheduled run: `systemctl --user list-timers night-shift.timer`
- hyprsunset process is running: `pgrep hyprsunset`
- Temperature changes over time: `./get-temperature-config.sh get-current-temp Dark`
- Status shows active service: `./manage-services.sh status`

## 🎨 Current Live Status

```bash
# Run this to see your current system state:
cd ~/.dotfiles/.config/scripts/night-shift && \
echo "Time: $(date '+%H:%M')" && \
echo "Mode: $(cat ~/.config/theme-switcher/theme.toml 2>/dev/null || echo 'Unknown')" && \
echo "Current Temp: $(./get-temperature-config.sh get-current-temp Dark)K" && \
echo "hyprsunset PID: $(pgrep hyprsunset || echo 'Not running')" && \
echo "Next Update: $(systemctl --user list-timers night-shift.timer --no-pager | awk 'NR==2{print $1, $2}')"
```

The system is now fully automated and will smoothly adjust your screen's color temperature throughout the night! 🌙✨
