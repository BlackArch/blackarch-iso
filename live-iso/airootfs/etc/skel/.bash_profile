# colors
darkgrey="$(tput bold ; tput setaf 0)"
white="$(tput bold ; tput setaf 7)"
red="$(tput bold; tput setaf 1)"
nc="$(tput sgr0)"

# exports
export PATH="${HOME}/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:"
export PATH="${PATH}/usr/local/sbin:/opt/bin:/usr/bin/core_perl:/usr/games/bin:"
export PS1="\[$darkgrey\][ \[$red\]blackarch \[$white\]\W\[$red\] \[$darkgrey\]]\\[$red\]# \[$nc\]"
export LD_PRELOAD=""
export EDITOR="vim"

# alias
alias ls="ls --color"
alias vi="vim"
alias shred="shred -zf"
alias python="python2"
alias wget="wget -U 'noleak'"
alias curl="curl --user-agent 'noleak'"

# source files
[ -r /usr/share/bash-completion/completions ] &&
  . /usr/share/bash-completion/completions/*

# tuning
tuning.sh 2>&1
