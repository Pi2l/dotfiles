
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID}
source ~/.config/user-dirs.dirs

# editor
EDITOR=vim

# Starship config file location
export STARSHIP_CONFIG=${XDG_CONFIG_HOME}/starship/starship.toml
export STARSHIP_CACHE=${XDG_CACHE_HOME}/starship

# Set the PATH so it includes user's private bin if it exists
export PATH="$HOME/.local/bin:$PATH"

# Avoid duplicates in history
export HISTCONTROL=ignorespace:erasedups

# History 
export HISTSIZE=100000
export HISTFILE=~/.cache/zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space

# Completion style
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Don't record some commands
export HISTIGNORE="&:[bf]g:exit:history:pwd:clear:cd:cd ..:cd ~:cd -:htop"

# Set less options
export LESS='-R --use-color'

# Set dotfiles dir
export DOTS_DIR="$HOME/.dotfiles/"
