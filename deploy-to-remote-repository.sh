#!/bin/bash -e

# Deploy to Remote Repository Action
# See README.md

# Trivial temp directory management
SCRATCH=$(mktemp -d) || exit 1

# Cleanup the temp directory on exit
function cleanup {
	# remove the temp directory
	rm -rf "$SCRATCH"
	# Remove any ssh keys we've set
	rm -f ~/.ssh/private_key
}
trap cleanup EXIT

# Update the REMOTE_REPO_DIR to be a subdirectory of the scratch directory
REMOTE_REPO_DIR="${SCRATCH}/remote-repo"

# Store the commit message in a temporary file.
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
echo "$COMMIT_MESSAGE" > "${SCRATCH}/commit.message"

# Setup the SSH key.
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Write the private key to a file, interpret any escaped newlines
echo -e "${SSH_KEY}" > ~/.ssh/private_key
chmod 600 ~/.ssh/private_key

# Clone remote repository
git clone --branch "${REMOTE_BRANCH}" "${REMOTE_REPO}" "${REMOTE_REPO_DIR}" --depth 1

# Rsync current repository to remote repository. Split the exclude list into an
# array by splitting on commas.
IFS=', ' read -r -a EXCLUDES <<< "$EXCLUDE_LIST"

# Build the rsync exclude options
EXCLUDE_OPTIONS="--exclude=.git "
for EXCLUDE in "${EXCLUDES[@]}"; do
	EXCLUDE_OPTIONS+="--exclude=${EXCLUDE} "
done

# shellcheck disable=SC2086
rsync -av $EXCLUDE_OPTIONS "${BASE_DIRECTORY}" "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}" --delete

# Replace .gitignore with .deployignore recursively.
if [ -f "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}/.deployignore" ]; then
	echo "Replacing .gitignore with .deployignore"

	find "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}" -type f -name '.gitignore' | while read -r GITIGNORE_FILE; do
		echo "# Emptied by deploy-to-remote-repository.sh; '.deployignore' exists and used as global .gitignore." > "$GITIGNORE_FILE"
	done

	mv -f "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}/.deployignore" "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}/.gitignore"
fi

# Pantheon-specific steps.
if [[ "true" == "${PANTHEON_DEPLOYMENT}" ]]; then
	# Support copying .pantheon/pantheon.yml to the root of the remote repository.
	if [[ -f "${BASE_DIRECTORY}/.pantheon/pantheon.yml" ]]; then
		echo "Copying ${BASE_DIRECTORY}/.pantheon/pantheon.yml to root of remote repository [${REMOTE_REPO_DIR}/pantheon.yml]"
		cp "${BASE_DIRECTORY}/.pantheon/pantheon.yml" "${REMOTE_REPO_DIR}/pantheon.yml"
	fi

	# Support copying .pantheon/private to the root of the remote repository.
	if [[ -d "${BASE_DIRECTORY}/.pantheon/private" ]]; then
		echo "Copying ${BASE_DIRECTORY}/.pantheon/private to root of remote repository [${REMOTE_REPO_DIR}/private]"
		rsync -av "${BASE_DIRECTORY}/.pantheon/private/" "${REMOTE_REPO_DIR}/private/" --delete
	fi
fi

# Commit and push changes to remote repository
cd "${REMOTE_REPO_DIR}" || exit 1

# Set git user.name to include repository name
REPO_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F '/' '{print $2}')
git config user.name "${REPO_NAME} GitHub Action"
git config user.email "action@github.com"

git add -A
git status
git commit --allow-empty -a --file="${SCRATCH}/commit.message"

# Push the new branch to the remote repository
echo "Pushing to ${REMOTE_REPO}@${REMOTE_BRANCH}"
git push -u origin
