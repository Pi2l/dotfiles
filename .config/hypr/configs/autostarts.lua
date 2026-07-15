-- #################
-- ### AUTOSTART ###
-- #################
--
-- # Autostart necessary processes (like notifications daemons, status bars, etc.)
-- # Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar & hyprsunset & swaync & hypridle & hyprpaper")
	hl.exec_cmd("/usr/bin/hyprland-per-window-layout")
	hl.exec_cmd("wl-paste")
	hl.exec_cmd("dbus-update-activation-environment")
	hl.exec_cmd("swayosd-server")
	hl.exec_cmd("wl-paste")
	hl.exec_cmd("systemctl --user start hyprland-session.target")

	-- # Power button
	-- # https://github.com/hyprwm/Hyprland/issues/2614#issuecomment-2395597405
	-- exec-once = systemd-inhibit --who="Hyprland config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity & echo $! > /tmp/.hyprland-systemd-inhibit
	-- exec-shutdown = kill -9 "$(cat /tmp/.hyprland-systemd-inhibit)
	hl.exec_cmd("systemd-inhibit --who=\"Hyprland config\" --why=\"wlogout keybind\" --what=handle-power-key --mode=block sleep infinity & echo $! > /tmp/.hyprland-systemd-inhibit")
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
	-- uses a blocking exec function and sleeps a bit to give things time to close
	-- you might also want to kill troublesome/crashing non-systemd background services here:
	-- os.execute("pkill wallpaperthing; systemctl --user stop hyprland-session.target && sleep 0.1")

	os.execute("kill -9 \"$(cat /tmp/.hyprland-systemd-inhibit)\"")
end)
