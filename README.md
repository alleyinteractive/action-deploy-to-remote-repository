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
      with:
        submodules: 'recursive'

    - name: Cache Theme Webpack Folder
      id: cache-webpack-themes
      uses: actions/cache@v3
      with:
        path: themes/create-wordpress-theme/.cache
        key: ${{ runner.os }}-webpack-theme

    - name: Setup Node
      uses: actions/setup-node@v3
      with:
        cache: 'npm'
        cache-dependency-path: themes/create-wordpress-theme/package-lock.json
        node-version: 16

    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: 8.1
        extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite,
pdo_sqlite, gd
        tools: composer:v2
        coverage: none

    - name: Install dependencies
      uses: ramsey/composer-install@v2
      with:
        composer-options: "--no-progress --no-ansi --no-interaction --prefer-dist
--no-dev"

    - name: Install npm dependencies
      run: cd themes/national-review && npm ci

    - name: Run npm build
      run: cd themes/create-wordpress-theme && npm run build

    - name: Sync to Pantheon
      uses: alleyinteractive/action-deploy-to-remote-repository@feature
      with:
        remote_repo: 'ssh://user@server/example.git'
        remote_branch: 'master' # Notable that this differs from 'production'
        destination_directory: 'wp-content/'
        exclude_list: '.git, .github, .gitmodules, node_modules'
        pantheon-deployment: 'true'
        ssh-key: ${{ secrets.REMOTE_REPO_SSH_KEY }}
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
- Defaults to the same branch name in the remote repo as the current running
  action.

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
- Accepts a string. (e.g. `.git, .gitmodules`)
- Defaults to `.git, .gitmodules`.

### `ssh-key`

- Specify the SSH key to use for the remote repository (requires write access).
- Required.

### `pantheon-deployment`

- Determine if this is a deployment for a Pantheon repository. Supports
  migrating .pantheon/pantheon.yml to pantheon.yml in the root of the
  repository.
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
