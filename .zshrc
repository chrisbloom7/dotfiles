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
  bundler                      # completion for basic bundler commands, as well as aliases and helper functions
  common-aliases               # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/common-aliases
  docker                       # auto-completion for docker as well as some aliases for common commands
  docker-compose               # auto-completion for docker-compose as well as some aliases for common commands
  dotenv                       # automatically load .env files when you cd into a directory
  encode64                     # encode64/e64; encodefile64/ef64; decode64/d64
  gh                           # adds completion for the GitHub CLI
  git-prompt                   # displays information about the current git repository
  golang                       # completion for the Go Programming Language
  history                      # h (history); hl (less); hs (grep); hsi (grep -i)
  httpie                       # completion for HTTPie, a command line HTTP client, a friendlier cURL replacement
  jsontools                    # <json data> | <tool>: pp_json; is_json; urlencode_json; urldecode_json
  npm                          # auto-completion for npm as well as many useful aliases
  nvm                          # auto-completion for nvm and automatically sources nvm
  rails                        # auto-completion and aliases for rails and rake
  rake-fast                    # Fast rake autocompletion plugin that caches output
  rbenv                        # sources rbenv, adds aliases: rubies, gemsets, current_ruby, current_gemset, gems
  rvm                          # utility functions and completions for Ruby Version Manager
  screen                       # sets title and hardstatus of the tab window for screen, the terminal multiplexer
  sudo                         # Easily prefix your current or previous commands with sudo by pressing esc twice
  tmux                         # aliases for tmux, the terminal multiplexer
  virtualenv                   # displays information of the created virtual container and allows background theming
  yarn                         # completion for the Yarn package manager, as well as some aliases for common commands
  zsh-autosuggestions          # Fish-like autosuggestions for zsh
  zsh-completions              # Additional completion definitions for Zsh
  zsh-history-substring-search # type in part of prev entered command and cycle with UP/DOWN arrow keys
  zsh-syntax-highlighting      # Fish shell like syntax highlighting for Zsh
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

# Add Java to path
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
