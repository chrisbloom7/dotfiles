# if [[ -f "~/.local/bin/mise" ]]; then
#   eval "$(~/.local/bin/mise activate zsh)"
# elif [[ -f "/opt/homebrew/bin/mise" ]]; then
#   eval "$(/opt/homebrew/bin/mise activate zsh)"
# fi
# [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || true

# Homebrew prefix differs by machine: Apple silicon, Intel, Linux
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do [[ -x "${_brew}" ]] && { eval "$("${_brew}" shellenv)"; break; }; done; unset _brew

# Machine-specific overrides (not tracked in dotfiles)
[[ -f "${HOME}/.zprofile.local" ]] && source "${HOME}/.zprofile.local" || true
