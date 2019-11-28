#!/bin/bash

# create the framework of dotfiles, etc that i use on a standard unix system.
# this presumes that i'm setting up shop on a new machine / laptop.  

# make sure that direnv is installed 

# installation script to pull down the necessary configuration files for me to
# bootstrap a machine.

# Xdefaults ansible.cfg cloginrc flake8 gitconfig gitignore gnupg gvimrc mailcap
# octaverc pb.sh screenrc sqliterc tmux.conf urlview vimrc

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
  cd "${HOME}/.vim"
  git submodule update --init
  cd "${HOME}"
}

# pull down pyenv
install_pyenv(){
  echo "downloading various SNMP mibs"
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
}

make_symlinks() {
  echo "making dotfile symlinks" 

}

install_personal_bin() {
  echo "installing personal scripts/binaries ..."


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
  curl -s https://github.com/sulrich.keys >> "${HOME}/.ssh/authorized_keys"
}


