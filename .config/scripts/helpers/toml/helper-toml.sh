#!/bin/bash

# --- 1. CONFIGURATION ---
VENV_DIR="$HOME/.cache/helper_toml_venv"

# --- 2. SELF-BOOTSTRAP LOGIC ---
if [ ! -f "$VENV_DIR/bin/python3" ] || ! "$VENV_DIR/bin/python3" -c "import toml" &>/dev/null; then
  echo " > First run detected. Setting up private Python environment..." >&2
  rm -rf "$VENV_DIR"
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install toml --quiet --disable-pip-version-check
fi

# --- 3. PYTHON SCRIPT EXECUTION ---
"$VENV_DIR/bin/python3" ~/.config/scripts/helpers/toml/helper-toml.py "$@"
