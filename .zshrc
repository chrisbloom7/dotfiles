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
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git git-extras)
plugins=(common-aliases           # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/common-aliases
         dotenv                   # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/dotenv
         encode64                 # encode64/e64; decode64/d64
         history                  # h (history); hs (grep); hsi (grep -i)
         history-substring-search # type in part of prev entered command and cycle with UP/DOWN arrow keys
         httpie                   # completion for HTTPie
         nvm                      # auto sources nvm
         rake-fast                # Fast rake autocompletion plugin that caches output
         screen                   # let the zsh tell screen what the title and hardstatus of the tab should be
         sudo)                    # ESC twice puts sudo in front of the current command or the last one
         # bundler                  # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/bundler
         # jira                     # https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/jira
         # jsontools                # <json data> | <tool>: pp_json; is_json; urlencode_json; urldecode_json
         # rbenv                    # sources rbenv, adds aliases: rubies, gemsets, current_ruby, current_gemset, gems

DEFAULT_USER="chrisbloom7"

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

# # rbenv config: https://albertogrespan.com/blog/installing-ruby-the-right-way-on-os-x-using-rbenv/
# export RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --with-libyaml-dir=`brew --prefix libyaml`"

# Bundler Config Options
# export LDFLAGS="-L/usr/local/opt/icu4c/lib -L/usr/local/opt/libffi/lib"
# export CPPFLAGS="-I/usr/local/opt/icu4c/include"
# export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

# ssh
# TODO: export SSH_KEY_PATH="~/.ssh/dsa_id"

# Ensure AWS defaults are set
export AWS_DEFAULT_REGION=us-east-1

source $HOME/.aliases

# load zsh extensions from Homebrew
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/opt/zsh-git-prompt/zshrc.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(/usr/local/share/zsh-completions $fpath)

# load iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Load rbenv
eval "$(rbenv init -)"
