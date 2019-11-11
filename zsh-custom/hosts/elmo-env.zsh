# -*- Mode: shell-script; tab-width: 2 -*- *
# elmo specific environment configuration

# blog base directory
export HUGO_DIR="${HOME}/src/personal/botwerks-site"

# referenced somewhere, i just don't quite know where ...
# TODO: this needs to updated in the age of pyenv
export POWERLINE_DIR="${HOME}/Library/Python/3.7/lib/python/site-packages/powerline"

# amazon AWS vars
export AWS_DEFAULT_PROFILE="sulrich@botwerks.org"

# the following are needed for my personal rsync backups
export SULRICH_BKUP_RPATH="/mnt/snuffles/home/sulrich/archive/arista-backup"
export SULRICH_BKUP_EXCLUDE="${HOME}/.home/backup/elmo-backup-exclude-list.txt"

# pyenv base
export PYENV_ROOT="${HOME}/.pyenv"
