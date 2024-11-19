#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

# This script is run to push new artifacts to the blob storage

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

if [[ -z "${SERVE_STATIC_IMAGE_NAME}" ]]; then
  echo "SERVE_STATIC_IMAGE_NAME is not set. Exiting."
  exit 1
fi

# Push the static image
docker push "${SERVE_STATIC_IMAGE_NAME}"
