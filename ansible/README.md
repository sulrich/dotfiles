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

## setup your venv

```bash
uv venv ~/.venvs/ansible
source ~/.venvs/ansible/bin/activate
uv pip install ansible passlib
```

## usage

### basic usage

run playbooks with:

```shell
ansible-playbook -i inventory/multipass.yaml playbooks/multipass-setup.yml
```

### user-only setup (recommended)

for user-only setup (no sudo required) against a single host:

```shell
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml
```

note: the trailing comma after the hostname is required when specifying a single host.

### customized setup

1. copy the configuration template:
```shell
cp playbooks/vars/user-config-template.yml playbooks/vars/my-config.yml
```

2. edit `my-config.yml` with your personal settings

3. run with custom configuration:
```shell
ansible-playbook -i "hostname.example.com," -e @playbooks/vars/my-config.yml playbooks/setup-env-user-only.yml
```

### selective installation

use tags to run only specific parts:

```shell
# only install development tools
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml --tags "go,python"

# skip ssh key setup
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml --skip-tags "ssh"

# only setup directories and dotfiles
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml --tags "setup,dotfiles"
```

### available tags

- `setup` - basic directory structure and validation
- `dotfiles` - dotfiles repository and symlinks
- `go` - go language installation
- `python` - python and uv package manager
- `ssh` - ssh key management
- `neovim` - neovim installation and configuration
- `development-tools` - various development tools (gh, op, etc.)

## troubleshooting

### common issues

1. **ssh key errors**: ensure your github ssh keys are properly configured
2. **network timeouts**: increase timeout values in the playbook if needed
3. **permission errors**: verify the target user has write access to home directory

### dry run

to see what would be changed without making modifications:

```shell
ansible-playbook -i "hostname.example.com," playbooks/setup-env-user-only.yml --check --diff
```
