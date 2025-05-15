export PATH="$HOME/.yarn/bin:$PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="${EDITOR:-vim}"
else
  export EDITOR="${EDITOR:-cursor}"
  export GIT_EDITOR="${GIT_EDITOR:-${EDITOR} --wait}"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Added by LM Studio CLI (lms)
export PATH="$PATH:${HOME}/.lmstudio/bin"
