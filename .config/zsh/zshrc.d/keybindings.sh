autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

# Navigation
# Bind Home key to move to the beginning of the line
bindkey "^[[H" beginning-of-line

# Bind End key to move to the end of the line (optional)
bindkey "^[[F" end-of-line

# Bind Ctrl + Left Arrow to move one word backward
bindkey "^[[1;5D" backward-word
