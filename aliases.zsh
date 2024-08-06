# Shortcuts
alias dots="$EDITOR $DOTFILES"
alias beep="say -v Yuri \"My liege, the task is complete\""
alias cls="clear"
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias fixzoom="sudo killall VDCAssistant"
alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias hosts="$EDITOR /etc/hosts"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
readme () {
  if [ $1 ]; then
    pandoc $1 | lynx -stdin
  else
    pandoc README.md | lynx -stdin
  fi
}
alias reload="omz reload"
weather() { curl -4 wttr.in/${1:-SRQ}\?${2:-n2} }

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
function src() { cd "$HOME/src/$@" }

# Ruby
epoch() {
  if [ $1 ]; then
    ruby -e "puts Time.at($1)"
  else
    ruby -e "puts Time.now.to_i"
  fi
}
alias timestamp='epoch'
rvmrc() {
  if [ "$1" != "" ]
  then
    rvm --create --ruby-version use `rvm current`
  else
    rvm --create --ruby-version use $1
  fi
}

# # Vagrant
# alias v="vagrant global-status"
# alias vup="vagrant up"
# alias vhalt="vagrant halt"
# alias vssh="vagrant ssh"
# alias vreload="vagrant reload"
# alias vrebuild="vagrant destroy --force && vagrant up"

# Docker
#alias dstop="docker stop $(docker ps -a -q)"
#alias dpurgecontainers="dstop && docker rm $(docker ps -a -q)"
#alias dpurgeimages="docker rmi $(docker images -q)"
#dbuild() { docker build -t=$1 .; }
#dbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }

# Git
alias gcom='git com'
alias gpom='git pom'
alias git-bin='git-branch-incoming'
alias git-bout='git-branch-outgoing'
alias git-mb='git-make-branch'
# alias me='git pretty | grep "Chris Bloom" | less'
git-make-branch() {
  echo "\$@ = '$@'"
  typeset branch
  if [[ "$@" != "" ]]; then
    branch=$(ruby -e 'puts ARGV.join(" ").strip.gsub(/[\W\s_]+/, " ").downcase.split(" ").join("_")' "$@")
    # echo "branch = '$branch'"
    if [[ "$branch" = "" ]]; then
      echo "-- Could not create branch from supplied arguments"
    else
      git co -b "$branch"
      echo "-- Created branch $branch"
    fi
  else
    echo "-- Could not create branch from supplied arguments"
  fi
}
parse_git_branch() {
  # From http://stackoverflow.com/a/2831173/83743
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
git-branch-incoming() {
    echo branch \($1\) has these commits and \($(parse_git_branch)\) does not
    git log --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local ..$1 | more
}
git-branch-outgoing() {
    echo branch \($(parse_git_branch)\) has these commits and \($1\) does not
    git log --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local $1.. | more
}

# # Java
# export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
# export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
# alias java8='export JAVA_HOME=$JAVA_8_HOME'
# alias java11='export JAVA_HOME=$JAVA_11_HOME'
# # default to Java 11
# java11

# Python
alias python="python3"
alias py="python3"
alias pip="pip3"
