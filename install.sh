#!/bin/bash

# create the framework of dotfiles and supporting software, etc that i
# use on a standard unix system.  this presumes that i'm setting up
# shop on a new machine / laptop.
# 
# make sure that direnv is installed 

# installation script to pull down the necessary configuration files for me to
# bootstrap a machine.

declare -a DOTFILES=( Xdefaults ansible.cfg cloginrc flake8 gitconfig
 gitignore gnupg gvimrc mailcap octaverc pb.sh screenrc sqliterc
 tmux.conf urlview vimrc)


ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm)    dpkg --print-architecture | grep -q "arm64" && ARCH="arm64" || ARCH="arm" ;;
esac


install_go() {
  echo "installing go"
  mkdir -p "${HOME}/go"
  GO_VERSION=$(curl -s "https://golang.org/VERSION?m=text")
  GO_OS=$(uname -s | tr "[:upper:]" "[:lower:]"n)
  FILENAME="${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz"
  echo "downloading: https://dl.google.com/go/${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz to ${FILENAME}" 
  # curl -s "https://dl.google.com/go/${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz" -o "${FILENAME}"
  # sudo tar -C /usr/local -xzf "${FILENAME}"
}

# pull down oh-my-zsh
install_omz() {
  echo "making home src directory"
  mkdir -p "${HOME}/src"
  echo "cloning oh-my-zsh"
  git clone https://github.com/robbyrussell/oh-my-zsh.git "${HOME}/src/zsh"
}

# pull down snmp mibs i use (begrudgingly)
install_snmp_mibs() {
  echo "downloading various SNMP mibs"
  curl -sf https://dyn.botwerks.net/mibs/mibs.tar.gz 
} 

# pull down my vim config
install_vim_modules() {
  echo "installing vim customizations"
  git clone https://github.com/sulrich/vim.git "${HOME}/.vim"
  cd "${HOME}/.vim" || return
  git submodule update --init
  cd "${HOME}" || return
}

# pull down pyenv
install_pyenv(){
  echo "downloading various SNMP mibs"
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
}

make_symlinks() {
  echo "making dotfile symlinks" 
  ln -s "${HOME}/.home/zsh-custom/zlogin" "${HOME}/.zlogin"
  ln -s "${HOME}/.home/zsh-custom/zshenv" "${HOME}/.zshenv"
  
  for DOTFILE in "${DOTFILES[@]}"
  do
    echo  "- ${DOTFILE}"
    ln -s "${HOME}/.home/${DOTFILE}" "${HOME}/.${DOTFILE}"
  done

  
}

install_personal_bin() {
  echo "installing personal scripts/binaries into home directory ..."
  git clone https://github.com/sulrich/home-bin.git "${HOME}/bin"
}

# after having built pyenv end the necessary python - install powerline to make
# things look cool
# pip install powerline-status
# 
# we should also install black to make python formatting work. depending on the
# version of vim installed, we may need to override the pip3 version to be the
# system version of python.  e.g.: `pyenv shell system`, we'll also need to make
# sure that the right version of pip is installed `apt install python3-pip` and
# be sure to install black to the user location (`pip3 install black ---user`)

# copy my authorized ssh public key 
sync_public_ssh_keys() {
  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"
  curl -s https://github.com/sulrich.keys >> "${HOME}/.ssh/authorized_keys"
}




print_usage() {

  cat << EOF

$0 command

available commands

command: bootstrap

downloads the baseline repos and binaries to make a reasonably useful
working environment.  makes dotfile symlinks, downloads the ~/bin
collection and takes a swing at getting pyenv in working order.

command: install-snmp

downloads the preferred collection of SNMP mibs

command: make-symlinks

deletes existing dotfiles or copies the dotfile to ~/dotfiles-backup
and regenerates symlinks based on the current state of the DOTFILES
list in this script.

command: sync-public-keys

updates my authorized_keys from the public keys posted to github.

EOF
 
}


# check to see if there's been an action specified 
if [ $# -eq 0 ];
then
  echo "no options specified"
  print_usage
  exit 1
fi

# parse command line args
PARAMS=""

while (( "$#" )); 
do
  case "$1" in
  install-snmp)
    echo "installing SNMP mibs"
    shift
    ;;
  make-symlinks)
    echo "regenerating symlinks"
    # backup_dotfiles
    # make_symlinks
    shift
    ;;
  sync-public-keys)
    echo "regenerating symlinks"
    # backup_dotfiles
    # make_symlinks
    shift
    ;;
  install-go)
    echo "installing go-lang"
    install_go
    shift
    ;;
  -h)  # end of args parsing
    print_usage
    shift
    break
    ;;
  --)  # end of args parsing
    shift
    break
    ;;
  *)  # preserve positional arguments
    print_usage
    PARAMS="$PARAMS $1"
    shift
    exit 
    ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"
