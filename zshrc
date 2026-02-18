# -*- Mode: shell-script; tab-width: 2 -*- *
#---------------------------------------------------------------------
# setup zsh parameters
#

if [ ! -z "$STARTPWD" ]
then
  cd $STARTPWD
fi

setopt ALWAYSLASTPROMPT
setopt ALWAYSTOEND
setopt AUTOLIST
setopt AUTOMENU
setopt AUTOPARAMKEYS
setopt AUTOPUSHD
setopt AUTOREMOVESLASH
setopt CDABLEVARS
setopt CHASELINKS
setopt HASHCMDS
setopt HASHDIRS
setopt HISTIGNOREDUPS
setopt LIST_TYPES
setopt LONGLISTJOBS
setopt NOBADPATTERN
setopt NOBEEP
setopt NOCLOBBER
setopt NOHISTBEEP
setopt NOHUP
setopt NONOMATCH
setopt NOTIFY
setopt PATH_DIRS
setopt PUSHDMINUS
setopt PUSHDSILENT
setopt PUSHDTOHOME
setopt RCQUOTES
setopt RM_STAR_SILENT

unsetopt AUTOCD
unsetopt AUTORESUME
unsetopt BGNICE
unsetopt CDABLEVARS
unsetopt COMPLETEINWORD
unsetopt CORRECT
unsetopt CORRECTALL
unsetopt EXTENDEDGLOB
unsetopt IGNORE_EOF
unsetopt MAILWARNING
unsetopt MARKDIRS
unsetopt NOCLOBBER
unsetopt NOFLOWCONTROL
unsetopt NOTIFY
unsetopt PATHDIRS
unsetopt RECEXACT

bindkey -e

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

bindkey '^];' spell-word

umask 002

## misc prompt frobbing - mostly so i can hint the status of git
# this replaced the only useful thing i had in oh-my-zsh
autoload -U colors && colors  # enable colors in prompts
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$fg[red]%}●%{$fg[white]%}%{$reset_color%}" # %c in vcs_info_msg_0_
zstyle ':vcs_info:*' unstagedstr "%{$fg[blue]%}●%{$fg[white]%}%{$reset_color%}" # %u in vcs_info_msg_0_
zstyle ':vcs_info:*' formats '[%b%c%u]' # %b is the branch %c and %u are tickled as noted above
precmd() {
    vcs_info
}

setopt prompt_subst
PS1="%m(%2~)\${vcs_info_msg_0_}%% "

## history handling
setopt APPEND_HISTORY            # append to history file
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # do not record an event starting with a space.
setopt HIST_NO_STORE             # don't store history commands
setopt HIST_SAVE_NO_DUPS         # do not write a duplicate event to the history file.
setopt HIST_VERIFY               # do not execute immediately upon history expansion.
setopt INC_APPEND_HISTORY        # write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # share history between all sessions.

#---------------------------------------------------------------------
# aliases
#
setaliases() {
  alias -g L=" 2>&1 | less"  #  page through the output, inluding STDERR
  # redirect stderr to /dev/null
  alias -g NE="2>/dev/null"
  # redirect stdout to /dev/null
  alias -g NO=">/dev/null"
  # redirect both stdout and stderr to /dev/null
  alias -g NUL="> /dev/null 2>&1"

  # misc. git aliases
  alias gitdiff-lastone="git diff HEAD^^ $1"
  alias gitlog-lastone="git log -p -n 1 $1"
  alias gitlog-short='git log --graph --date=short --pretty="%h %cd %cn %ce"'
  alias git-set-filemode="git config core.filemode false"

  alias ll="ls -lh"
  alias lla="ls -lha"
  alias lld="ls -ld -- */"
  alias ls="ls -CF"
  alias quickhttp="python3 -m http.server 4000"   # use python3 by default
  alias rm="rm -f"
  alias vi="vim"
  alias mutt="neomutt"   # mutt is dead, long live mutt.

  # mess with escaping jq stuff at your own risk
  alias json2path="jq '[leaf_paths as \$p | {'key': \$p | join(\"/\"), 'value': getpath(\$p)}] | from_entries'"
  alias jspp="python -m json.tool $1"

  # the following requires imagemagick to be installed
  alias mkwebp="convert $1 -quality 100 -define webp-:lossless=true $2"
  # get rid of those annoying git filemode issues
  alias findtags="egrep -i '(#{1}[[:alpha:]]{2,}\s)'"

  # makes logging into lab routers handy
  alias ago="TERM=vt100 ssh -l admin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  # when logging into netlab or sonic devices with the standard credentials.
  alias sgo="TERM=vt100 sshpass -f ${HOME}/.credentials/sonic-pass.txt ssh $@"
  alias ngo="TERM=vt100 sshpass -f ${HOME}/.credentials/nh-dut-pass.txt ssh $@"

  # parse ownership vouchers.  in reality, this is just invoking openssl with
  # the right flags to snarf the cert/signing elements from a DER formatted file
  alias ov-parse="openssl asn1parse -inform der -in $1"

  alias hh="hopperhelper"

  if [ $+commands[nvim] == "1" ]
  then
    alias vim="nvim"  # always use nvim where possible
  fi
}

# the following should prevent tramp hangs in emacs. this is useful in some
# other odd terminal scenarios as well.
if [[ $TERM == "dumb" ]];
then
  unsetopt zle
  unset zle_bracketed_paste
  PS1='$ '
  PS3='$ '
  return
fi


#---------------------------------------------------------------------
# functions
#
# misc. handy one liners
#function strip-blank () { cat $1 | awk '$0!~/^$/ {print $0}' }
function strip-blank () { sed '/^[[:space:]]*$/d' < $1 }
function debug() { [ "$DEBUG" ] && echo ">>> $*"; }
function mwhois { whois -h `whois "domain $@" | sed '/^.*Whois Server:/!d;s///'` "$@" }
function asnwhois { whois -h whois.cymru.com " -v AS$1" }

function update-tmux-ssh () {
  if [[ -n "$TMUX" ]]; then
    while IFS='=' read -r key value; do
      [[ -n "$value" ]] && export "$key"="$value"
    done < <(tmux show-environment | grep '^SSH_.*=')
  fi
}

function upgrade-uv-tools() {
  uv self update
  foreach i ($(uv tool list | egrep -iv '^-' | awk '{print $1}'))
    uv tool install $i --upgrade;
  end
}

SU==su
su () {
  if [ "$1" = "" ]
  then
    ( export STARTPWD=$PWD ; cd / ; ${SU} root -c "exec zsh" )
  else
     ${SU} $*
  fi
} # end of su override

# generate a random mac address
function gen-mac-addr () {
  printf 'DE:CA:FB:AD:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))
}

# get the difference between to YYYYMMDD formatted dates. note,
# requires gdate.
function date-diff() {
  local DIFF=(`gdate +%s -d $1`-`gdate +%s -d $2`)/86400
  echo $DIFF
}

# get a list of the google netblocks.  not necessarily definitive, but gives
# you a good idea of what you should be seeing.
function google-nets () {
  local GOOG_BLOCKS=(
    _netblocks.google.com
    _netblocks2.google.com
    _netblocks3.google.com
  )

  foreach NET ("${GOOG_BLOCKS[@]}")
    nslookup -q=TXT ${NET} 8.8.8.8;
  end
}

# pb-nh
function pb-nh() {
  jq -Rns '{text: inputs}' | \
    curl  -s -H 'Content-Type: application/json' --data-binary @- ${WBIN_API_URL}/ | \
    jq -r '. | "'${WBIN_API_URL}'\(.path)"'
}

# personal configuration update
function personal-config-update()  {
  # pull updates from git to keep things in sync
  local CONFIG_DIRS=(
    "${HOME}/.home"
    "${HOME}/.config/nvim"
    "${HOME}/bin"
  )

  foreach CONFIG_DIR ("${CONFIG_DIRS[@]}")
    echo "${CONFIG_DIR} - sync"
    cd "${CONFIG_DIR}"
    git pull
  end

  # ensure that ssh files have the right permissions
  ${HOME}/.home/bin/ssh-fix-perms.sh
}

# output yang models in the unfurled path format.  this requires anees' nifty
# plugin which is in the openconfig repo.
function pyang-path () {
  # use of --strip helps to make the output more readable.
  pyang --plugindir ${YANG_PLUGINS} --strip -f paths $*
}

# misc. git functions
# create a uniquely named branch for blog PRs - to be run from $HUGO_DIR
function blog-branch() {
  local BRANCH_NAME="$(date +"%Y%m%d")-${HOSTNAME}-updates"
  git co -b "${BRANCH_NAME}"
}

function git-upstream-sync() {
  # for stuff that i am actively working on with others, work off of my fork and
  # update my $default_branch with the contents of the upstream. this is a
  # pretty common workflow.
  # determine if the repo uses master/main as the default branch name
  #
  # i need to remember to set the upstream for this first. this done by adding
  # the upstream a la "git remote add upstream <upstream-repo-url>
  #
  # make changes to the new branch by doing ...
  # git checkout -b <my-new-branch>
  # git push --set-upstream origin <my-new-branch>

  local DEFAULT_BRANCH=$(git remote show upstream | grep 'HEAD branch' | awk '{print $NF}')
  echo "default branch: ${DEFAULT_BRANCH}"

  if [ -z "${DEFAULT_BRANCH}" ]; then
    echo ""
    echo "ERROR: the upstream rep is undefined, you will need to add an upstream"
    echo "ERROR: repo to track git remote add upstream <upstream-url-here>"
    echo ""
  else
    git checkout "${DEFAULT_BRANCH}"
    git fetch upstream
    git pull upstream "${DEFAULT_BRANCH}"
    git push origin "${DEFAULT_BRANCH}"
  fi
}

function git-pull-all-branches() {
  git branch -r                                        |\
  grep -v '\->'                                        |\
  sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"                     |\
    while read remote;                                  \
    do                                                  \
      git branch --track "${remote#origin/}" "$remote"; \
    done
}

function github-https2ssh() {
  # get the current directory's git remote origin url
  local origin_url=$(git config --get remote.origin.url)

  # check if it's an https url
  if [[ $origin_url == https://github.com/* ]]; then
    # extract username and repo name from the https url
    local username_repo=${origin_url#https://github.com/}
    username_repo=${username_repo%.git}

    # generate the new ssh url with custom profile
    local new_url="github-sulrich:/${username_repo}.git"

    # prompt for confirmation
    echo "current origin url: $origin_url"
    echo "new origin url: $new_url"
    read -q "REPLY?change the remote origin url? [Y/n] "
    echo ""

    if [[ $REPLY =~ ^[Yy]$ || $REPLY = "" ]]; then
      git remote set-url origin $new_url
      echo "origin url updated to: $(git config --get remote.origin.url)"
    else
      echo "operation cancelled"
    fi
  else
    echo "current origin url is not https: $origin_url"
  fi
}

# 1password CLI functions
OP_ACCOUNT_NAME="botzinski"
function 1p-on() {
  if [[ -z ${OP_SESSION_botzinski} ]]; then
    # eval $(op signin "${OP_ACCOUNT_NAME}")
    eval $(op signin)
  fi
}

function 1p-off() {
  op signout
  unset OP_SESSION_botzinski
}

function get-1pass-passwd() {
  1p-on
  op get item "$1" --fields password
}

# API tokens use the credential field.
function get-1pass-api-token() {
  1p-on
  op get item "$1" --fields credential
}

setaliases # load the aliases

# completion kits --------------------------------------------------------------
# these aren't necessarily going to be available everywhere.
#
# enable misc. completions from various sources
# note that $fpath is a list, not a colon-delimited string
fpath=(/opt/homebrew/share/zsh-completions  ${HOME}/.home/zsh/completions $fpath)

# note that zsh requires the completion directories be reasonably secured. check
# compaudit for info on problematic directories and adjust permissions and
# ownership accordingly

# tickle the completion elements in zsh
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
zmodload -i zsh/complist
compctl -c type
compctl -g '*(-/) .*(-/)' cd rmdir

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # i love this
setopt always_to_end

if [ $+commands[aws_completer] == "1" ]
then
  complete -C 'aws_completer' aws
fi

# :completion:<function>:<completer>:<command>:<argument>:<tag>
# define completers
zstyle ':completion:*' completer _extensions _complete _approximate

# use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "{HOME}/.config/zsh/.zcompcache"
# complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true
zstyle ':completion:*' verbose yes

# the following matcher-list enables matching on substrings in filenames, etc.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# google CLI
if [ -e "${HOME}/src/google-cloud-sdk/completion.zsh.inc" ]
then
  source "${HOME}/src/google-cloud-sdk/completion.zsh.inc"
fi

# note the following is a zsh-specific check for the existence of a command.
# if [ $+commands[kubectl] == "1" ]
# then
#   source <(kubectl completion zsh)
# fi

#-------------------------------------------------------------------------------
## additional modules / functions for various activities

# pull in platform specific configuration - note this needs to be somewhere
# other than the ZSH_CUSTOM directory otherwise everything gets pulled in.
if [ -e "${HOME}/.home/zsh/platform/${PLATFORM}.zsh" ]
then
  source "${HOME}/.home/zsh/platform/${PLATFORM}.zsh"
fi

# pull in host specific configuration elements - same as re: platform specific
# config elements in terms of placement
if [ -e "${HOME}/.home/zsh/hosts/${HOSTNAME}.zsh" ]
then
  source "${HOME}/.home/zsh/hosts/${HOSTNAME}.zsh"
fi

# pull in the relevant 1password plugin credentials for github, etc.
if [ -e "${HOME}/.config/op/plugins.sh" ]
then
  source "${HOME}/.config/op/plugins.sh"
fi

# load the direnv overrides
if [ $+commands[direnv] == "1" ]
then
  eval "$(direnv hook zsh)"
fi
