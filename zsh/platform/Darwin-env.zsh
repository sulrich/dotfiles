# -*- Mode: shell-script; tab-width: 2 -*- *
# macos specific functions and aliases

# i don't particularly like the placement of the XDG_CONFIG_HOME on mac os
export XDG_CONFIG_HOME="${HOME}/.config" 

# is vagrant even a thing anymore?
#export VAGRANT_DEFAULT_PROVIDER="virtualbox"
#export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
#export VAGRANT_VMWARE_CLONE_DIRECTORY="/Volumes/JetDrive/vagrant-clone"

# this addresses some ansible hassles on mac os when using the get_url module.
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# convenience environment variable to get to the iCloud root directory
export ICLOUD="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

# note the following requires that synology be configured with the relevant ssh
# keys.  the path is also _relative_ to the home directory as presented by the
# sftp process.
export SULRICH_BKUP_RPATH="/home/archive/backups/${HOSTNAME}-backup/"
export SULRICH_BKUP_EXCLUDE="${HOME}/.home/backup/${HOSTNAME}-backup-exclude-list.txt"
# note that the following is sensitive to the naming inside 1password
export SULRICH_BKUP_1P="restic-${HOSTNAME}"
