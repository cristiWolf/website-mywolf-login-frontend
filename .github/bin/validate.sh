#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
export WORKSPACE

### Project specific code
### Validate that your code is ready to be committed ###

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

COMPOSE_FILE=docker-compose.ci.yaml
export COMPOSE_FILE

cp .npmrc.template .npmrc
sed -i "s/__TOKEN__/${GH_TOKEN}/g" .npmrc

make docker-up
make install
make pipeline-check
make test-coverage
make build-dev_test-sources
