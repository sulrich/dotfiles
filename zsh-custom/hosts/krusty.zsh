# arista specific functions for interacting w/internal services
fpath=(/usr/local/share/zsh-completions $fpath)

case-blurb() {
  local CASEBLURB="${HOME}/.home/templates/text/case-blurb.txt"
  if [ "$1" = "" ]
  then
    cat <<EOFUSAGE

usage: 
  case-blurb <case-number> - where the case-number is a whitespace-free string

EOFUSAGE

  else
    sed "s/%%CASE_NUM%%/${1}/g" < ${CASEBLURB}
  fi
}

function clab-start() {
  docker run --rm -it --privileged                 \
      --network host                               \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /var/run/netns:/run/netns                 \
      --pid="host"                                 \
      -w $CLAB_DIR                                 \
      -v $CLAB_DIR:$CLAB_DIR                       \
      ghcr.io/srl-labs/clab bash
}
# misc. arista specific aliases
alias ago="TERM=vt100 ssh -l admin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
source "${HOME}/.home/pb.sh"
