#!/bin/bash

# Store the commit message in a temporary file.
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
echo "$COMMIT_MESSAGE" > /tmp/commit.message

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
		echo "# Emptied by vip-go-build; '.deployignore' exists and used as global .gitignore." > "$GITIGNORE_FILE"
		echo "${GITIGNORE_FILE}"
	done

	mv "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}/.deployignore" "${REMOTE_REPO_DIR}/${DESTINATION_DIRECTORY}/.gitignore"
fi

# Commit and push changes to remote repository
cd "${REMOTE_REPO_DIR}" || exit 1

# Set git user.name to include repository name
REPO_NAME=$(echo "$GITHUB_REPOSITORY" | awk -F '/' '{print $2}')
git config user.name "${REPO_NAME} GitHub Action"
git config user.email "action@github.com"

git add -A
git status
git commit --allow-empty -a --file=/tmp/commit.message

# Push the new branch to the remote repository
echo "Pushing to ${REMOTE_REPO}@${REMOTE_BRANCH}"
git push -u origin

# Cleanup after ourselves.
rm -rf "${REMOTE_REPO_DIR}"
rm -f /tmp/commit.message
rm -f ~/.ssh/private_key
