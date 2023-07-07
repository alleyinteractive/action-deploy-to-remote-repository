# Deploy to Remote Repository Action

Uses rsync and git to deploy files/folders from a local GitHub action repository
to a remote repository.

_Notes_:

- We do not leverage external actions to manage the SSH agent as we want to keep
  the code as simple/single-sourced as possible.
- We must manually manage the SSH keys for the remote repository. This is
  typically done by adding the private key to the GitHub action secrets and then
  adding the public key to the remote repository (eg. as a write deploy key).

## Usage

Example deploy to a WordPress VIP:

> TODO: Update after action is built.

```yml
name: Deploy to VIP repository

on:
  push:
    branches:
      - production
      - preprod
      - develop

jobs:
  sync-to-vip:
    uses: alleyinteractive/.github/.github/workflows/deploy-to-remote-repository.yml@main
    with:
      remote_repo: 'git@github.com:wpcomvip/alley.git'
      exclude_list: '.git, .gitmodules, .revision, .deployment-state, .node_modules, no-vip'
    secrets:
      REMOTE_REPO_SSH_KEY: ${{ secrets.REMOTE_REPO_SSH_KEY }}
```

Example Deploy to Pantheon multidev sites labeled `preprod` and `develop`:

```yml
name: Deploy to Pantheon repository

on:
  push:
    branches:
      - preprod
      - develop

jobs:
  sync-to-pantheon:
    uses: alleyinteractive/.github/.github/workflows/deploy-to-remote-repository.yml@main
    with:
      remote_repo: 'ssh://codeserver.dev.SOME-PANTHEON-SITE_ID@codeserver.dev.SOME-PANTHEON-SITE_ID.drush.in:2222/~/repository.git'
      destination_directory: 'wp-content/'
      exclude_list: '.git, pantheon-mu-plugin'
    secrets:
      REMOTE_REPO_SSH_KEY: ${{ secrets.REMOTE_REPO_SSH_KEY }}
```

## Inputs

> Specify using `with` keyword.

### `os`

- Specify the operation system to use.
- Accepts a string.
- Defaults to `ubuntu-latest`.

### `remote_repo`

- Specify the remote repository to deploy to.
- Accepts a string.
- Required.

### `remote_branch`

- Specify the remote branch to deploy to.
- Accepts a string.
- Defaults to the same branch name in the remote repo as the current running action.

### `base_directory`

- Specify the base directory to sync from.
- Accepts a string.
- Defaults to the root of the repository (`.`). **NOTE** You likely want a trailing slash if you're syncing a subdirectory. (eg. `wp-content/`)

### `destination_directory`

- Specify the destination directory to sync to.
- Accepts a string.
- Defaults to the root of the remote repository (`.`).

### `exclude_list`

- Specify a comma-separated list of files and directories to exclude from sync.
- Accepts a string. (e.g. `.git, .gitmodules`)
- Defaults to `.git, .gitmodules`.

## Secrets

> Specify using `secrets` keyword.

### `REMOTE_REPO_SSH_KEY`

- Specify the SSH key to use for the remote repository (requires write access).
- Required.

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Credits

This project is actively maintained by [Alley
Interactive](https://github.com/alleyinteractive).

- [Ben Bolton](https://github.com/benpbolton)
- [All Contributors](../../contributors)

## License

The GNU General Public License (GPL) license. Please see [License File](LICENSE) for more information.
