alias g='git'

# add
alias ga='git add'
alias gaa='git add .'

# status
alias gst='git status'
alias gss='git status -s'

# log
alias gl='git log'
alias glo='git log --oneline --color'
alias glog='git log --oneline --color --graph'
alias glg='git log --graph --decorate --color'
alias glgga='git log --graph --decorate --all'

# restore
alias gr='git restore'
alias gra='git restore .'
alias grs='git restore --staged'
alias grsa='git restore --staged .'

# fetch
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfp='git fetch --prune'
alias gft='git fetch --tags'

# checkout
alias gc='git checkout'
alias gcb='git checkout -b'

# reset
alias gres='git reset' 
alias gresh='git reset HEAD~' # git reset HEAD~ to undo last commit and make commited files to be staged

# pull
alias gpl='git pull'

# push
alias gp='git push'
