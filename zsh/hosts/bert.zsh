# host specific functions for interacting w/internal services
fpath=(/usr/local/share/zsh-completions $fpath)

if [ -e "${HOME}/.clawdock/clawdock-helpers.sh" ]
then
  source "${HOME}/.clawdock/clawdock-helpers.sh"
fi

