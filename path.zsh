# Add directories to the PATH and prevent to add the same directory multiple times upon shell reload.
add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# Load dotfiles binaries
add_to_path "$DOTFILES/bin"

# Load global Node installed binaries
add_to_path "$HOME/.node/bin"

# Use project specific binaries before global ones
add_to_path "vendor/bin"
add_to_path "node_modules/.bin"

# Local bin directories before anything else
add_to_path "/usr/local/bin"

# Add Java to path
add_to_path "/opt/homebrew/opt/openjdk/bin"

# Add linux's man to the manpath
export MANPATH="/usr/local/man:$MANPATH"
