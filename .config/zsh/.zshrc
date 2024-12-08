#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f /etc/zshrc ] && source /etc/zshrc

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
PROFILE_FILE="$CONFIG_DIR/.zprofile.sh"
[ -f "$PROFILE_FILE" ] && source "$PROFILE_FILE"

# source aliases, completion etc
while read -r f; do source "$f"; done < <(find "$CONFIG_DIR/zsh/zshrc.d/" -name "*.sh")

# Startship init
eval "$(starship init zsh)"
