#
# ~/.bash_profile

# Get the aliases and functions
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}
if [ -f "$CONFIG_DIR/bash/.bashrc" ]; then
    . "$CONFIG_DIR/bash/.bashrc"
fi
# or find it at home
[[ -f ~/.bashrc ]] && . ~/.bashrc
