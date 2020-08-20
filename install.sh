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

## install-go: pull down the latest go releas and install 
install-go() {
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

## install-omz: install oh-my-zsh
install-omz() {
  echo "making home src directory"
  mkdir -p "${HOME}/src"
  echo "cloning oh-my-zsh"
  git clone https://github.com/robbyrussell/oh-my-zsh.git "${HOME}/src/zsh"
}

## install-snmp-mibs: pull down the collection of mibs
install-snmp-mibs() {
  echo "downloading various SNMP mibs"
  curl -sf https://dyn.botwerks.net/mibs/mibs.tar.gz 
} 

# pull down my vim config
## install-vim-modules: pull down git repos and init
install-vim-modules() {
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

## install-pyenv: self-explanatory
install-pyenv(){
  echo "pulling down some key utilities for vim first. note, these will be"
  echo "installed locally via the --user flag"
  pip3 install black --user
  pip3 install websockets --user
  echo "cloning pyenv"
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
  echo "you'll need to re-init your shell to pick up pyenv"
}

## make-symlinks: make the necessary symlinks
make-symlinks() {
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

## install-perosnal-bin: install personal binaries into home directory
install-personal-bin() {
  echo "installing personal scripts/binaries into home directory ..."
  git clone https://github.com/sulrich/home-bin.git "${HOME}/bin"
}


## sycn-public-ssh-keys: copy my authorized ssh public keys from github
sync-public-ssh-keys() {
  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"
  curl -s https://github.com/sulrich.keys >> "${HOME}/.ssh/authorized_keys"
  chmod 0755 "${HOME}/.ssh/authorized_keys"
}


## install-min-packages-ubuntu: installs my minimum set of tools (ubuntu)
install-minimum-packages-ubuntu() {
  # install the minimum set of bootstrap tools for a host
   sudo apt install                                                             \
     build-essential curl direnv fzf git libbz2-dev libffi-dev liblzma-dev      \
     libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev \
     llvm make python3-dev python3-pip python-openssl ripgrep tmux vim-nox      \
     wget xz-utils zlib1g-dev zsh
}

## install-min-packages-centos7: installs my minimum set of tools (centos)
install-minimum-packages-centos7() {
  # install the minimum set of bootstrap tools for a host
  sudo yum install                                                               \
    @development bzip2 bzip2-devel curl findutils git libffi-devel               \
    ncurses-devel ncurses-libs openssl-devel readline-devel sqlite sqlite-devel  \
    tmux xz xz-devel zlib-devel llvm make zsh python3 python3-devel python3-pip  \
    python3-libs vim-minimal wget

  # ripgrep
  sudo yum-config-manager \
       --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
  sudo yum install ripgrep
  # fzf
  # install direnv separately (no rpm available)
  curl -sfL https://direnv.net/install.sh | bash
}



# anything that has ## at the front of the line will be used as input.
help() {
  echo "available functions:"
  sed -n "s/^##//p" "$0" | column -t -s ":" | sed -e "s/^/ /"
}

# keep this - it lets you run the various functions in this script
"$@"



