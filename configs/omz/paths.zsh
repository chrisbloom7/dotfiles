# Prepend directories to $PATH and prevent adding the same directory multiple times upon shell reload.
_prepend_to_path() {
  NEW_PATH="${1:?Path is required}"
  if [[ -d "${NEW_PATH}" ]] && [[ ":${PATH}:" != *":${NEW_PATH}:"* ]]; then
    export PATH="$NEW_PATH:$PATH"
  fi
}

# Load personal binaries
_prepend_to_path "${HOME}/bin"

# Add Homebrew coreutils to path for GNU utilities
_prepend_to_path "/usr/local/opt/coreutils/libexec/gnubin"

# Load global Node installed binaries
_prepend_to_path "${HOME}/.node/bin"

# Use project specific binaries before global ones
_prepend_to_path "vendor/bin"
_prepend_to_path "node_modules/.bin"

# Local bin directories before anything else
_prepend_to_path "/usr/local/bin"

# Add Java to path
_prepend_to_path "/opt/homebrew/opt/openjdk/bin"

# Add linux's man to the manpath
export MANPATH="/usr/local/man:${MANPATH}"
