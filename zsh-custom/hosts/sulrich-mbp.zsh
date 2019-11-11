# juniper specific functions for interacting w/internal services or a juniper
# specific configuration

# open a PR in a new tab
bulk-pr-open () { foreach i ($*) open "https://gnats.juniper.net/web/default/$i"; end }

# if i past a bunch of PRs into a string open them in a series of tabs 
bulk-rli-open () {
  foreach i ($*)
    i="${i//[^[:digit:]]/}"  # strip anything that's not a number from the string
    open "https://deepthought.juniper.net/app/do/showView?tableName=RLI&taskCode=all&record_number=${i}";
  end
}

# mail rollover tools - this moves my mailbox to the right spot
rolloutbox () {
  ARCH_YEAR=$(date -v -2m +%Y)
  ARCH_BASE=${HOME}/Documents/archives/mail/${ARCH_YEAR}/outbox
  ${HOME}/bin/split-maildirs.pl --keep_recent --arch_dir=$ARCH_BASE -src_dir=${HOME}/mail outbox
}

# kill offlineimap instances and clean up the lock file. 
koff () {
  pkill -if offlineimap
  rm "${HOME}/.offlineimap/jnpr_o365.lock"
  offlineimap -u basic
}

# misc. juniper specific aliases
