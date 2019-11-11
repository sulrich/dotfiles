# -*- Mode: shell-script; tab-width: 2 -*- *
# kermit specific environment configuration

# blog base directory 
export HUGO_DIR="${HOME}/src/botwerks-site"

# pyenv base location
export PYENV_ROOT="${HOME}/.pyenv"

# amazon AWS vars
export AWS_DEFAULT_PROFILE="sulrich@botwerks.org"

# referenced somewhere, i just don't quite know where ...
# TODO: this needs to updated in the age of pyenv
export POWERLINE_DIR="${HOME}/Library/Python/3.7/lib/python/site-packages/powerline"

# the following are needed for my personal rsync backups
export SULRICH_BKUP_RPATH="/mnt/snuffles/home/sulrich/archive/personal-backup"
export SULRICH_BKUP_EXCLUDE="${HOME}/.home/backup/kermit-backup-exclude-list.txt"
