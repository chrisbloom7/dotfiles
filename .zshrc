# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Enable completions
autoload -Uz compinit && compinit

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  common-aliases           # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/common-aliases
  dotenv                   # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
  history                  # h (history); hs (grep); hsi (grep -i)
  history-substring-search # type in part of prev entered command and cycle with UP/DOWN arrow keys
  nvm                      # auto sources nvm
  rake-fast                # Fast rake autocompletion plugin that caches output
  rbenv                    # sources rbenv, adds aliases: rubies, gemsets, current_ruby, current_gemset, gems
  screen                   # let the zsh tell screen what the title and hardstatus of the tab should be
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  ### INACTIVE ###
  # bundler                  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/bundler
  # encode64                 # encode64/e64; decode64/d64
  # httpie                   # completion for HTTPie
  # jira                     # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jira
  # jsontools                # <json data> | <tool>: pp_json; is_json; urlencode_json; urldecode_json
  # sudo                     # ESC twice puts sudo in front of the current command or the last one
)

source $ZSH/oh-my-zsh.sh

# User configuration
DEFAULT_USER="chrisbloom7"

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
  export GIT_EDITOR='code --wait'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Ensure AWS defaults are set
export AWS_DEFAULT_REGION=us-east-1

# Load project aliases
[[ -e "${HOME}/.aliases" ]] && source "${HOME}/.aliases"

# load git prompt extensions
[[ -e "$HOME/zsh-git-prompt/zshrc.sh" ]] && source "$HOME/zsh-git-prompt/zshrc.sh"

# load iTerm2 shell integration
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Load fuzzy finder
[ -e "${HOME}/.fzf.zsh" ] && source "${HOME}/.fzf.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
