#!/usr/bin/env bash
## -*- mode: sh; fill-column: 78; comment-column: 50; tab-width: 2 -*-

trap cleanup SIGINT SIGTERM ERR EXIT


usage() {
    cat << EOF
usage: ${0##*/} [-h]

    -h          display help and exit
    XXX - list of args here

EOF
}

# anything that has ## at the front of the line will be used as input.
## help: details the available functions in this script
help() {
  usage
  echo "available functions:"
  sed -n 's/^##//p' $0 | column -t -s ':' | sed -e 's/^/ /'
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
