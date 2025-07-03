# -*- Mode: shell-script; tab-width: 2 -*- *
# OSX specific functions and aliases

alias qlf='qlmanage -p "$@" >& /dev/null'
alias clear-dns-cache='dscacheutil -flushcache'
alias lsusb='system_profiler SPUSBDataType'
alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
alias topc="top -o cpu"
alias loc="less ${OC_PATH_DUMP}"
# useful for doing ubuntu stuff on my laptops
alias mp="multipass" 
# macos free-ish replacement
alias mfree="top -l 1 -s 0 | egrep '^(PhysMem|VM):'"
alias claude="${HOME}/.claude/local/claude"

# open a manpage in a new iterm window with a specific theme
function xman() { open x-man-page://$@ ; }
function set_volume() { sudo osascript -e "set Volume $1" }
function ql () { qlmanage -p "$@" >& /dev/null & }
function iterm-title () { echo -ne "\033]0;"${1}"\007" }

# google seems to want all of my standard google auth biz to be coupled to a
# google cloud project. f*ck that.  i guess i'll just leak the environment
# variable.
function gemini-sandbox() {
  docker run -it --rm \
    -e GEMINI_API_KEY="${GEMINI_API_KEY}" \
    -v $(pwd):/app:rw \
    --net=host  gemini-sandbox
}

# this uses the claude subscription auth mounted at the following mountpoints to
# let me run claude-code in a docker container while not having to re-auth every
# time. these may need to be periodically refreshed.  also, this is quite
# dependent on the path structure of my container.
function claude-sandbox() {
  docker run -it --rm \
    -v $(pwd):/app:rw \
    -v ${HOME}/.credentials/claude:/home/claude/.claude:rw \
    -v ${HOME}/.claude.json:/home/claude/.claude.json:rw \
    --net=host claude-sandbox
}

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
  rm "${HOME}/.offlineimap/gmail.lock"
  offlineimap -u basic
}
