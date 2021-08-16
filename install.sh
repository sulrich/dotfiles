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

# this will need to point at something useful, as the per-host brewfile won't
# exist yet.
BREWFILE="${HOME}/iCloud/src/configs/brewfile.txt"

PYTHON2_VER="2.7.18"
PYTHON3_VER="3.8.10"

ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm*)   dpkg --print-architecture | grep -q "arm64" && ARCH="arm64" || ARCH="armv6l" ;;
esac

# TODO: provide an option for upgrading go on raspberry pi
#
# upgrading process
# 1. check the latest version online vs. the installed version
# 2. prompt the operator to see if they want to upgrade
# 3. rm -rf /usr/local/go
# 3. run the install-go process

## install-go (sudo): pull down the latest go releas and install 
install-go() {
  echo "installing go"
  mkdir -p "${HOME}/go/bin"
  mkdir -p "${HOME}/go/src"
  mkdir -p "${HOME}/go/pkg"
  local GO_VERSION=$(curl -s "https://golang.org/VERSION?m=text")
  local GO_OS=$(uname -s | tr "[:upper:]" "[:lower:]"n)
  local FILENAME="${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz"
  echo "https://dl.google.com/go/${FILENAME} -> ${FILENAME}" 
  curl -s "https://dl.google.com/go/${FILENAME}" -o "${FILENAME}"
  sudo tar -C /usr/local -xzf "${FILENAME}"
  rm -i "${FILENAME}"
}

## install-brew: new macs only. do the needful
install-brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

## install-brew-packages: down all the cool stuff 
install-brew-packages() {
  brew bundle --file="${BREWFILE}"
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

  echo "adding neovim elements"
  if [ ! -d "${HOME}/.config" ] 
  then
    echo "adding XDG_CONFIG_HOME ..."
    git clone https://github.com/sulrich/xdg-config-home.git "${HOME}/.config"
  fi

  if [ ! -d "${HOME}/.local/share" ] 
  then
    echo "adding neovim plugins/modules"
    mkdir -p "${HOME}/.local/share"
  fi

  if [ ! -d "${HOME}/.local/share/nvim" ] 
  then
    git clone https://github.com/sulrich/nvim.git "${HOME}/.local/share/nvim"
  fi
  cd "${HOME}/.local/share/nvim" || exit
  git submodule update --init
}

# after having built pyenv end the necessary python - install
# powerline to make things look cool - this will likely have some
# local font dependencies if this is run on an actual
# workstation. (read: Mac OS)
# 

## install-pyenv: self-explanatory
install-pyenv() {
  echo "pulling down some key utilities for vim first. note, these will be"
  echo "installed locally via the --user flag"
  pip3 install black --user
  pip3 install websockets --user
  echo "cloning pyenv"
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
  echo "you'll need to re-init your shell to pick up pyenv"
}

## install-pythons: install the interesting versions of python via pyenv
install-pythons() {
  echo "installing python2 version: ${PYTHON2_VER}"
  pyenv install "${PYTHON2_VER}"
  echo "installing python3 version: ${PYTHON3_VER}"
  pyenv install "${PYTHON3_VER}"

  echo "setting pyenv global"
  pyenv global "${PYTHON3_VER}" "${PYTHON2_VER}" 
  echo "installing relevant python packages"
  pip3 install powerline-status
}

## install-docker-ubuntu (sudo): install docker
install-docker-ubuntu() {
  echo "updating the base packages"
  sudo apt-get install apt-transport-https ca-certificates \
    curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  echo "adding docker repo"
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
}

## install-poetry: self-explanatory
install-poetry() {
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py \
		> /tmp/get-poetry.py
	python /tmp/get-poetry.py
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
    ['mailcap']=".mailcap"
    ['markdownlint.yaml']=".markdownlint.yaml"
    ['octaverc']=".octaverc"
    ['screenrc']=".screenrc"
    ['sqliterc']=".sqliterc"
    ['tmux.conf']=".tmux.conf"
    ['urlview']=".urlview"
    ['vimrc']=".vimrc"
    ['zshrc']=".zshrc"
    ['zsh-custom/zlogin']=".zlogin"
    ['zsh-custom/zshenv']=".zshenv"
  )

  echo "making dotfile symlinks" 
  for DFILE in "${!DOTFILES[@]}";
  do
    echo  "- ${DFILE} -> ${DOTFILES[$DFILE]}"
    ln -s "${HOME}/.home/${DFILE}" "${HOME}/${DOTFILES[$DFILE]}"
  done

  echo "making local ~/.credentials cache"
  mkdir -p "${HOME}/.credentials"
  chmod 0700 "${HOME}/.credentials"
  echo "copy the necessary credentials into ~/.credentials"
 
}

## install-personal-bin: install personal binaries into home directory
install-personal-bin() {
  echo "installing personal scripts/binaries into home directory ..."
  git clone https://github.com/sulrich/home-bin.git "${HOME}/bin"
}

## sync-public-ssh-keys: copy my authorized ssh public keys from github
sync-public-ssh-keys() {
  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"
  # get the public sources
  curl -s https://github.com/sulrich.keys >> "${HOME}/.ssh/authorized_keys"
  # remove dups
  uniq "${HOME}/.ssh/authorized_keys" > "${HOME}/.ssh/tmp_keys"
  mv "${HOME}/.ssh/tmp_keys" "${HOME}/.ssh/authorized_keys" 
  chmod 0755 "${HOME}/.ssh/authorized_keys"
}

## install-min-packages-debian (sudo): install minimum set of tools (debian/ubuntu)
install-min-packages-debian() {
  # install the minimum set of bootstrap tools for a host
   sudo apt install                                                             \
     build-essential curl direnv fzf git libbz2-dev libffi-dev liblzma-dev      \
     libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev \
     llvm make python3-dev python3-pip python-openssl ripgrep tmux vim-nox      \
     wget xz-utils zlib1g-dev zsh neovim
}

## install-tpm: install tmux plugin manager (TPM)
install-tpm() {
  echo "cloning TPM ..."
	git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
  echo 'start tmux, and install using "C-t + I" to install'
}

## install-min-packages-centos7 (sudo) : install minimum set of tools (centos)
install-min-packages-centos7() {
  # install the minimum set of bootstrap tools for a host
  sudo yum install                                                              \
    @development bzip2 bzip2-devel curl findutils git libffi-devel              \
    ncurses-devel ncurses-libs openssl-devel readline-devel sqlite sqlite-devel \
    tmux xz xz-devel zlib-devel llvm make zsh python3 python3-devel python3-pip \
    python3-libs vim-minimal wget mtr-tiny

  # ripgrep
  sudo yum-config-manager \
       --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
  sudo yum install ripgrep
  # fzf
  # install direnv separately (no rpm available)
  curl -sfL https://direnv.net/install.sh | bash
}

## setup-ssh: bootstrap ssh config elements
setup-ssh() {
  sync-public-ssh-keys
  cp "${HOME}/.home/ssh-config-zenith" "${HOME}/.ssh/config"
  mkdir -p "${HOME}/.ssh/tmp"
  chmod 0755 "${HOME}/.ssh/tmp"
  # TODO(sulrich) - source the misc. keys from a secure backing store
}


# https://github.com/nodesource/distributions/blob/master/README.mdnstall-nodejs-debian (sudo): PPA nodjs install
## install-nodejs-debian: print pointers to installation of nodejs
install-nodejs-debian() {
  cat <<EOFMESSAGE

  the base node version in the debian packages is ancient.  run the following
  to install the 16.x relese of nodejs. note, you must be root
  ref: https://github.com/nodesource/distributions/blob/master/README.md

  curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
  apt install nodjs
EOFMESSAGE

}

## install-server-debian (sudo): install server elements (debian/ubuntu)
install-server-debian() {
  sudo apt install \
    nginx certbot ansible cifs-utils bind9 openjdk-8-jre-headless haveged \
		protobuf-compiler libprotobuf-dev libutempter-dev libboost-dev        \
  	libio-pty-perl libssl-dev pkg-config autoconf
	
	cat <<EOFMESSAGE 

	you'll need to install docker as well.  
	ref: https://docs.docker.com/compose/install/ 

EOFMESSAGE

}

## clone-config-repos: assume you're logged into github correctly
clone-config-repos() {

 local REPO_DIR="${HOME}/src/config-repos"
 mkdir -p "${REPO_DIR}"
 git clone https://github.com/sulrich/bert-nginx.git "${REPO_DIR}/nginx"
 git clone https://github.com/sulrich/bind9-botwerks.git "${REPO_DIR}/bind"
 git clone https://github.com/sulrich/zenith-docs.git "${REPO_DIR}/zenith-docs"
 git clone https://github.com/sulrich/zenith-containers.git "${REPO_DIR}/zenith-containers"
 git clone https://github.com/sulrich/ansible-private.git "${HOME}/src/ansible"
 git clone http://dyn.botwerks.net/git/sulrich/network-configs.git "${HOME}/src/network-configs"

}

# anything that has ## at the front of the line will be used as input.
help() {
  cat << EOF

usage install.sh <function>

this provides a mechanism to quickly install and align various personal
configuration elements.  when used with a fresh system, there are functions
that install the minimum set of required packages for the distro of interest.
these commands will require the use of sudo.  plan accordingly. 

available functions:
EOF
  sed -n "s/^##//p" "$0" | column -t -s ":" | sed -e "s/^/ /"
}

# keep this - it lets you run the various functions in this script
"$@"
