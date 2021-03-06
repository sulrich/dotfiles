# -*- Mode: shell-script; tab-width: 2 -*- *
# OSX specific functions and aliases

alias qlf='qlmanage -p "$@" >& /dev/null'
alias clear-dns-cache='dscacheutil -flushcache'
alias ocal="open ${HOME}/Desktop/meeting.ics"
alias flashfind="find ~/Library -name \*sol"
alias lsusb='system_profiler SPUSBDataType'
alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
alias topc="top -o cpu"
alias vctl="/Applications/VMware\ Fusion.app/Contents/Public/vctl"

function set_volume() { sudo osascript -e "set Volume $1" }
function ql () { qlmanage -p "$@" >& /dev/null & }
function iterm-title () { echo -ne "\033]0;"${1}"\007" }



vterm_printf(){
  if [ -n "$TMUX" ]; then
    # Tell tmux to pass the escape sequences through
    # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
    printf "\ePtmux;\e\e]%s\007\e\\" "$1"
  elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf "\eP\e]%s\007\e\\" "$1"
  else
    printf "\e]%s\e\\" "$1"
  fi
}


# sometimes we want to install something using the homebrew version of python.
# this is expecially useful when dealing with things that happen to be linked
# against the brew python installs and there's a pip module we need.
pyenv-brew-relink() {
  rm -f "${HOME}/.pyenv/versions/*-brew"

  for i in $(brew --cellar python)/*; do
    echo "brew version: $i"
    ln -s "${i}" "${HOME}/.pyenv/versions/${i##/*/}-brew"
  done
}
