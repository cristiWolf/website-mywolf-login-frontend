#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

### e2e tests ###

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

COMPOSE_FILE=docker-compose.ci.yaml
export COMPOSE_FILE

cp .npmrc.template .npmrc
sed -i "s/__TOKEN__/${GH_TOKEN}/g" .npmrc

# Debug: Print environment variables
echo "Debug: VITE_HOST=${VITE_HOST}"
echo "Debug: VITE_API_ENDPOINT=${VITE_API_ENDPOINT}"

echo "VITE_HOST=${VITE_HOST}" > .env.local
echo "VITE_API_ENDPOINT=${VITE_API_ENDPOINT}" >> .env.local

make docker-up
make install
make test-e2e
