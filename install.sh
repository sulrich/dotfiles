#!/usr/bin/env bash
# -*- mode: sh; fill-column: 78; comment-column: 50; tab-width: 2 -*-

trap cleanup SIGINT SIGTERM ERR EXIT

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
BREWFILE="${HOME}/iCloud/src/configs/krustini/brew-file.txt"

PYTHON2_VER="2.7.18"
PYTHON3_VER="3.12.7"

ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm*)   ARCH="$(uname -m)"
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
  local GO_OS=$(uname -s | tr "[:upper:]" "[:lower:]")
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

## install-fzf: new servers only
install-fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install"
}

## install-brew-packages: down all the cool stuff
install-brew-packages() {
  brew bundle --file="${BREWFILE}"
}

## install-language-servers (sudo): intall relevant lsps for nvim
install-language-servers() {
  # install python language server (pyright)
  npm install -g pyright
  # install go language server
  go install golang.org/x/tools/gopls@latest
}

## install-snmp-mibs: pull down the collection of mibs
install-snmp-mibs() {
  mkdir -p "${HOME}/.snmp"
  echo "downloading various SNMP mibs"
  curl -s https://dyn.botwerks.net/mibs/mibs.tar.gz -o "${HOME}/.home/mibs.tar.gz"
  echo "expanding mibs to ${HOME}/.snmp/mibs"
  cd "${HOME}/.snmp" || return
  tar xzf "${HOME}/.home/mibs.tar.gz"
  rm -i "${HOME}/.home/mibs.tar.gz"
}

## install-1pass-apt: install 1password in apt based systems
install-1pass-apt() {
  # ref: https://developer.1password.com/docs/cli/get-started/
  # install key
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
  # install apt repo 
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
  # more debsig stuff
  sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
  sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  # freshen apt and install
  sudo apt update && sudo apt install 1password-cli
}

# pull down my vim config
## install-neovim-config: pull down config git repos and neovim config
install-neovim-config() {
  echo "adding neovim config..."
  if [ ! -d "${HOME}/.config" ]
  then
    echo " - adding XDG_CONFIG_HOME"
    git clone https://github.com/sulrich/xdg-config-home.git "${HOME}/.config"
  fi

  if [ ! -d "${HOME}/.config/nvim" ]
  then
    echo " - adding neovim config dir"
    git clone https://github.com/sulrich/nvim.git "${HOME}/.config/nvim"
  fi

  if [ ! -d "${HOME}/.local/share" ]
  then
    echo " - adding neovim plugins/modules location"
    mkdir -p "${HOME}/.local/share"
  fi
}

## install-uv: self-explanatory
install-uv() {
  # this should work across linux and mac (will place into ~/.local/bin/)
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo 'make sure to install the relevant pythons via "uv python install"'
}

## TODO(sulrich) - install the critical set of uv tools for happy operation.

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
    ['digrc']=".digrc"
    ['flake8']=".flake8"
    ['git/gitconfig']=".gitconfig"
    ['git/gitconfig-personal']=".gitconfig-personal"
    ['git/gitignore']=".gitignore"
    ['mailcap']=".mailcap"
    ['markdownlint.json']=".markdownlintrc"
    ['octaverc']=".octaverc"
    ['ruff.toml']=".ruff.toml"
    ['screenrc']=".screenrc"
    ['sqliterc']=".sqliterc"
    ['templates']=".templates"
    ['tmux.conf']=".tmux.conf"
    ['urlview']=".urlview"
    ['vale.ini']=".vale.ini"
    ['zshrc']=".zshrc"
    ['zsh/zlogin']=".zlogin"
    ['zsh/zshenv']=".zshenv"
    ['ssh/config']=".ssh/config"
  )

  # ssh specific elements
  mkdir -p "${HOME}/.ssh/tmp"
  # git isn't always great re: permissions
  chmod -R 0755 "${HOME}/.home/ssh"
  chmod 0755 "${HOME}/.ssh/tmp"
  # put platform specific ssh elements into place
  local BASEOS=$(uname -s | tr "[:upper:]" "[:lower:]")
  ln -s "${HOME}/.home/ssh/${BASEOS}" "${HOME}/.ssh/conf.d"

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

## sync-public-ssh-keys: copy my authorized ssh public keys from the 
##                     : appropriate repo (arista, github, botwerks)
sync-public-ssh-keys() {
  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"

  declare -A PUBKEYS
  PUBKEYS=(
    #['arista']="https://gitlab.aristanetworks.com/sulrich.keys"
    ['github']="https://github.com/sulrich.keys"
    ['botwerks']="https://botwerks.net/sulrich.keys"
  )
  for KEY in "${!PUBKEYS[@]}";
  do
    # get the public ssh key
    curl -s ${PUBKEYS[$KEY]} >> "${HOME}/.ssh/authorized_keys"
  done
      
  # remove dups
  uniq "${HOME}/.ssh/authorized_keys" > "${HOME}/.ssh/tmp_keys"
  mv "${HOME}/.ssh/tmp_keys" "${HOME}/.ssh/authorized_keys"
  chmod 0755 "${HOME}/.ssh/authorized_keys"
}

## install-min-packages-debian (sudo): install minimum set of tools (debian/ubuntu)
install-min-packages-debian() {
  # install the minimum set of bootstrap tools for a host
  # the following is a little bit of gravy to install the latest neovim
   sudo add-apt-repository ppa:neovim-ppa/unstable
   sudo apt update
   # base packages installation
   echo "base linux package installation..."
   sudo apt install                                                            \
     bpfcc-tools bpftrace build-essential curl direnv ethtool fzf git          \
     iproute2 libbz2-dev libffi-dev liblzma-dev libncurses5-dev                \
     libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev                \
     linux-tools-common llvm make neovim nicstat numactl procps python3-dev    \
     python3-openssl python3-pip ripgrep sysstat tcpdump tiptop tmux trace-cmd \
     util-linux vim-nox wget xz-utils zlib1g-dev zsh
}

## install-tpm: install tmux plugin manager (TPM)
install-tpm() {
  echo "cloning TPM ..."
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
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
    nginx certbot ansible cifs-utils bind9 openjdk-8-jre-headless haveged   \
		protobuf-compiler libprotobuf-dev libutempter-dev libboost-dev          \
  	libio-pty-perl libssl-dev pkg-config autoconf ack python3-certbot-nginx \
    whois

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

## bootstrap-deb-1 (sudo): install the elements to make server happy
bootstrap-debian-1() {
  install-server-debian
  install-min-packages-debian
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

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here, tmp files, etc.
}

if [[ $# -lt 1 ]]; then
  help
  exit
fi

case $1 in
  *)
    # shift positional arguments so that arg 2 becomes arg 1, etc.
    CMD=$1
    shift 1
    ${CMD} ${@} || help
    ;;
esac
