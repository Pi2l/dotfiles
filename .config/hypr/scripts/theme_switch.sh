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
  # Determine current theme mode
  if [ "$(cat $HOME/.cache/.theme_mode)" = "Light" ]; then
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
  echo "$NEXT_MODE" >~/.cache/.theme_mode
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

# swaync color change
# if [ "$next_mode" = "Dark" ]; then
#     sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(0, 0, 0, 0.8);/' "${SWAYNC_STYLE}"
#     sed -i '/@define-color noti-bg-alt/s/#.*;/#111111;/' "${SWAYNC_STYLE}"
# else
#     sed -i '/@define-color noti-bg/s/rgba([0-9]*,\s*[0-9]*,\s*[0-9]*,\s*[0-9.]*);/rgba(255, 255, 255, 0.9);/' "${SWAYNC_STYLE}"
#     sed -i '/@define-color noti-bg-alt/s/#.*;/#F0F0F0;/' "${SWAYNC_STYLE}"
# fi

# kitty background color change
# if [ "$next_mode" = "Dark" ]; then
#     sed -i '/^foreground /s/^foreground .*/foreground #dddddd/' "${KITTY_CONF}"
#     sed -i '/^background /s/^background .*/background #000000/' "${KITTY_CONF}"
#     sed -i '/^cursor /s/^cursor .*/cursor #dddddd/' "${KITTY_CONF}"
# else
#     sed -i '/^foreground /s/^foreground .*/foreground #000000/' "${KITTY_CONF}"
#     sed -i '/^background /s/^background .*/background #dddddd/' "${KITTY_CONF}"
#     sed -i '/^cursor /s/^cursor .*/cursor #000000/' "${KITTY_CONF}"
# fi
# for pid in $(pidof kitty); do
#     kill -SIGUSR1 "$pid"
# done

# Set Dynamic Wallpaper for Dark or Light Mode
# if [ "$next_mode" = "Dark" ]; then
#     next_wallpaper="$(find "${DARK_WALLPAPERS}" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | shuf -n1 -z | xargs -0)"
# else
#     next_wallpaper="$(find "${LIGHT_WALLPAPERS}" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | shuf -n1 -z | xargs -0)"
# fi

# Update wallpaper using swww command
# $swww "${next_wallpaper}" $effect

# Set Kvantum Manager theme & QT5/QT6 settings
# if [ "$NEXT_MODE" = "Dark" ]; then
#   kvantum_theme="Catppuccin-Mocha"
#   qt5ct_color_scheme="$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf"
#   qt6ct_color_scheme="$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf"
# else
#   kvantum_theme="Catppuccin-Latte"
#   qt5ct_color_scheme="$HOME/.config/qt5ct/colors/Catppuccin-Latte.conf"
#   qt6ct_color_scheme="$HOME/.config/qt6ct/colors/Catppuccin-Latte.conf"
# fi
#
# sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt5ct_color_scheme|" "$HOME/.config/qt5ct/qt5ct.conf"
# sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt6ct_color_scheme|" "$HOME/.config/qt6ct/qt6ct.conf"
# kvantummanager --set "$kvantum_theme"

# GTK themes and icons switching
set_custom_gtk_theme() {
  mode=$1
  gtk_themes_directory="$HOME/.themes"
  icon_directory="$HOME/.icons"
  color_setting="org.gnome.desktop.interface color-scheme"
  theme_setting="org.gnome.desktop.interface gtk-theme"
  icon_setting="org.gnome.desktop.interface icon-theme"

  # Define the file path
  theme_file="$HOME/.config/theme-switcher/theme"
  if [ "$mode" == "Light" ]; then
    search_keywords="*Light*"
    selected_color="prefer-light"
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
      theme_section="[light-theme]"
    else
      theme_section="[dark-theme]"
    fi

    # Parse the theme and icon values from the file
    selected_theme=$(awk -v section="$theme_section" '
            $0 == section {found=1} 
            found && $0 ~ /gtk-theme=/ {gsub(/gtk-theme=|'\''/,""); print; exit}
            ' "$theme_file")

    selected_icon=$(awk -v section="$theme_section" '
            $0 == section {found=1} 
            found && $0 ~ /gtk-icon=/ {gsub(/gtk-icon=|'\''/,""); print; exit}
            ' "$theme_file")

    # Validate that themes were found
    if [[ ! -n "$selected_theme" || ! -n "$selected_icon" ]]; then
      echo "Error: Failed to parse theme settings from $theme_file"
      exit 1
    fi
    echo "GTK Theme: $selected_theme"
    echo "GTK Icon: $selected_icon"
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

update_sunset() {
  MODE=$1
  CONF_FILE="$HOME/.config/theme-switcher/theme"
  TEMPERATURE=5000

  if [[ -e "$CONF_FILE" ]]; then
    if [[ "$mode" == "Light" ]]; then
      theme_section="[light-theme]"
    else
      theme_section="[dark-theme]"
    fi
    CONF_TEMPERATURE=$(awk -v section="$theme_section" '
              $0 == section {found=1} 
              found && $0 ~ /sunset-temperature=/ {gsub(/sunset-temperature=|'\''/,""); print; exit}
              ' "$CONF_FILE")
    if [[ -z "$CONF_TEMPERATURE" ]]; then
      TEMPERATURE=5000
    else
      TEMPERATURE="$CONF_TEMPERATURE"
    fi
  fi

  pkill hyprsunset
  if [ "$MODE" == "Dark" ]; then
    hyprsunset -t $TEMPERATURE &
  else
    hyprsunset -t $TEMPERATURE & # TODO: add check if themperature is more than 6000K
  fi
}

set_custom_gtk_theme "$NEXT_MODE"

update_theme_mode
update_sunset "$NEXT_MODE"

wallust run ~/.local/share/walls/default -u
$SCRIPTSDIR/refresh.sh

wait $!
notify_user

exit 0
