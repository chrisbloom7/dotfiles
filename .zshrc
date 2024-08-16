# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Enable completions
if [ -n "$(command -v rbenv 2>/dev/null)" ] && [ -e "$(rbenv root)/completions" ]; then
  # add rbenv completions
  FPATH="$(rbenv root)/completions:${FPATH}"
fi
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
  common-aliases               # creates helpful shortcut aliases for many commonly used commands
  encode64                     # encode64/e64; encodefile64/ef64; decode64/d64
  history                      # h (history); hl (less); hs (grep); hsi (grep -i)
  jsontools                    # <json data> | <tool>: pp_json; is_json; urlencode_json; urldecode_json
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
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="${EDITOR:-vim}"
else
  export EDITOR="${EDITOR:-code}"
  export GIT_EDITOR="${GIT_EDITOR:-code --wait}"
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Ensure AWS defaults are set
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Load project aliases (backed up by mackup to prevent leaking sensitive info)
[[ -e "${HOME}/.aliases" ]] && source "${HOME}/.aliases"

# Load iTerm2 shell integration
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"

# Load rbenv
[ -n "$(command -v rbenv 2>/dev/null)" ] && eval "$(rbenv init -)"

# Load nodenv
[ -n "$(command -v nodenv 2>/dev/null)" ] && eval "$(nodenv init -)"

# NVM completions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Make sure ruby-build is up to date
[ -d "$(rbenv root)/plugins/ruby-build" ] && git -C "$(rbenv root)/plugins/ruby-build" pull
