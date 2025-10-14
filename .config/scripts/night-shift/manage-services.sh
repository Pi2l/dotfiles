#!/bin/bash

# Night Shift Service Manager - Simple version
# Manages systemd user services for automatic night shift updates

show_status() {
    echo "Night Shift Services Status:"
    echo "============================"
    
    echo -e "\n📅 Timer Service (every 15 minutes):"
    printf "  Enabled: "
    systemctl --user is-enabled night-shift.timer 2>/dev/null || echo "disabled"
    printf "  Active:  "
    systemctl --user is-active night-shift.timer 2>/dev/null || echo "inactive"
    
    echo -e "\n🔄 Daemon Service (continuous):"
    printf "  Enabled: "
    systemctl --user is-enabled night-shift-daemon.service 2>/dev/null || echo "disabled"
    printf "  Active:  "
    systemctl --user is-active night-shift-daemon.service 2>/dev/null || echo "inactive"
    
    echo -e "\n📊 Current Night Shift:"
    "$(dirname "$0")/activate-night-shift.sh" status | grep -E "(Current|calculated|Night shift)"
}

enable_timer() {
    echo "Enabling timer-based service (updates every 15 minutes)..."
    systemctl --user stop night-shift-daemon.service 2>/dev/null
    systemctl --user disable night-shift-daemon.service 2>/dev/null
    systemctl --user enable night-shift.timer
    systemctl --user start night-shift.timer
    echo "✅ Timer service enabled!"
}

enable_daemon() {
    echo "Enabling daemon service (continuous monitoring)..."
    systemctl --user stop night-shift.timer 2>/dev/null
    systemctl --user disable night-shift.timer 2>/dev/null
    systemctl --user enable night-shift-daemon.service
    systemctl --user start night-shift-daemon.service
    echo "✅ Daemon service enabled!"
}

disable_all() {
    echo "Disabling all services..."
    systemctl --user stop night-shift.timer night-shift-daemon.service 2>/dev/null
    systemctl --user disable night-shift.timer night-shift-daemon.service 2>/dev/null
    echo "✅ All services disabled."
}

case "$1" in
    "status") show_status ;;
    "enable-timer") enable_timer ;;
    "enable-daemon") enable_daemon ;;
    "disable") disable_all ;;
    "logs")
        case "$2" in
            "timer") journalctl --user -u night-shift.service -f ;;
            "daemon") journalctl --user -u night-shift-daemon.service -f ;;
            *) echo "Usage: $0 logs {timer|daemon}" ;;
        esac
        ;;
    *)
        echo "Night Shift Service Manager"
        echo "=========================="
        echo "Usage: $0 {status|enable-timer|enable-daemon|disable|logs}"
        echo ""
        echo "Commands:"
        echo "  status        - Show service status"
        echo "  enable-timer  - Enable 15-minute updates"
        echo "  enable-daemon - Enable continuous monitoring" 
        echo "  disable       - Disable all services"
        echo "  logs timer    - Show timer logs"
        echo "  logs daemon   - Show daemon logs"
        ;;
esac