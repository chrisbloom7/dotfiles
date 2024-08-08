# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Enable completions
autoload -Uz compinit && compinit

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
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
# ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# See https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/
plugins=(
  bundler                      # completion for basic bundler commands, as well as aliases and helper functions
  common-aliases               # creates helpful shortcut aliases for many commonly used commands
  docker                       # auto-completion for docker as well as some aliases for common commands
  docker-compose               # auto-completion for docker-compose as well as some aliases for common commands
  dotenv                       # automatically load .env files when you cd into a directory
  encode64                     # encode64/e64; encodefile64/ef64; decode64/d64
  gh                           # adds completion for the GitHub CLI
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
  thor                         # completion for Thor, a ruby toolkit for building powerful command-line interfaces
  tmux                         # aliases for tmux, the terminal multiplexer
  virtualenv                   # displays information of the created virtual container and allows background theming
  yarn                         # completion for the Yarn package manager, as well as some aliases for common commands
  zbell                        # prints a bell character when a command finishes if it has been running for longer than a specified duration
  zsh-autosuggestions          # Fish-like autosuggestions for zsh
  zsh-completions              # Additional completion definitions for Zsh
  zsh-history-substring-search # type in part of prev entered command and cycle with UP/DOWN arrow keys
  zsh-syntax-highlighting      # Fish shell like syntax highlighting for Zsh
)

# User configuration for oh-my-zsh and plugins
DEFAULT_USER="chrisbloom7"

# Initialize oh-my-zsh
[[ ! -f $ZSH/oh-my-zsh.sh ]] && echo "oh-my-zsh not found at $ZSH" && exit 1
source $ZSH/oh-my-zsh.sh

# User configuration

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

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Load project aliases (backed up by mackup to prevent leaking sensitive info)
[[ -e "${HOME}/.aliases" ]] && source "${HOME}/.aliases"

# Load iTerm2 shell integration
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"

# Load fuzzy finder
[ -e "${HOME}/.fzf.zsh" ] && source "${HOME}/.fzf.zsh"

# Load rbenv
[ -n $(command -v rbenv 2>/dev/null) ] && eval "$(rbenv init -)"

# Load nodenv
[ -n $(command -v nodenv 2>/dev/null) ] && eval "$(nodenv init -)"

# Add nvm to path and load completions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
