#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

source "$(dirname "$0")/tools/provide-versions.sh"

echo "VERSION_NEXT_PRE_RELEASE: $VERSION_NEXT_PRE_RELEASE"
echo "VERSION_NEXT_MINOR: $VERSION_NEXT_MINOR"
echo "VERSION_NEXT: $VERSION_NEXT"
echo "VERSION_CURRENT: $VERSION_CURRENT"
echo "BRANCH_CURRENT: $BRANCH_CURRENT"

# Check if the current branch is the trunk
if [[ "$BRANCH_CURRENT" != "main" ]]; then
    echo "ERROR: Current branch is not the trunk. No pre-release version can be determined."
    exit 1
fi

# Check if the current version is a pre-release version
if [[ "$VERSION_CURRENT" == *"-beta"* ]]; then
    echo "ERROR: There seems to be already an active pre-release. Finish this one and then start a new release cycle."
    exit 1
fi

# For convco to create a pre-release version, at least one tag must exist, otherwise it will not use the "-beta" suffix
if [[ "$VERSION_CURRENT" == "0.0.0" ]]; then
	echo "ERROR: Current version is 0.0.0. No pre-release version can be determined. Please create your first version tag manually (0.1.0) or (1.0.0)"
	exit 1
fi

# If there are no commits since the last tag, we cannot determine a pre-release version
COMMITS_SINCE_LAST_TAG=$(git rev-list --count "$(git describe --tags --abbrev=0)"..HEAD)
if [[ "$COMMITS_SINCE_LAST_TAG" == "0" ]]; then
    echo "ERROR: There are no new commits since the last tag. No pre-release version can be determined."
    exit 1
fi

# Determine the resulting branch name and tag name
if [[ "$VERSION_NEXT_PRE_RELEASE" != *"0-beta.1" ]]; then
    RESULTING_BRANCH_NAME="v$VERSION_NEXT_MINOR"
    RESULTING_TAG_NAME="v${VERSION_NEXT_MINOR}-beta.1"
else 
    RESULTING_BRANCH_NAME="v$VERSION_NEXT"
    RESULTING_TAG_NAME="v${VERSION_NEXT_PRE_RELEASE}"
fi

# If the current version is the same as the next version, force the use of the next minor version
if [[ "$VERSION_CURRENT" == "$VERSION_NEXT" ]]; then
    RESULTING_BRANCH_NAME="v$VERSION_NEXT_MINOR"
    RESULTING_TAG_NAME="v${VERSION_NEXT_MINOR}-beta.1"
fi

echo "RESULTING_BRANCH_NAME: $RESULTING_BRANCH_NAME"
echo "RESULTING_TAG_NAME: $RESULTING_TAG_NAME"

# Create a new branch and tag
git checkout -b "release/${RESULTING_BRANCH_NAME}" && \
    git tag "${RESULTING_TAG_NAME}" -am "pre-release ${RESULTING_TAG_NAME} version" && \
    git push --tags --set-upstream origin "release/${RESULTING_BRANCH_NAME}"

