# checkout N times backwards
gcn() {
  if [ -z "$1" ]; then
    echo "Checking out once"
    echo "Usage: gsn <number>"
    git checkout -
    return 0
  fi
  git checkout "@{-$1}"
}

# get gitignore for a specific language
gitignore() {
  local joined_args
  joined_args=$(
    IFS=,
    echo "$*"
  )
  curl -L -s https://www.gitignore.io/api/"$joined_args" >.gitignore
}
