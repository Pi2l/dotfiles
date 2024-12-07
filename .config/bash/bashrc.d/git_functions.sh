
# checkout N times backwards
gsn() {
	if [ -z "$1" ]; then
		echo "Checking out once\n"
		echo "Usage: gsn <number>"
		git checkout -
		return 0
	fi
	git checkout "@{-$1}"
}

# get gitignore for a specific language
gitignore() {
  curl -L -s https://www.gitignore.io/api/"$@" >.gitignore
} 
