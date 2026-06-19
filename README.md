# overview

my public dotfiles repository. a roving dumpster fire, reasonably well
organized.

## initial setup

clone the repo and drop it into the standard source hierarchy:

```shell
mkdir -p ~/src/personal/
git clone https://github.com/sulrich/dotfiles.git "${HOME}/src/personal/dotfiles"
ln -s ~/src/personal/dotfiles ~/.home
```

## source directory hierarchy

the dotfiles assume a specific directory layout under `~/src/`. create
the top-level directories and drop the appropriate `.envrc` files in
place:

```shell
mkdir -p ~/src/{personal,nexthop}
```

once the credential templates are populated (see below), symlink the
relevant `.envrc` files into the hierarchy:

```shell
ln -s ~/.credentials/src-personal-envrc ~/src/personal/.envrc
ln -s ~/.credentials/src-nexthop-envrc ~/src/nexthop/.envrc
```

these are picked up by `direnv` as you move between the directories,
setting the appropriate environment variables (API tokens, AWS profiles,
etc.) based on context.

## credentials setup

the `templates/credentials/` directory contains 1password-templated
files for the various credentials and environment configurations. the
`op` CLI's inject command renders these templates and writes the output
to `~/.credentials/`.

```shell
mkdir -p ~/.credentials
chmod 0700 ~/.credentials
```

for each file in `templates/credentials/`, run `op inject`:

```shell
op inject -i templates/credentials/00-api-creds.env \
  -o ~/.credentials/00-api-creds.env

op inject -i templates/credentials/claude-fireworks.env \
  -o ~/.credentials/claude-fireworks.env

op inject -i templates/credentials/src-personal-envrc \
  -o ~/.credentials/src-personal-envrc

op inject -i templates/credentials/src-nexthop-envrc \
  -o ~/.credentials/src-nexthop-envrc
```

the template files use 1password secret references in the form
`{{ op://vault/item/field }}`. `op inject` resolves these against your
1password account and writes the rendered output. you'll need to be
authenticated (`op signin`) before running the inject commands.

credentials in `~/.credentials/` are intentionally not symlinked from
`~/.home` - they live outside version control by design.

## remote host setup with ansible

the ansible playbooks in `ansible/playbooks/` handle the heavy lifting
for bootstrapping remote hosts. the `setup-env-user-only.yml` playbook
is the main workhorse - it sets up a full user environment without
requiring root access:

```shell
ansible-playbook -i "hostname.example.com," \
  ansible/playbooks/setup-env-user-only.yml
```

note the trailing comma after the hostname - that's required when
targeting a single host without an inventory file.

for a full overview of what each playbook does and how to run them,
see `ansible/README.md`.

## a note on install.sh

`install.sh` is deprecated. it was the original bootstrapping mechanism
and still works for individual operations (installing go, setting up
neovim, etc.), but the ansible playbooks have superseded it for anything
involving a new machine or remote host. if you're setting up a new
environment, reach for ansible first.

the script remains in the repo for reference and the occasional
one-off function call where spinning up a full playbook would be
overkill.
