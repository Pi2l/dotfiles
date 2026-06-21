-- #####################
-- ### LOOK AND FEEL ###
-- #####################
--
-- # Refer to https://wiki.hyprland.org/Configuring/Variables/
--
local configs = "lua/configs"
-- # https://wiki.hyprland.org/Configuring/Variables/#general
-- require("~/.cache/wallust/colors-hyprland.lua")
local colors = dofile(os.getenv("HOME") .. "/.cache/wallust/colors-hyprland.lua")
hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 10,

    border_size = 2,

      -- # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
      -- # col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
      -- # col.inactive_border = rgba(595959aa)
      col = {
        active_border = { colors = { colors.color6, colors.color12 }, angle = 45 },
        inactive_border = { colors = { colors.color8, colors.color10 }, angle = 45 },
      },

      -- # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = false,

      -- # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      allow_tearing = false,
      layout = dwindle,
  },
  group = {
    col = {
      border_active = { colors = { "rgba(ca0ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
      border_inactive = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
      border_locked_active = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
      border_locked_inactive = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
    }
  },
  decoration = {
    rounding = 10,

    -- # Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 0.9,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)"
    },

    -- # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696
    }
}

})

-- # https://wiki.hyprland.org/Configuring/Variables/#decoration
require(configs .. "/animations")

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})

-- # https://wiki.hyprland.org/Configuring/Variables/#misc
hl.config({
  misc = {
    force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
  },
})
