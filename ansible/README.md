# ansible automation

ansible automation for setting up and configuring hosts.

## inventory

the `inventory/` directory contains host definitions:

- `multipass.yaml` - defines multipass vm hosts for local development

## playbooks

the `playbooks/` directory contains the following automation:

### environment setup

- `setup-env-user-only.yml` - bootstraps a user environment without requiring
  root. installs:
  - dotfiles (from personal github)
  - go environment
  - python environment with uv package manager
  - neovim configuration
  - ssh configuration
  - public keys

### server setup

- `server-acct-setup.yml` - sets up the baseline account configuration on a
  server:
  - checks out personal dotfiles
  - creates symlinks
  - installs uv package manager
  - copies public keys
  - checks out work dotfiles

### multipass vm setup

- `multipass-setup.yml` - configures multipass ubuntu vms:
  - installs containerlab
  - sets up dotfiles symlinks
  - installs uv package manager
  - copies public keys

## usage

run playbooks with:

```shell
ansible-playbook -i inventory/multipass.yaml playbooks/multipass-setup.yml
```

or for user-only setup (no sudo required):

to run against a single host without an inventory file (user-only setup):

```shell
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml
```

note the trailing comma after the hostname is required when specifying a single
host.
