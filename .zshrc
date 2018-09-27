# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Disable the annoying "You have new mail" message
#unset MAILCHECK # This isn't working in oh_my_zsh :/

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git git-extras)
plugins=(aws \                     # https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/aws
         bundler \                 # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/bundler
         colored-man-pages \
         colorize \                # ccat
         common-aliases \          # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/common-aliases
         docker \                  # zsh completion for docker
         dotenv \                  # Automatically load ENV variables from .env
         encode64 \                # encode64/e64; decode64/d64
         gem \                     # gemb (build); gemp (build); gemy (yank)
         history \                 # h (history); hs (grep); hsi (grep -i)
         history-substring-search \ # type in part of prev entered command and cycle with UP/DOWN arrow keys
         httpie \
         jira \                    # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/jira
         jsontools \               # <json data> | <tool>: pp_json; is_json; urlencode_json; urldecode_json
         npm \                     # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/npm
         nvm \
         osx \                     # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/osx
         rails \                   # https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/rails
         rake-fast \
         screen \                  # let the zsh tell screen what the title and hardstatus of the tab should be
         sudo \                    # ESC twice puts sudo in front of the current command or the last one
         vscode \                  # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/vscode
         yarn \                    # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/yarn
         zsh-syntax-highlighting)  # https://github.com/zsh-users/zsh-syntax-highlighting

DEFAULT_USER="chrisbloom"

# Activate Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

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
export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"
