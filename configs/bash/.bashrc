export PATH="${HOME}/.local/share/mise/shims:${HOME}/.yarn/bin:${PATH}"

# Preferred editor for local and remote sessions
_DEFAULT_EDITOR=vim
if [[ -z $SSH_CONNECTION ]]; then
  if [[ -n $(command -v cursor 2>/dev/null) ]]; then
    _DEFAULT_EDITOR=cursor
  elif [[ -n $(command -v code 2>/dev/null) ]]; then
    _DEFAULT_EDITOR=code
  fi
fi
export EDITOR="${EDITOR:-_DEFAULT_EDITOR}"
export GIT_EDITOR="${GIT_EDITOR:-${EDITOR} --wait}"
unset _DEFAULT_EDITOR


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Added by LM Studio CLI (lms)
export PATH="${PATH}:${HOME}/.lmstudio/bin"


if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
