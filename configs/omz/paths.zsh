# Prepend directories to $PATH and prevent adding the same directory multiple times upon shell reload.
_prepend_to_path() {
  NEW_PATH="${1:?Path is required}"
  if [[ -d "${NEW_PATH}" ]] && [[ ":${PATH}:" != *":${NEW_PATH}:"* ]]; then
    export PATH="$NEW_PATH:$PATH"
  fi
}

# Load personal binaries
_prepend_to_path "${HOME}/.local/bin"
_prepend_to_path "${HOME}/bin"

# Add Homebrew coreutils to path for GNU utilities
if [[ -n $(command -v brew 2>/dev/null) ]]; then
  _prepend_to_path "$(brew --prefix coreutils)/libexec/gnubin"
fi

# Load global Node installed binaries
_prepend_to_path "${HOME}/.node/bin"

# Use project specific binaries before global ones
_prepend_to_path "node_modules/.bin"
_prepend_to_path "vendor/bin"

# Local bin directories before anything else
_prepend_to_path "/usr/local/bin"

# Add Java to path
if [[ -n $(command -v brew 2>/dev/null) ]]; then
  _prepend_to_path "$(brew --prefix openjdk)/bin"
fi

# Add linux's man to the manpath
export MANPATH="/usr/local/man:${MANPATH}"

# #######################################
# # Adds a path to $PATH and echoes the new $PATH string.
# # Arguments:
# #   $1 = Path to add to $PATH
# #   $2 = $PATH string
# #######################################
# add_to_path() {
#     new_path="$2"
#     if [[ $PATH != *"$1"* ]]; then
#         new_path="$1:$2"
#     fi
#     echo "$new_path"
# }

# #######################################
# # Replaces "export PATH=..." in a file with the given PATH
# # Arguments:
# #   $1 = File
# #   $2 = Text to write
# #######################################
# replace_export_path() {
#     sed -i "" -e "s|export PATH=.*|export PATH=\"$2\"|g" "$1"
# }

# #######################################
# # Replace the value of a key in .env
# # Arguments:
# #   $1 = Key
# #   $2 = Value
# #######################################
# write_env_val() {
#     sed -i "" -e "s|\(^${1}=\).*|\1${2}|" $dotenv_path
# }
