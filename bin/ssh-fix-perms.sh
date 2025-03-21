#!/bin/bash
#
# fix-ssh-permissions.sh - script to correct ssh directory and file permissions
# to avoid ssh security warnings and errors
#

set -e

SSH_HOME_DIR="${HOME}/.home/ssh"
SSH_DIR="${HOME}/.ssh"

echo "fixing ssh permissions in ${SSH_HOME_DIR} and ${SSH_DIR}"

# fix dotfiles ssh directory permissions
if [ -d "${SSH_HOME_DIR}" ]; then
  echo "setting permissions on ${SSH_HOME_DIR}"
  find "${SSH_HOME_DIR}" -type d -exec chmod 700 {} \;
  find "${SSH_HOME_DIR}" -type f -name "config*" -exec chmod 600 {} \;
  find "${SSH_HOME_DIR}" -type f -name "*.pub" -exec chmod 644 {} \;
  find "${SSH_HOME_DIR}" -type f -name "known_hosts" -exec chmod 644 {} \;
  find "${SSH_HOME_DIR}" -type f -not -name "*.pub" -not -name "config*" -not -name "known_hosts" -exec chmod 600 {} \;
fi

# fix actual .ssh directory permissions
if [ -d "${SSH_DIR}" ]; then
  echo "setting permissions on ${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  find "${SSH_DIR}" -type d -exec chmod 700 {} \;
  
  # fix authorized_keys permissions
  if [ -f "${SSH_DIR}/authorized_keys" ]; then
    chmod 600 "${SSH_DIR}/authorized_keys"
  fi
  
  # fix config files
  find "${SSH_DIR}" -type f -name "config*" -exec chmod 600 {} \;
  
  # fix private keys
  find "${SSH_DIR}" -type f -not -name "*.pub" -not -name "known_hosts" -not -name "config*" -not -name "authorized_keys" -exec chmod 600 {} \;
  
  # fix public keys
  find "${SSH_DIR}" -type f -name "*.pub" -exec chmod 644 {} \;
  
  # fix known_hosts
  if [ -f "${SSH_DIR}/known_hosts" ]; then
    chmod 644 "${SSH_DIR}/known_hosts"
  fi
fi

echo "ssh permissions fixed successfully"
