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
