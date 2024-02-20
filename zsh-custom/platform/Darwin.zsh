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
alias loc="less ${OC_PATH_DUMP}"
alias lopr="less ${ANET_PATHREPORT}"


function set_volume() { sudo osascript -e "set Volume $1" }
function ql () { qlmanage -p "$@" >& /dev/null & }
function iterm-title () { echo -ne "\033]0;"${1}"\007" }

# sometimes we want to install something using the homebrew version of python.
# this is expecially useful when dealing with things that happen to be linked
# against the brew python installs and there's a pip module we need.
function pyenv-brew-relink() {
  rm -f "${HOME}/.pyenv/versions/*-brew"

  for i in $(brew --cellar python)/*; do
    echo "brew version: $i"
    ln -s "${i}" "${HOME}/.pyenv/versions/${i##/*/}-brew"
  done
}

# legacy imap/mutt mail handling tools
# mail rollover tools - tis moves my mailbox to the right spot
rolloutbox () {
  ARCH_YEAR=$(date -v -2m +%Y)
  ARCH_BASE=${HOME}/Documents/archives/mail/${ARCH_YEAR}/outbox
  ${HOME}/bin/split-maildirs.pl --keep_recent --arch_dir=$ARCH_BASE -src_dir=${HOME}/mail outbox
}

# kill offlineimap instances and clean up the lock file. 
koff () {
  pkill -if offlineimap
  rm "${HOME}/.offlineimap/arista.lock"
  offlineimap -u basic
}
