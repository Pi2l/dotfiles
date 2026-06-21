-- ###################
-- ### KEYBINDINGS ###
-- ###################
--
-- # See https://wiki.hyprland.org/Configuring/Keywords/
local mainMod = "SUPER" -- # Sets "Windows" key as main modifier
local scriptsDir = "$HOME/.config/hypr/scripts"
local generalScriptsDir = "$HOME/.config/scripts"

-- # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("pkill waybar; waybar &")) -- tmp
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + G", hl.dsp.window.float())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(scriptsDir .. "/theme_switch.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(scriptsDir .. "/wofi-wallpaper-selector.sh"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(scriptsDir .. "/change-kblayout.sh notify"))

-- # Clipbord
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy")) -- select from clipboard
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist delete")) -- delete from clipboard
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd(scriptsDir .. "/toggle_clipboard.sh disable")) -- disable clipboard
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(scriptsDir .. "/toggle_clipboard.sh enable")) -- enable clipboard

-- # Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- # Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

-- # Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- # Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scriptsDir .. "/volume.sh up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scriptsDir .. "/volume.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(scriptsDir .. "/volume.sh mute && $generalScriptsDir/bin/mic-toggle-led.sh"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(scriptsDir .. "/volume.sh toggle-microphone"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh decrease"), { locked = true, repeating = true })

-- # Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- # to switch between windows in a floating workspace
-- hl.bind(mainMod .. " + Tab", function ()
--   hl.dsp.window.cycle_next()
--   hl.dsp.focus({ last = true })
-- end)

-- # Screenshot
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only")) -- Screenshot a window
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output")) -- Screenshot a monitor
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only")) -- Screenshot a region

-- # Notification
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw")) -- toggle notification center
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -C")) -- clear all notification
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("swaync-client -d")) -- toggle dnd

-- # Power button
-- # https://github.com/hyprwm/Hyprland/issues/2614#issuecomment-2395597405
-- exec-once = systemd-inhibit --who="Hyprland config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity & echo $! > /tmp/.hyprland-systemd-inhibit
-- exec-shutdown = kill -9 "$(cat /tmp/.hyprland-systemd-inhibit)
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("systemctl suspend"))
