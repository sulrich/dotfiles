#!/usr/bin/env bash
# -*- mode: sh; fill-column: 78; comment-column: 50; tab-width: 2 -*-

set -euo pipefail

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

# map uname -m onto the arch strings go uses in its release filenames
ARCH=""
case $(uname -m) in
  i386|i686)     ARCH="386" ;;
  x86_64)        ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  # go only publishes armv6l for 32-bit arm
  armv6l|armv7l) ARCH="armv6l" ;;
esac

# TODO: provide an option for upgrading go on raspberry pi
#
# upgrading process
# 1. check the latest version online vs. the installed version
# 2. prompt the operator to see if they want to upgrade
# 3. rm -rf /usr/local/go
# 3. run the install-go process

## install-go (sudo): pull down the latest go release and install
install-go() {
  if [ -z "${ARCH}" ]
  then
    echo "error: unsupported architecture $(uname -m)" >&2
    return 1
  fi

  mkdir -p "${HOME}/go/bin" "${HOME}/go/src" "${HOME}/go/pkg"

  local GO_VERSION GO_OS FILENAME GO_TMP
  # note: golang.org/VERSION now redirects, and the response carries the
  # version on the first line with a build timestamp on the second
  GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text")
  GO_VERSION=${GO_VERSION%%$'\n'*}
  if [ -z "${GO_VERSION}" ]
  then
    echo "error: could not determine the latest go version" >&2
    return 1
  fi

  GO_OS=$(uname -s | tr "[:upper:]" "[:lower:]")
  FILENAME="${GO_VERSION}.${GO_OS}-${ARCH}.tar.gz"
  GO_TMP=$(mktemp -d)

  echo "installing ${GO_VERSION} (${GO_OS}-${ARCH})"
  curl -fsSL "https://dl.google.com/go/${FILENAME}" -o "${GO_TMP}/${FILENAME}"
  # unpacking over an existing tree leaves stale files behind - go's install
  # instructions call for removing it first
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "${GO_TMP}/${FILENAME}"
  rm -rf "${GO_TMP}"
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

## install-language-servers (sudo): install relevant lsps for nvim
install-language-servers() {
  # install python language server (pyright)
  npm install -g pyright
  # install go language server
  go install golang.org/x/tools/gopls@latest
}

## install-snmp-mibs: pull down the collection of mibs
install-snmp-mibs() {
  mkdir -p "${HOME}/.snmp"
  local MIB_TAR
  MIB_TAR=$(mktemp)
  echo "downloading various SNMP mibs"
  curl -fsSL https://dyn.botwerks.net/mibs/mibs.tar.gz -o "${MIB_TAR}"
  echo "expanding mibs to ${HOME}/.snmp/mibs"
  tar -C "${HOME}/.snmp" -xzf "${MIB_TAR}"
  rm -f "${MIB_TAR}"
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

# associative arrays need bash 4.0+, and macos still ships 3.2
require-bash4() {
  if [ "${BASH_VERSINFO:-0}" -lt 4 ]
  then
    echo "error: bash 4.0+ required (running ${BASH_VERSION:-unknown})" >&2
    exit 1
  fi
}

# link-dotfile <source> <target>: symlink source -> target, idempotently.
# a target already pointing at source is left alone, as is anything else
# occupying the target.  a missing source is reported rather than linked, so we
# don't litter the home directory with dangling symlinks.
link-dotfile() {
  local SRC="$1"
  local DST="$2"

  if [ ! -e "${SRC}" ]
  then
    echo "  ! ${DST} - missing source ${SRC}"
    return 1
  fi

  if [ -L "${DST}" ]
  then
    local CURRENT
    CURRENT=$(readlink "${DST}")
    if [ "${CURRENT}" = "${SRC}" ]
    then
      echo "  = ${DST}"
      return 0
    fi
    echo "  ! ${DST} - points at ${CURRENT}, leaving it alone"
    return 1
  fi

  if [ -e "${DST}" ]
  then
    echo "  ! ${DST} - exists and is not a symlink, leaving it alone"
    return 1
  fi

  mkdir -p "$(dirname "${DST}")"
  ln -s "${SRC}" "${DST}"
  echo "  + ${DST} -> ${SRC}"
}

## make-symlinks: make the necessary symlinks
make-symlinks() {
  require-bash4

  # repo-relative path -> path relative to ${HOME}
  declare -A DOTFILES
  DOTFILES=(
    ['ansible.cfg']=".ansible.cfg"
    ['cloginrc']=".cloginrc"
    ['digrc']=".digrc"
    ['flake8']=".flake8"
    ['git/gitconfig']=".gitconfig"
    ['git/gitconfig-personal']=".gitconfig-personal"
    ['git/gitignore']=".gitignore"
    # .gitconfig is useless without this - it's an unconditional [include]
    ['gitconfig-conditional']=".gitconfig-conditional"
    ['markdownlint.json']=".markdownrc"
    ['ruff.toml']=".ruff.toml"
    ['screenrc']=".screenrc"
    ['sqliterc']=".sqliterc"
    ['templates']=".templates"
    ['tmux.conf']=".tmux.conf"
    ['vale.ini']=".vale.ini"
    ['vimrc']=".vimrc"
    ['zshrc']=".zshrc"
    ['zsh/zlogin']=".zlogin"
    ['zsh/zshenv']=".zshenv"
    ['ssh/config']=".ssh/config"
  )

  local SKIPPED=0

  echo "making dotfile symlinks"
  local DFILE
  for DFILE in "${!DOTFILES[@]}";
  do
    if ! link-dotfile "${HOME}/.home/${DFILE}" "${HOME}/${DOTFILES[$DFILE]}"
    then
      SKIPPED=$((SKIPPED + 1))
    fi
  done

  # ssh/config pulls in the platform fragments via "Include conf.d/*"
  mkdir -p "${HOME}/.ssh/tmp"
  local BASEOS
  BASEOS=$(uname -s | tr "[:upper:]" "[:lower:]")
  if ! link-dotfile "${HOME}/.home/ssh/${BASEOS}" "${HOME}/.ssh/conf.d"
  then
    SKIPPED=$((SKIPPED + 1))
  fi

  # git doesn't track the permissions ssh insists on
  "${HOME}/.home/bin/ssh-fix-perms.sh"

  echo "making local ~/.credentials cache"
  mkdir -p "${HOME}/.credentials"
  chmod 0700 "${HOME}/.credentials"
  echo "populate ~/.credentials with 'op inject' - see README.md"

  if [ "${SKIPPED}" -gt 0 ]
  then
    echo "${SKIPPED} link(s) skipped - see the '!' lines above" >&2
    return 1
  fi
}

## install-personal-bin: install personal binaries into home directory
install-personal-bin() {
  echo "installing personal scripts/binaries into home directory ..."
  git clone https://github.com/sulrich/home-bin.git "${HOME}/bin"
}

## sync-public-ssh-keys: copy my authorized ssh public keys from the
##                     : appropriate repo (nexthop, github, botwerks)
sync-public-ssh-keys() {
  require-bash4

  mkdir -p "${HOME}/.ssh"
  chmod 0700 "${HOME}/.ssh"

  declare -A PUBKEYS
  PUBKEYS=(
    ['nh']="https://github.com/sulrich-nexthop.keys"
    ['github']="https://github.com/sulrich.keys"
    ['botwerks']="https://botwerks.net/sulrich.keys"
  )

  local AUTH_KEYS="${HOME}/.ssh/authorized_keys"
  local NEW_KEYS
  NEW_KEYS=$(mktemp)

  # start from what's already there so locally added keys survive the sync
  if [ -f "${AUTH_KEYS}" ]
  then
    cat "${AUTH_KEYS}" >> "${NEW_KEYS}"
  fi

  local KEY
  for KEY in "${!PUBKEYS[@]}";
  do
    echo "fetching ${KEY} keys"
    if ! curl -fsS "${PUBKEYS[$KEY]}" >> "${NEW_KEYS}"
    then
      echo "error: could not fetch ${KEY} keys from ${PUBKEYS[$KEY]}" >&2
      rm -f "${NEW_KEYS}"
      return 1
    fi
    # not every source ends its output with a newline
    echo >> "${NEW_KEYS}"
  done

  # uniq only collapses *adjacent* duplicates and the keys arrive interleaved,
  # so sort first.  key order in authorized_keys is not significant.
  sort -u "${NEW_KEYS}" | sed '/^[[:space:]]*$/d' > "${AUTH_KEYS}"
  rm -f "${NEW_KEYS}"
  chmod 0600 "${AUTH_KEYS}"
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

## bootstrap-debian-1 (sudo): install the elements to make server happy
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

# installed here rather than at the top of the file so an early failure can't
# fire the trap before cleanup() is defined
trap cleanup SIGINT SIGTERM ERR EXIT

if [[ $# -lt 1 ]]; then
  help
  exit
fi

CMD="$1"
shift

# dispatch only to functions defined in this script, otherwise "install.sh rm"
# would cheerfully run rm
if ! declare -F "${CMD}" > /dev/null
then
  echo "error: unknown function '${CMD}'" >&2
  help
  exit 1
fi

"${CMD}" "$@"
