-- ################
-- ### MONITORS ###
-- ################
--
-- # See https://wiki.hyprland.org/Configuring/Monitors/
-- monitor=,preferred,auto,1.25
-- monitor=eDP-1,1920x1200@60,auto,1.2

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "auto",
	scale = 1.2,
})
