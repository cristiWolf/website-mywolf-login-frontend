#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

source "$(dirname "$0")/tools/provide-versions.sh"

echo "VERSION_NEXT_PRE_RELEASE: $VERSION_NEXT_PRE_RELEASE"
echo "VERSION_CURRENT: $VERSION_CURRENT"
echo "VERSION_NEXT: $VERSION_NEXT"
echo "BRANCH_CURRENT: $BRANCH_CURRENT"

# Check if the current branch is a release branch, ie it follows the format "release/x.x.x"
if [[ "$BRANCH_CURRENT" != "release/"* ]]; then
	echo "ERROR: Current branch is not a release branch. Updates to pre-releases may only happen on respective release branches."
	exit 1
fi

# If the current version is a pre-release, then only increment the beta counter. If it is a release, then increment the patch version.
if [[ "$VERSION_CURRENT" == *"-beta"* ]]; then
	RESULTING_TAG_NAME="v${VERSION_NEXT_PRE_RELEASE}"
else
	RESULTING_TAG_NAME="v${VERSION_NEXT}"
fi

echo "RESULTING_TAG_NAME: $RESULTING_TAG_NAME"

# Create just a new pre-release tag if the current version is a pre-release, otherwise create a new patch release
if [[ "$VERSION_CURRENT" == *"-beta"* ]]; then
	# Create the new pre-release tag
	git tag "${RESULTING_TAG_NAME}" -am "pre-release ${RESULTING_TAG_NAME} version" && git push --tags

	# Set the app mode for building and publishing the artifacts
	echo "BUILD_MODE=stage" >> "$GITHUB_OUTPUT"
else
	# Create the tag to create the new changelog
	git tag "${RESULTING_TAG_NAME}"

	# Update version file
	echo "${RESULTING_TAG_NAME}" > "${WORKSPACE}/VERSION.txt"

	# Create a changelog
	$CONVCO_CMD changelog --output CHANGELOG.md

	git add CHANGELOG.md
	git add VERSION.txt
	git commit -m "Update CHANGELOG.md / VERSION.txt for ${VERSION_NEXT} release"

	# Delete the tag and set it to the changelog commit
	git tag -d "${RESULTING_TAG_NAME}"
	git tag "${RESULTING_TAG_NAME}" -am "Pre-release ${RESULTING_TAG_NAME} version"

	# Push the tag and the changelog commit
	git push --tags origin "${BRANCH_CURRENT}"

	# Create a release in github
	gh release create "v${VERSION_NEXT}" -F CHANGELOG.md

	# Create a pull request to merge the release branch back into the main branch
    gh pr create -B main -H "${BRANCH_CURRENT}" --title "release: Release ${RESULTING_TAG_NAME}" --body "$(echo -e "Merge release ${RESULTING_TAG_NAME} back into trunk.\n\n**IMPORTANT: DO NOT USE SQUASH MERGE TO MERGE THIS PULL REQUEST. USE MERGE COMMIT**.")"

    # Automatically merge the pull request
    gh pr merge -m --admin || echo 'Automatic merge of the pull request failed. There must be a merge conflict that has to be resolved manually.'

	# Set the app mode for building and publishing the artifacts
	echo "BUILD_MODE=prod" >> "$GITHUB_OUTPUT"
fi
