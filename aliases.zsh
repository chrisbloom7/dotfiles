# Shortcuts
alias beep="say -v Yuri \"My liege, the task is complete\""
alias cls="clear"
alias copyssh="pbcopy < ${HOME}/.ssh/id_ed25519.pub"
alias copyssh="pbcopy < ${HOME}/.ssh/id_rsa.pub"
alias fixzoom="sudo killall VDCAssistant"
alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias reloadshell="omz reload"
alias reload="omz reload"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"

# Directories
alias dotfiles="cd ${DOTFILES}"
alias library="cd ${HOME}/Library"
src () { cd "$HOME/src/$@" }

# Projects and files
alias edots="${EDITOR} ${DOTFILES}"
alias ehosts="${EDITOR} /etc/hosts"
alias edotaliases="${EDITOR} ${HOME}/.aliases"
readme () {
  if [ -n "${1:-}" ]; then
    pandoc $1 | lynx -stdin
  else
    pandoc README.md | lynx -stdin
  fi
}

# General utilities
epoch () {
  if [ -n "${1:-}" ]; then
    cmd="puts Time.at(${1})"
  else
    cmd="puts Time.now.to_i"
  fi

  $(command -v ruby) -e $cmd
}
alias timestamp="epoch"
weather () { curl -4 wttr.in/${1:-SRQ}\?${2:-n2} }
rvmrc () {
  if [ -n "${1:-}" ]; then
    rvm --create --ruby-version use $(rvm current)
  else
    rvm --create --ruby-version use ${1}
  fi
}

# Git
git-make-branch () {
  echo "\$@ = \"$@\""
  if [ -z "$@" ]; then
    branch=$(ruby -e 'puts ARGV.join(" ").strip.gsub(/[\W\s_]+/, " ").downcase.split(" ").join("_")' "$@")
    echo "Attempting to create branch names '$branch'..."
    if [ -z "$branch" ]; then
      echo "-- Could not create branch from supplied arguments"
    else
      git switch -c $branch
    fi
  else
    echo "-- No arguments supplied"
  fi
}
alias git-mb='git-make-branch'
_parse_git_branch () {
  # From http://stackoverflow.com/a/2831173/83743
  git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
git-branch-diff () {
  if [ "$#" -lt 2 ] || [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
    echo "Lists commits in the source commitish that are not in the target commitish, i.e. commits that would be added if you merged source into target"
    echo "Usage: git-branch-diff <source-commitish> <target-commitish>"
    echo "Alias: git-bdiff"
    exit 1
  else
    echo "'${1}' has these commits and '${2}' does not:"
    log=$(git log --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local ${1}..${2} 2>/dev/null)
    if [ -z "$log" ]; then
      echo "'${1}' has no commits that '${2}' does not also have"
    else
      echo "$log"
    fi
  fi
}
alias git-bdiff='git-branch-diff'
git-branch-incoming () {
  if [ "$#" -lt 1 ] || [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
    echo "Lists commits in the current working branch that are not in the source commitish, i.e. incoming commits if you merged the source commitish into the working branch."
    echo "Usage: git-branch-incoming <source-commitish>"
    echo "Alias: git-bin"
    exit 0
  fi
  git-branch-diff $(_parse_git_branch) ${1}
}
alias git-bin='git-branch-incoming'
git-branch-outgoing () {
  if [ "$#" -ne 1 ]; then
    echo "Lists commits in the current working branch that are not in the target commitish, i.e. outgoing commits if you merged the working branch into the target commitish."
    echo "Usage: git-branch-outgoing <target-commitish>"
    echo "Alias: git-bout"
    exit 0
  fi
  git-branch-diff ${1} $(_parse_git_branch)
}
alias git-bout='git-branch-outgoing'

# Python
alias python="python3"
alias py="python3"
alias pip="pip3"
