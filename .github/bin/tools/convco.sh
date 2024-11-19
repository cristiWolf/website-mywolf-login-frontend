# Uses the convco/convco tool to generate a changelog and bump the version number.
CONVCO_VERSION="${CONVCO_VERSION:-0.4.0}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-docker}"
CONVCO_CMD="${CONTAINER_ENGINE} run --rm \
	--volume "${GITHUB_WORKSPACE}:/tmp" \
	--workdir /tmp \
	--user $(id -u):$(id -g) \
	docker.io/convco/convco:${CONVCO_VERSION}"

export CONVCO_CMD
