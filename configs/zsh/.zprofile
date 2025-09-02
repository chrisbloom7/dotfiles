# if [[ -f "~/.local/bin/mise" ]]; then
#   eval "$(~/.local/bin/mise activate zsh)"
# elif [[ -f "/opt/homebrew/bin/mise" ]]; then
#   eval "$(/opt/homebrew/bin/mise activate zsh)"
# fi
# [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || true

# AWS vars - portal Makefile depends on these being set
export AWS_PROFILE=chris.bloom
export AWS_VAULT_BACKEND=keychain
export AWS_REGION=us-east-1
