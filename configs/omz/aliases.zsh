# Shortcuts
alias cls="clear"
alias badge='tput bel'

yn() {
  test $@ && echo yup || echo nope
}

if [[ -n "$(command -v zsh 2>/dev/null)" ]]; then
  alias reloadshell="omz reload"
  alias reload="omz reload"
fi

if [[ "$(uname -a)" =~ "Darwin" ]]; then
  alias beep="say -v Yuri \"My liege, the task is complete\""
  alias copyssh="pbcopy < ${HOME}/.ssh/id_rsa.pub"
  alias fixzoom="sudo killall VDCAssistant"
  alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
  alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
  alias library="cd ${HOME}/Library"
fi

# Directories
dotfiles () { cd "${DOTFILES:?DOTFILES not set}" }
src () { cd "$HOME/src/$@" }

# Python
alias python="python3"
alias py="python3"
alias pip="pip3"

# Projects and files
edots () {
  ${EDITOR:?EDITOR not defined} "${DOTFILES}"
}
ehosts () {
  ${EDITOR:?EDITOR not defined} /etc/hosts
}
edotaliases () {
  ${EDITOR:?EDITOR not defined} "${HOME}/.aliases"
}
readme () {
  if [[ -z "$(command -v pandoc 2>/dev/null)" ]] || [[ -z "$(command -v lynx 2>/dev/null)" ]]; then
    return 1;
  fi
  if [[ -n "${1:-}" ]]; then
    pandoc $1 | lynx -stdin
  else
    pandoc README.md | lynx -stdin
  fi
}

# General utilities
epoch () {
  if [[ -n "${1:-}" ]]; then
    if [[ -n "$(command -v ruby 2>/dev/null)" ]]; then
      cmd="puts Time.at(${1})"
      $(command -v ruby) -e $cmd
    else
      echo Ruby command not found. Try using without a date argument.
      return 1
    fi
  else
    echo $(date +%s)
  fi
}
alias timestamp="epoch"
weather () { curl -4 wttr.in/${1:-SRQ}\?${2:-n2} }
rvmrc () {
  [[ -z "$(command -v rvm 2>/dev/null)" ]] && echo "rvm not installed" && return 1

  if [[ -z "${1:-}" ]]; then
    rvm --create --ruby-version use $(rvm current)
  else
    rvm --create --ruby-version use ${1}
  fi
}

# Git
alias gcom='git com'                  # Short for `git checkout [default_branch]`, typically `main` or `master`
alias git-bdiff='git-branch-diff' .   # Show commits in <source> that are not in <target>
alias git-bin='git-branch-incoming'   # Lists commits in the <source> that are not in the current working branch
alias git-bout='git-branch-outgoing'  # Lists commits in the current working branch that are not in the <target>
alias git-mb='git-make-branch'        # Create a new branch from the current branch with a name based on the supplied arguments
alias gpom='git pom'                  # Short for `git pull origin [default_branch]`, typically `main` or `master`
git-make-branch () {
  if [[ "$#" -gt 0 ]]; then
    branch=$(ruby -e 'puts ARGV.join(" ").strip.gsub(/[\W\s_]+/, " ").downcase.split(" ").join("_")' "$@")
    echo "Attempting to create branch names '$branch'"
    if [[ -z "$branch" ]]; then
      echo "-- Could not create branch from supplied arguments"
      return 1
    else
      git switch -c $branch
    fi
  else
    echo "-- No arguments supplied"
    return 1
  fi
}
_parse_git_branch () {
  # From http://stackoverflow.com/a/2831173/83743
  git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
git-branch-diff () {
  if [[ "$#" -lt 2 ]] || [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
    echo "Lists commits in the source commitish that are not in the target commitish, i.e. commits that would be added if you merged source into target"
    echo "Usage: git-branch-diff <source-commitish> <target-commitish>"
    echo "Alias: git-bdiff"
    return 0
  else
    log=$(git log --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local ${1}..${2} --)
    if [[ -z "$log" ]]; then
      echo "'${2}' has no commits that '${1}' does not also have"
    else
      echo "'${2}' has these commits and '${1}' does not:"
      echo "$log"
    fi
  fi
}
git-branch-incoming () {
  if [[ "$#" -lt 1 ]] || [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
    echo "Lists commits in the source commitish that are not in the current working branch, i.e. incoming commits if you merged the source commitish into the working branch."
    echo "Usage: git-branch-incoming <source-commitish>"
    echo "Alias: git-bin"
    return 0
  fi
  git-branch-diff "$(_parse_git_branch)" "${1}"
}
git-branch-outgoing () {
  if [[ "$#" -ne 1 ]]; then
    echo "Lists commits in the current working branch that are not in the target commitish, i.e. outgoing commits if you merged the working branch into the target."
    echo "Usage: git-branch-outgoing <target-commitish>"
    echo "Alias: git-bout"
    return 0
  fi
  git-branch-diff "${1}" "$(_parse_git_branch)"
}
