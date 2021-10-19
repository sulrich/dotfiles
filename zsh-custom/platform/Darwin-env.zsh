# -*- Mode: shell-script; tab-width: 2 -*- *
# OSX specific functions and aliases

# i don't particularly like the placement of the XDG_CONFIG_HOME on mac os
export XDG_CONFIG_HOME="${HOME}/.config" 

export VAGRANT_DEFAULT_PROVIDER="virtualbox"
#export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
#export VAGRANT_VMWARE_CLONE_DIRECTORY="/Volumes/JetDrive/vagrant-clone"

# day1 journal location - this seems like voodoo
export D1J="${HOME}/Library/Group Containers/5U8NS4GX82.dayoneapp2/Data/Auto Import/Default Journal.dayone"

# convenience environment variable to get to the iCloud root directory
export ICLOUD="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

# note the following requires that synology be configured with the relevant ssh
# keys.  the path is also _relative_ to the home directory as presented by the
# sftp process.
export SULRICH_BKUP_RPATH="sftp:sulrich@snuffles.local.:/home/archive/backups/${HOSTNAME}-backup/"
export SULRICH_BKUP_EXCLUDE="${HOME}/.home/backup/${HOSTNAME}-backup-exclude-list.txt"
# note that the following is sensitive to the naming inside 1password
export SULRICH_BKUP_1P="restic-${HOSTNAME}"
