#!/bin/bash
## /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##

# Paths
WALLPAPER_BASE_PATH="$HOME/Pictures/wallpapers/Dynamic-Wallpapers"
DARK_WALLPAPERS="$WALLPAPER_BASE_PATH/Dark"
LIGHT_WALLPAPERS="$WALLPAPER_BASE_PATH/Light"
SWAYNC_STYLE="$HOME/.config/swaync/style.css"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
BELL_ICON="$HOME/.config/swaync/images/bell.png"

KITTY_CONF="$HOME/.config/kitty/kitty.conf"

if [ ! -z $1 ]; then
  NEXT_MODE="$1"
else
  theme_file="$HOME/.config/theme-switcher/theme.toml"

  mode=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" current mode)
  echo "mode: $mode"

  if [[ "$mode" == "Light" || "$mode" == "light" ]]; then
    NEXT_MODE="Dark"
    # Logic for Dark mode
    wallpaper_path="$DARK_WALLPAPERS"
  else
    NEXT_MODE="Light"
    # Logic for Light mode
    wallpaper_path="$LIGHT_WALLPAPERS"
  fi
fi

# Function to update theme mode for the next cycle
update_theme_mode() {
  ~/.config/scripts/helpers/toml/helper-toml.sh write "$theme_file" current mode "$NEXT_MODE"
}

# Function to notify user
notify_user() {
  notify-send -u low -t 3000 "Themes in $NEXT_MODE mode" "GTK Theme: $selected_theme\nGTK Icon: $selected_icon"
}

WALLUST_CONFIG="$HOME/.config/wallust/wallust.toml"
PALLETE_DARK="dark16"
PALLETE_LIGHT="light16"
# Use sed to replace the palette setting in the wallust config file
if [ "$NEXT_MODE" = "Dark" ]; then
  sed -i 's/^palette = .*/palette = "'"$PALLETE_DARK"'"/' "$WALLUST_CONFIG"
else
  sed -i 's/^palette = .*/palette = "'"$PALLETE_LIGHT"'"/' "$WALLUST_CONFIG"
fi

# Function to set Waybar style; TODO:
# set_waybar_style() {
#     theme="$1"
#     waybar_styles="$HOME/.config/waybar/style"
#     waybar_style_link="$HOME/.config/waybar/style.css"
#     style_prefix="\\[${theme}\\].*\\.css$"
#
#     style_file=$(find "$waybar_styles" -maxdepth 1 -type f -regex ".*$style_prefix" | shuf -n 1)
#
#     if [ -n "$style_file" ]; then
#         ln -sf "$style_file" "$waybar_style_link"
#     else
#         echo "Style file not found for $theme theme."
#     fi
# }

# GTK themes and icons switching
set_custom_gtk_theme() {
  mode=$1
  gtk_themes_directory="$HOME/.themes"
  icon_directory="$HOME/.local/share/icons"
  color_setting="org.gnome.desktop.interface color-scheme"
  theme_setting="org.gnome.desktop.interface gtk-theme"
  icon_setting="org.gnome.desktop.interface icon-theme"
  cursor_setting="org.gnome.desktop.interface cursor-theme"

  # Define the file path
  theme_file="$HOME/.config/theme-switcher/theme.toml"
  if [ "$mode" == "Light" ]; then
    search_keywords="*Light*"
    selected_color="default"
  elif [ "$mode" == "Dark" ]; then
    search_keywords="*Dark*"
    selected_color="prefer-dark"
  else
    selected_color="default"
    echo "Invalid mode provided. Set to default: 'default'"
    return 1
  fi

  themes=()
  icons=()

  if [[ -e "$theme_file" ]]; then
    if [[ "$mode" == "Light" ]]; then
      theme_section="light-theme"
    else
      theme_section="dark-theme"
    fi

    # Parse the theme and icon values from the file
    selected_theme=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" gtk-theme)
    selected_icon=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" gtk-icon)
    selected_cursor=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" gtk-cursor)

    # Validate that themes were found
    if [[ ! -n "$selected_theme" || ! -n "$selected_icon" || ! -n "$selected_cursor" ]]; then
      echo "Error: Failed to parse theme settings from $theme_file"
      exit 1
    fi
    echo "GTK Theme: $selected_theme"
    echo "GTK Icon: $selected_icon"
    echo "GTK Cursor: $selected_cursor"
  else
    notify-send "Config file not found! Searched at: $theme_file; File layout: [dark-theme]\ngtk-theme='...'\ngtk-icon='...'\n[light-theme]\ngtk-theme='...'\ngtk-icon='...'"
    while IFS= read -r -d '' theme_search; do
      themes+=("$(basename "$theme_search")")
    done < <(find "$gtk_themes_directory" -maxdepth 1 -type d -iname "$search_keywords" -print0)

    while IFS= read -r -d '' icon_search; do
      icons+=("$(basename "$icon_search")")
    done < <(find "$icon_directory" -maxdepth 1 -type d -iname "$search_keywords" -print0)

    if [ ${#themes[@]} -gt 0 ]; then
      if [ "$mode" == "Dark" ]; then
        selected_theme=${themes[RANDOM % ${#themes[@]}]}
      else
        selected_theme=${themes[$RANDOM % ${#themes[@]}]}
      fi
      echo "Selected GTK theme for $mode mode: $selected_theme"
    else
      echo "No $mode GTK theme found"
    fi

    if [ ${#icons[@]} -gt 0 ]; then
      if [ "$mode" == "Dark" ]; then
        selected_icon=${icons[RANDOM % ${#icons[@]}]}
      else
        selected_icon=${icons[$RANDOM % ${#icons[@]}]}
      fi
      echo "Selected icon theme for $mode mode: $selected_icon"

      ## QT5ct icon_theme
      sed -i "s|^icon_theme=.*$|icon_theme=$selected_icon|" "$HOME/.config/qt5ct/qt5ct.conf"
      sed -i "s|^icon_theme=.*$|icon_theme=$selected_icon|" "$HOME/.config/qt6ct/qt6ct.conf"

    else
      echo "No $mode icon theme found"
    fi
  fi

  # Apply the themes using gsettings
  gsettings set $color_setting "$selected_color"
  gsettings set $theme_setting "$selected_theme"
  gsettings set $icon_setting "$selected_icon"
  gsettings set $cursor_setting "$selected_cursor"

  # Flatpak GTK apps (themes)
  if command -v flatpak &>/dev/null; then
    flatpak --user override --filesystem=$HOME/.themes
    sleep 0.5
    flatpak --user override --env=GTK_THEME="$selected_theme"
  fi

  # Flatpak GTK apps (icons)
  if command -v flatpak &>/dev/null; then
    flatpak --user override --filesystem=$HOME/.icons
    sleep 0.5
    flatpak --user override --env=ICON_THEME="$selected_icon"
  fi

}

set_hyprland_theme() {
    mode=$1
    icon_directory="$HOME/.local/share/icons"

    # Define the file path
    theme_file="$HOME/.config/theme-switcher/theme.toml"
    if [ "$mode" == "Light" ]; then
        search_keywords="*Light*"
        selected_color="default"
    elif [ "$mode" == "Dark" ]; then
        search_keywords="*Dark*"
        selected_color="prefer-dark"
    else
        selected_color="default"
        echo "Invalid mode provided. Set to default: 'default'"
        return 1
    fi

    if [[ -e "$theme_file"  ]]; then
    # && -e "$SCRIPTSDIR"/shared/functions.sh hyprland_running
        if [[ "$mode" == "Light" ]]; then
            theme_section="light-theme"
        else
            theme_section="dark-theme"
        fi

        # Parse the theme and icon values from the file
        selected_cursor=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" gtk-cursor) # can be added hypr-cursor to config to have cursor per DE
        selected_cursor_size=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" cursor-size)

        # Validate that themes were found
        if [[ ! -n "$selected_cursor" ]]; then
            echo "Error: Failed to parse theme settings from $theme_file"
            exit 1
        fi
            echo "Hypr Cursor: $selected_cursor"
            echo "Hypr Cursor size: $selected_cursor_size"
        else
            notify-send "Config file not found! Searched at: $theme_file; File layout: [dark-theme]\ngtk-theme='...'\ngtk-icon='...'\n[light-theme]\ngtk-theme='...'\ngtk-icon='...'"

        # Apply the themes using hypr
        hyprctl setcursor "$selected_cursor" 24 # "$selected_cursor_size" # fix size
    fi
}

set_wallpaper() {
  mode="$1"
  theme_file="$HOME/.config/theme-switcher/theme.toml"

  if [[ -e "$theme_file" ]]; then
    if [[ "$mode" == "Light" ]]; then
      theme_section="light-theme"
    else
      theme_section="dark-theme"
    fi

    background_path=$(~/.config/scripts/helpers/toml/helper-toml.sh read "$theme_file" "$theme_section" background)
    echo "background: $background_path"
    "$SCRIPTSDIR"/change-wallpaper.sh load "$background_path"
    "$SCRIPTSDIR"/change-wallpaper.sh unload-unused
  fi
}

set_custom_gtk_theme "$NEXT_MODE"
set_hyprland_theme "$NEXT_MODE"
update_theme_mode
set_wallpaper "$NEXT_MODE"

wallust run ~/.local/share/walls/default -u
$SCRIPTSDIR/refresh.sh

wait $!
notify_user

exit 0
