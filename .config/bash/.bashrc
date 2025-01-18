#!/usr/bin/env bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f /etc/bashrc ] && source /etc/bashrc

CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
PROFILE_FILE="$CONFIG_DIR/.profile.sh"
[ -f "$PROFILE_FILE" ] && source "$PROFILE_FILE"

# source aliases, completion etc
while read -r f; do source "$f"; done < <(find "$CONFIG_DIR/bash/bashrc.d/" -name "*.sh")

# Startship init
eval "$(starship init zsh)"

#rust
. "$HOME/.cargo/env"
