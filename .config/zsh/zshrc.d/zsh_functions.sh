# create tmp dir and cd to it
function cdtmp() {
  cd $(mktemp -d)
}

function edit() {
  # Edit a file with the default editor
  local file=$(find . -type f | fzf) && ${EDITOR:-nvim} "$file"
}

function kproc() {
  # Kill a process by name
  local pid=$(ps -ef | sed 1d | fzf | awk '{print $2}')
  if [ -n "$pid" ]; then
    kill -9 "$pid"
  fi
}

# function to create symbolic link from source to target
function slink() {
  local sorce=$1
  local target=$2

  if [[ -z "$sorce" || -z "$target" ]]; then
    echo "usage: slink <sourse> <target>"
  else
    ln -sv "$sorce" "$target"
  fi
}
