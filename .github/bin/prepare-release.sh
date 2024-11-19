#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

source "$(dirname "$0")/tools/provide-versions.sh"

echo "VERSION_CURRENT: $VERSION_CURRENT"
echo "VERSION_NEXT: $VERSION_NEXT"
echo "BRANCH_CURRENT: $BRANCH_CURRENT"

# Check if the current branch is a release branch, ie it follows the format "release/x.x.x"
if [[ "$BRANCH_CURRENT" != "release/"* ]]; then
    echo "ERROR: Current branch is not a release branch. Updates to pre-releasses may only happen on respective release branches."
    exit 1
fi

# Check if the current version is a pre-release version
if [[ "$VERSION_CURRENT" != *"-beta"* ]]; then
   echo "ERROR: Current version is not a pre-release version. A release can only be started from a pre-release version."
   exit 1
fi

# This section of code
# * generates a changelog,
# * adds it to the git repository,
# * creates a commit with a message indicating the version number,
# * creates a tag with the version number,
# * pushes the tag to the remote repository,
# * creates a pull request from the current branch to the main branch,
# * and creates a new release with the version number and changelog.

RESULTING_TAG_NAME="v${VERSION_NEXT}"

# Create the tag to create the new changelog including the new tag
git tag "${RESULTING_TAG_NAME}"

# Update version file
echo "${RESULTING_TAG_NAME}" > "${WORKSPACE}/VERSION.txt"

# Create a changelog
$CONVCO_CMD changelog --output CHANGELOG.md

git add CHANGELOG.md
git add VERSION.txt
git commit -m "Update CHANGELOG.md / VERSION.txt for ${RESULTING_TAG_NAME} release"

# Delete the tag to set it to the changelog commit
git tag -d "${RESULTING_TAG_NAME}"
git tag "${RESULTING_TAG_NAME}" -am "Release ${RESULTING_TAG_NAME} version"

# Push the tag
git push origin "${RESULTING_TAG_NAME}"

# Push the changelog commit
git push origin "${BRANCH_CURRENT}"

# Create a release in github
gh release create "${RESULTING_TAG_NAME}" -F CHANGELOG.md

# Create a pull request to merge the release branch back into the main branch
gh pr create -B main -H "${BRANCH_CURRENT}" --title "release: Release ${RESULTING_TAG_NAME}" --body "$(echo -e "Merge release ${RESULTING_TAG_NAME} back into trunk.\n\n**IMPORTANT: DO NOT USE SQUASH MERGE TO MERGE THIS PULL REQUEST. USE MERGE COMMIT**.")"

# Automatically merge the pull request
gh pr merge -m --admin || echo 'Automatic merge of the pull request failed. There must be a merge conflict that has to be resolved manually.'