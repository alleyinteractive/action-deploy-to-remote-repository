# Deploy to Remote Repository Action

Uses rsync and git to deploy files/folders from a local GitHub action repository
to a remote repository.

_Notes_:

- We do not leverage external actions to manage the SSH agent as we want to keep
  the code as simple/single-sourced as possible.
- We must manually manage the SSH keys for the remote repository. This is
  typically done by adding the private key to the GitHub action secrets and then
  adding the public key to the remote repository (e.g., as a write deploy key).

## Usage

Example deploy to a remote repository:

```yml
name: Deploy to Pantheon Live

on:
  push:
    branches:
      - production

jobs:
  build-and-sync:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Sync to Remote Repository
      uses: alleyinteractive/action-deploy-to-remote-repository@v3
      with:
        remote_repo: 'ssh://user@server/example.git'
        remote_branch: 'master' # Notable that this differs from 'production'
        destination_directory: 'wp-content/'
        exclude_list: '.git, .github, .gitmodules, node_modules'
        pantheon: 'true'
        ssh-key: ${{ secrets.REMOTE_REPO_SSH_KEY }}
```

### `.deployignore`

The action supports recursively replacing all `.gitignore` files in your project
with a root-level `.deployignore` file if one is found. This is useful for
excluding files from the deployment that would have previously been ignored by
version control (such as built assets and Composer dependencies). The
`.deployignore` syntax is the same as a normal `.gitignore` file. To skip invoking
this behavior, use the `deployignore: 'false'` input.

### Pantheon Mode

Passing `pantheon: 'true'` to the action will enable "Pantheon" mode. This mode
provides the following features:

- Copies the `.pantheon/pantheon.yml` file (if it exists) to the root of the
  repository as `pantheon.yml`. This is useful for projects that are rooted at
  `wp-content` but still want to version control their Pantheon configuration.
- Copies the `.pantheon/private` directory (if it exists) to the root of the
  repository as `private`.
- Automatically adds `.pantheon` and `mu-plugins/pantheon-mu-plugin` to the [exclude list](#exclude_list) to prevent common deployment errors related to these directories.

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
- Defaults to the same branch name in the remote repo as the current running
  action.

### `remote_branch_is_orphan`

- Whether to use the `--orphan` flag when creating the remote branch.
- Accepts a string. (e.g. `true` or `false`)
- Defaults to `false`.

### `base_directory`

- Specify the base directory to sync from.
- Accepts a string.
- Defaults to the root of the repository (`.`). **NOTE** You likely want a
  trailing slash if you're syncing a subdirectory. (eg. `wp-content/`)

### `destination_directory`

- Specify the destination directory to sync to.
- Accepts a string.
- Defaults to the root of the remote repository (`.`).

### `exclude_list`

- Specify a comma-separated list of files and directories to exclude from sync.
- Accepts a string. (e.g. `.git, .gitmodules, .github`)
- Defaults to `.git, .gitmodules, .github`.

### `deployignore`

- Whether to replace `.gitignore` with `.deployignore` if the files exist.
- Accepts a string. (e.g. `true` or `false`)
- Defaults to `true`.

### `ssh-key`

- Specify the SSH private key to use for the remote repository.
- A corresponding public key must be added as a deploy key to the remote repository with write access.
- Should reference a GitHub secret. See above for an example. The actual private key should be stored in secrets, and never committed to the repository.
- Required.

### `pantheon`

- Determine if this is a deployment for a Pantheon repository. See [Pantheon Mode](#pantheon-mode) for more details.
- Accepts a string. (e.g. `true` or `false`)
- Defaults to `false`.

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed
recently.

## Credits

This project is actively maintained by [Alley
Interactive](https://github.com/alleyinteractive).

- [Ben Bolton](https://github.com/benpbolton)
- [All Contributors](../../contributors)

## License

The GNU General Public License (GPL) license. Please see [License File](LICENSE)
for more information.
