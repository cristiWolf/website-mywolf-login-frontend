#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

# This script is run to build new images

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

source "$(dirname "$0")/tools/provide-versions.sh"

IMAGE_REGISTRY=${DOCKER_IMAGE_REGISTRY}
IMAGE_REPOSITORY_BASE=${DOCKER_IMAGE_REPOSITORY_BASE}

BUILD_MODE=${BUILD_MODE:-dev_test}

RESULTING_TAG=${TAG:-test}
GITHUB_REF=${GITHUB_REF}

# Check if the current branch is the trunk
if [[ "$BRANCH_CURRENT" == "main" ]]; then
    RESULTING_TAG="test"
else
	RESULTING_TAG="v${VERSION_CURRENT}"
fi

echo "BRANCH_CURRENT: $BRANCH_CURRENT"
echo "VERSION_CURRENT: $VERSION_CURRENT"
echo "RESULTING_TAG: $RESULTING_TAG"
echo "GITHUB_REF: $GITHUB_REF"

# Set the resulting image in an output parameter
echo "IMAGE_TAG=$RESULTING_TAG" >> "$GITHUB_OUTPUT"

### Project specific code
### Build your images/artefacts and push them to the registry/cloud storage

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

COMPOSE_FILE=docker-compose.ci.yaml
export COMPOSE_FILE

### Pass in the resulting version to Sentry

VITE_SENTRY_RELEASE="${RESULTING_TAG}"
export VITE_SENTRY_RELEASE

# Login to the registry
echo "${SP_WO_MICROSERVICES_CI_SECRET}" | docker login "$IMAGE_REGISTRY" -u "${SP_WO_MICROSERVICES_CI_ID}" --password-stdin

cp .npmrc.template .npmrc
sed -i "s/__TOKEN__/${GH_TOKEN}/g" .npmrc

make docker-up
make install
make "build-${BUILD_MODE}-sources"

make build-serve-static-image-from-sources \
  SERVE_STATIC_BUILD_TARGET="${BUILD_MODE}" \
  IMAGE_REGISTRY="${IMAGE_REGISTRY}" \
  IMAGE_REPOSITORY="${IMAGE_REPOSITORY_BASE}" \
  RESULTING_TAG="${RESULTING_TAG}" \
  WORKSPACE="${WORKSPACE}"

echo "SERVE_STATIC_IMAGE_NAME=${IMAGE_REGISTRY}/${IMAGE_REPOSITORY_BASE}:${RESULTING_TAG}" >> "$GITHUB_OUTPUT"
