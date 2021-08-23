# arista specific functions for interacting w/internal services
fpath=(/usr/local/share/zsh-completions $fpath)

# mail rollover tools - tis moves my mailbox to the right spot
rolloutbox () {
  ARCH_YEAR=$(date -v -2m +%Y)
  ARCH_BASE=${HOME}/Documents/archives/mail/${ARCH_YEAR}/outbox
  ${HOME}/bin/split-maildirs.pl --keep_recent --arch_dir=$ARCH_BASE -src_dir=${HOME}/mail outbox
}

# kill offlineimap instances and clean up the lock file. 
koff () {
  pkill -if offlineimap
  rm "${HOME}/.offlineimap/arista.lock"
  offlineimap -u basic
}

ashark() {
  if [ "$1" = "" ]
  then
    cat <<EOF
usage: ashark <hostname|ip> <remote_interface>

EOF

  else
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        admin@$1 "bash sudo tcpdump -s 0 -Un -w - -i $2"            \
      | tshark -i -
  fi
}

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

# misc. arista specific aliases
source "${HOME}/.home/pb.sh"
