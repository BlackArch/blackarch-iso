# colors
# "darkgrey" is colour 8 (bright black) where the terminal has 16 or more
# colours. Elsewhere -- notably the Linux console (TERM=linux, 8 colours)
# -- it stays bold black, which the console renders as dark grey. Bold
# black is not used everywhere because many terminal emulators do not
# brighten bold text: it stays black on a black background, and the path
# and the '#' in the prompt vanish.
if [ "$(tput colors 2>/dev/null || echo 0)" -ge 16 ]; then
  darkgrey="$(tput setaf 8)"
else
  darkgrey="$(tput bold ; tput setaf 0)"
fi
white="$(tput bold ; tput setaf 7)"
blue="$(tput bold; tput setaf 4)"
cyan="$(tput bold; tput setaf 6)"
nc="$(tput sgr0)"

# exports
export PATH="${HOME}/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"
export PATH="${PATH}:/usr/local/sbin:/opt/bin:/usr/bin/core_perl:/usr/games/bin"
# Not exported: child shells that do not understand \[ \] would show it raw.
PS1="\[$blue\][ \[$cyan\]\H \[$darkgrey\]\w\[$darkgrey\] \[$blue\]]\\[$darkgrey\]# \[$nc\]"

# Start each prompt on a fresh line when the previous command's output did
# not end with a newline (printf, echo -n, cat of a file with no final
# newline). Otherwise bash assumes the prompt starts at column 0, its
# redisplay is off by that many columns, and typed characters vanish from
# the screen while editing. Same technique as zsh's PROMPT_SP: print a
# reverse-video '%' and COLUMNS-1 spaces, then return to column 0. At
# column 0 that exactly fills the line and the prompt overwrites it;
# mid-line it wraps first, leaving '%' to mark the unterminated output.
case $- in *i*)
  if [ "${TERM:-dumb}" != dumb ]; then
    _ba_prompt_sp() { printf '\e[7m%%\e[m%*s\r' "$(( ${COLUMNS:-80} - 1 ))" ''; }
    case " ${PROMPT_COMMAND[*]} " in
      *" _ba_prompt_sp "*) ;;
      *) PROMPT_COMMAND+=(_ba_prompt_sp) ;;
    esac
  fi
;; esac
export LD_PRELOAD=""
export EDITOR="vim"

# alias
alias ls="ls --color"
alias vi="vim"
alias shred="shred -zf"
#alias python="python2"
alias wget="wget -U 'noleak'"
alias curl="curl --user-agent 'noleak'"

# bash-completion is loaded by /etc/bash.bashrc, which /etc/profile sources
# for login shells too. Do not source completions/* here: '.' reads only
# the first file of the glob and passes the rest to it as arguments.
