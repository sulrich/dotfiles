#!/bin/bash

# note that the minimum bash version for this script is 4.0 to support
# the associative arrays

# create the framework of dotfiles and supporting software, etc that i
# use on a standard unix system.  this presumes that i'm setting up
# shop on a new machine / laptop.
# 
# make sure that direnv is installed 

# installation script to pull down the necessary configuration files for me to
# bootstrap a machine.


ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm*)   dpkg --print-architecture | grep -q "arm64" && ARCH="arm64" || ARCH="armv6l" ;;
esac


install_go() {
  echo "installing go"
  mkdir -p "${HOME}/go/bin"
  mkdir -p "${HOME}/go/src"
  mkdir -p "${HOME}/go/pkg"
  local GO_VERSION=$(curl -s "https://golang.org/VERSION?m=text")
  local GO_OS=$(uname -s | tr "[:upper:]" "[:lower:]"n)
  local FILENAME="${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz"
  # echo ${ARCH}
  echo "downloading: https://dl.google.com/go/${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz to ${FILENAME}" 
  curl -s           "https://dl.google.com/go/${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz" -o "${FILENAME}"
  sudo tar -C /usr/local -xzf "${FILENAME}"
  rm -i "${FILENAME}"
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

# after having built pyenv end the necessary python - install
# powerline to make things look cool - this will likely have some
# local font dependencies if this is run on an actual
# workstation. (read: Mac OS)
# 
# pip install powerline-status

# pull down pyenv
install_pyenv(){
  echo "pulling down some key utilities for vim first. note, these will be"
  echo "installed locally via the --user flag"
  pip3 install black --user
  pip3 install websockets --user
  echo "cloning pyenv"
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
  echo "you'll need to re-init your shell to pick up pyenv"
}

make_symlinks() {
  if [ "${BASH_VERSINFO:-0}" -lt 4 ]
  then
    echo "error: bash version too low (${BASH_VERSION})"
    exit 1
  fi

  declare -A DOTFILES
  DOTFILES=(
    ['Xdefaults']=".Xdefaults"
    ['ansible.cfg']=".ansible.cfg"
    ['cloginrc']=".cloginrc"
    ['flake8']=".flake8"
    ['gitconfig']=".gitconfig"
    ['gitignore']=".gitignore"
    ['gvimrc']=".gvimrc"
    ['mailcap']=".mailcap"
    ['octaverc']=".octaverc"
    ['screenrc']=".screenrc"
    ['sqliterc']=".sqliterc"
    ['tmux.conf']=".tmux.conf"
    ['urlview']=".urlview"
    ['vimrc']=".vimrc"
  )

  echo "making dotfile symlinks" 
  ln -s "${HOME}/.home/zsh-custom/zlogin" "${HOME}/.zlogin"
  ln -s "${HOME}/.home/zsh-custom/zshenv" "${HOME}/.zshenv"

  echo "making local ~/.credentials cache"
  mkdir -p "${HOME}/.credentials"
  chmod 0700 "${HOME}/.credentials"
  
  for DFILE in "${!DOTFILES[@]}";
  do
    echo  "- ${DFILE} -> ${DOTFILES[$DFILE]}"
    ln -s "${HOME}/.home/${DFILE}" "${HOME}/${DOTFILES[$DFILE]}"
  done
}

install_personal_bin() {
  echo "installing personal scripts/binaries into home directory ..."
  git clone https://github.com/sulrich/home-bin.git "${HOME}/bin"
}


# copy my authorized ssh public key 
sync_public_ssh_keys() {
  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"
  curl -s https://github.com/sulrich.keys >> "${HOME}/.ssh/authorized_keys"
  chmod 0755 "${HOME}/.ssh/authorized_keys"
}


install_minimum_packages() {
  # install the minimum set of bootstrap tools for a host
   sudo apt install                                                             \
     build-essential curl direnv fzf git libbz2-dev libffi-dev liblzma-dev      \
     libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev \
     llvm make python3-dev python3-pip python-openssl ripgrep tmux vim-nox      \
     wget xz-utils zlib1g-dev zsh
}


print_usage() {

  cat << EOF

$0 command

available commands:

  install-bin - downloads and installs my collection of ${HOME}/bin scripts
  install-go - downloads and installs the latest version of go
  install-min-packages - (ubuntu/debian) installs my minimum set of tools
  install-omz - downloads and installs the latest version of oh-my-zsh
  install-pyenv - downloads pyenv
  install-snmp - downloads a collection of snmp mibs
  install-vim - installs vim-nox and my collection of modules.
  make-symlinks - generates the necessary dotfiles in ${HOME}
  sync-public-keys - downloads my public keys from github

command: bootstrap

  downloads the baseline repos and binaries to make a reasonably useful working
  environment.  makes dotfile symlinks, downloads the ~/bin collection and
  takes a swing at getting pyenv in working order.

command: make-symlinks

  deletes existing dotfiles or copies the dotfile to ~/dotfiles-backup and
  regenerates symlinks based on the current state of the DOTFILES list in this
  script.

command: sync-public-keys

  updates authorized_keys from the public keys posted to github.

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
    # echo "regenerating symlinks"
    # backup_dotfiles
    make_symlinks
    shift
    ;;
  sync-public-keys)
    echo "pulling down public ssh keys"
    sync_public_ssh_keys
    shift
    ;;
  install-go)
    echo "installing go-lang"
    install_go
    shift
    ;;
  install-omz)
    echo "installing oh-my-zsh"
    install_omz
    shift
    ;;
  install-bin)
    echo "installing personal scripts"
    install_personal_bin
    shift
    ;;
  install-pyenv)
    echo "installing pyenv"
    install_pyenv
    shift
    ;;
  install-min-packages)
    echo "installing essentials"
    install_minimum_packages
    shift
    ;;
  install-vim)
    echo "installing vim"
    sudo apt install vim-nox
    install_vim_modules
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
