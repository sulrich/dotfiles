# -*- Mode: shell-script; tab-width: 2 -*- *
# linux only aliases and functions

alias hh="hopperhelper"

# not everyone has killall installed
killall () {
  local pid
  pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
  echo -n "killing $1 ( process:  $pid )"
  kill -9 `echo $pid`
} 

function xterm-title () { print -Pn "\e]0;${1}: %\a" }

# the following are particularly handy for working with qemu overlay images
# images
gen-kvm-overlay () {
  # create the router specific overlay files
  # $1 = qcow image,
  # $2 = router image
  qemu-img create -b $1 -f qcow2 $2
}

gen-qcow-image () {
  # get to the base image
  IMAGE=$(basename "$1")
  IMG_BASE=${IMAGE%%.*}
  # returns the filename sans extension
  qemu-img convert $IMG_BASE.vmdk -O qcow2 $IMG_BASE.qcow2
}

## i really only want ssh-add enabled on remote linux hosts
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s)
fi

