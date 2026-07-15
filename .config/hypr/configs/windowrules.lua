
-- # common modals
-- windowrule = float on,match:modal true

-- # Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ name = "ignore-maximize", match = { class = "*" }, suppress_event = "maximize" })

-- # To see class, title, etc, use 'hyprctl clients'
hl.window_rule({ match = { class = "com.github.tchx84.Flatseal" }, float = true })
hl.window_rule({ match = { class = "gnome-power-statistics" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, size = { 800, 500 } })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Nautilus" }, size = { 1200, 600 } })
hl.window_rule({ match = { class = "nwg-look" }, float = true })
hl.window_rule({ match = { class = "nwg-look" }, size = { 1000, 500 } })
hl.window_rule({ match = { class = "org.gnome.FileRoller" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, size = { 1200, 500 } })
hl.window_rule({ match = { class = "com.saivert.pwvucontrol" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Loupe" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Loupe" }, size = { 800, 500 } })

-- modals
hl.window_rule({ match = { modal = true }, float = true })