# -*- Mode: shell-script; tab-width: 2 -*- *
#---------------------------------------------------------------------
# setup zsh parameters
#

if [ ! -z "$STARTPWD" ]
then
  cd $STARTPWD
fi

setopt	pushdtohome cdablevars autolist automenu alwayslastprompt \
	autoparamkeys autoremoveslash chaselinks extendedhistory hashcmds \
	hashdirs histignoredups nobeep \
	longlistjobs alwaystoend \
	nobadpattern nonomatch \
	nohistbeep nohup notify path_dirs rm_star_silent \
	histignoredups pushdsilent noclobber \
	autopushd pushdminus rcquotes list_types

unsetopt bgnice correct correctall noflowcontrol markdirs pathdirs \
         recexact mailwarning notify noclobber completeinword ignore_eof \
         autocd cdablevars autoresume extendedglob

# misc. completions experiments and command line editing options
autoload -U compinit
# compinit
compctl -c type
compctl -g '*(-/) .*(-/)' cd rmdir

autoload edit-command-line
zle -N edit-command-line

bindkey '^Xe' edit-command-line
bindkey -e
bindkey '^];' spell-word

#---------------------------------------------------------------------
# aliases
#
setaliases() {
  alias -g L=" 2>&1|less"  #  page through the output, inluding STDERR
  alias -g NUL="> /dev/null 2>&1"
  alias -g TL="| tail -20"
  alias e="emacsclient"

  # git aliases for misc. stuff i do
  alias gitdiff-lastone="git diff HEAD^^ $1"
  alias gitlog-lastone="git log -p -n 1 $1"
  alias gitlog-short='git log --graph --date=short --pretty="%h %cd %cn %ce"'
  alias gitfilemode="git config core.filemode false"

  alias ll="ls -lh"
  alias lld="ls -ld -- */"
  alias ls="ls -CF"
  alias quickhttp="python3 -m http.server 4000"   # use python3 by default
  alias quickhttp2="python2 -m SimpleHTTPServer 4000"
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

  # overrides to prevent craziness from oh-my-zsh
  unalias grep
}

# the following should prevent tramp hangs in emacs
if [[ $TERM == "dumb" ]];
then
  unsetopt zle
  unset zle_bracketed_paste
  PS1='$ '
  PS3='$ '
  return
fi

if [[ -n ${INSIDE_EMACS} ]];
then
  if [[ "$INSIDE_EMACS" != 'vterm' ]];
  then
    # this shell runs inside an emacs *shell*/*term* buffer.
    # zle tends to not be happy inside of emacs shells
    unsetopt zle
    unset zle_bracketed_paste
    PS3='$ '
  fi

  if [[ "$INSIDE_EMACS" = 'vterm' ]];
  then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
  fi
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

# note: this assumes that the URL has been remapped to /prometheus and the 
# web-command elements are enabled to trigger reloads. applicable to home
# operation
function prom-reload { curl -X POST http://localhost:9090/prometheus/-/reload }

SU==su
su () {
  if [ "$1" = "" ]
  then
    ( export STARTPWD=$PWD ; cd / ; ${SU} root -c "exec zsh" )
  else
     ${SU} $*
  fi
} # end of su override

function gen-mac-addr () {
  # generate a random mac address
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
  GOOG_BLOCKS=(
    _netblocks.google.com
    _netblocks2.google.com
    _netblocks3.google.com
  )

  foreach NET ("${GOOG_BLOCKS[@]}")
    nslookup -q=TXT ${NET} 8.8.8.8;
  end
}

# output yang models in the unfurled path format.  this require's anees' nifty
# plugin which is in the openconfig repo.
function pyang-path () {
  # this is dependent on having aashaikh's pyang module installed.
  # use of --strip helps to make the output more readable.
  pyang --plugindir ${YANG_PLUGINS} --strip -f paths $*
}

# misc. git functions
function git-upstream-sync() {
  # for stuff that i am actively working on with others, work off of my fork and
  # update my $default_branch with the contents of the upstream. this is a
  # pretty common workflow.
  # determine if the repo uses master/main as the default branch name

  local DEFAULT_BRANCH=$(git remote show upstream | grep 'HEAD branch' | awk '{print $NF}')
  echo "default branch: ${DEFAULT_BRANCH}"

  if [ -z "${DEFAULT_BRANCH}" ]; then
    echo ""
    echo "the upstream rep is undefined, you will need to add an upstream repo to track"
    echo "git remote add upstream <upstream-url-here>"
    echo ""
  else
    git checkout "${DEFAULT_BRANCH}"
    git fetch upstream
    git pull upstream "${DEFAULT_BRANCH}"
    git push origin "${DEFAULT_BRANCH}"
  fi
}

# 1password CLI functions
OP_ACCOUNT_NAME="botzinski"
function 1p-on() {
  if [[ -z ${OP_SESSION_botzinski} ]]; then
    eval $(op signin "${OP_ACCOUNT_NAME}")
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

umask 002
setaliases

# completion kits --------------------------------------------------------------
# these aren't necessarily going to be available everywhere.
#
# enable misc. completions available from homebrew
fpath=(/usr/local/share/zsh-completions $fpath)

# google CLI
if [ -e "${HOME}/src/google-cloud-sdk/completion.zsh.inc" ]
then
  source "${HOME}/src/google-cloud-sdk/completion.zsh.inc"
fi

# enable AWS CLI completion
if [ -e /usr/local/share/zsh/site-functions/_aws ]
then
  source /usr/local/share/zsh/site-functions/_aws
fi

## azure completion - begin. generated by omelette ###
if type compdef &>/dev/null; then
  _azure_complette() {
    compadd -- `azure --compzsh --compgen "${CURRENT}" "${words[CURRENT-1]}" "${BUFFER}"`
  }
  compdef _azure_complette azure
elif type complete &>/dev/null; then
  _azure_complette() {
    COMPREPLY=( $(compgen -W '$(azure --compbash --compgen "${COMP_CWORD}" "${COMP_WORDS[COMP_CWORD-1]}" "${COMP_LINE}")' -- "${COMP_WORDS[COMP_CWORD]}") )
  }
  complete -F _azure_complette azure
fi
### azure completion - end ###

#-------------------------------------------------------------------------------
## additional modules / functions for various activities

# pull in platform specific configuration - note this needs to be somewhere
# other than the ZSH_CUSTOM directory otherwise everything gets pulled in.
if [ -e "${HOME}/.home/zsh-custom/platform/$(uname).zsh" ]
then
  source "${HOME}/.home/zsh-custom/platform/$(uname).zsh"
fi

# pull in host specific configuration elements - same as re: platform specific
# config elements in terms of placement
if [ -e "${HOME}/.home/zsh-custom/hosts/$(hostname).zsh" ]
then
  source "${HOME}/.home/zsh-custom/hosts/$(hostname).zsh"
fi

if [[ $TERM != "dumb" && -z "${INSIDE_EMACS}" ]];
then
  # enable iterm zsh integration if it's available
  # exclude dumb terminals so that tramp for emacs, etc. works
  # also exclude from inside of emacs so that ansi-term, etc. works.
  test -e "${HOME}/.iterm2_shell_integration.zsh" && \
    source "${HOME}/.iterm2_shell_integration.zsh"
fi

# load the direnv overrides
eval "$(direnv hook zsh)"

