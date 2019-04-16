# Shortcuts
alias dots="dotfiles && $EDITOR $DOTFILES"
alias beep="say -v Fred \"My liege, the task is complete\""
alias cls="clear"
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias hosts="$EDITOR /etc/hosts"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
reload() {
	local cache="$ZSH_CACHE_DIR"
	autoload -U compinit zrecompile
	compinit -i -d "$cache/zcomp-$HOST"

	for f in ~/.zshrc "$cache/zcomp-$HOST"; do
		zrecompile -p $f && command rm -f $f.zwc.old
	done

	# Use $SHELL if available; remove leading dash if login shell
	[[ -n "$SHELL" ]] && exec ${SHELL#-} || exec zsh
}
weather() { curl -4 wttr.in/${1:-SRQ}?${2:-n2} }

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias src="cd $HOME/src"

# Ruby
alias epoch="ruby -e 'puts Time.now.to_i'"
alias timestamp='epoch'
rvmrc() {
  if [ "$1" != "" ]
  then
    rvm --create --ruby-version use `rvm current`
  else
    rvm --create --ruby-version use $1
  fi
}

# Vagrant
alias v="vagrant global-status"
alias vup="vagrant up"
alias vhalt="vagrant halt"
alias vssh="vagrant ssh"
alias vreload="vagrant reload"
alias vrebuild="vagrant destroy --force && vagrant up"

# Docker
#alias dstop="docker stop $(docker ps -a -q)"
#alias dpurgecontainers="dstop && docker rm $(docker ps -a -q)"
#alias dpurgeimages="docker rmi $(docker images -q)"
#dbuild() { docker build -t=$1 .; }
#dbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }

# Git
alias git-bin='git-branch-incoming'
alias git-bout='git-branch-outgoing'
alias git-mb='git-make-branch'
alias me='git pretty | grep "Chris Bloom" | less'
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
    git log ..$1 --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local
}
git-branch-outgoing() {
    echo branch \($(parse_git_branch)\) has these commits and \($1\) does not
    git log $1.. --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local
}

# Java
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# default to Java 11
java11
