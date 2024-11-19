SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: *

IMAGE_REGISTRY ?= localhost:5000
IMAGE_REPOSITORY ?= website/mywolf-login-frontend
IMAGE_TARGET ?= prod
RESULTING_TAG ?= devtest
COMPOSE_FILE ?= docker-compose.yaml
REMOTE_IMAGE_REGISTRY ?= msvcweu.azurecr.io

WORKSPACE ?= $(shell pwd)

pnpm=docker compose -f ${COMPOSE_FILE} exec -T app pnpm


##@ Commands

help: ## Display this help text
	bin/makehelp $(MAKEFILE_LIST)


##@ Local development

init: docker-build docker-up docker-compose.ide.yaml install set-permissions ## Initialize project locally
	@echo "The project is now initialized. Start the dev server with 'make dev'."

start: docker-stop docker-up dev ## Start project

stop: docker-stop ## Stop project

generate-ts-schema-from-api-docs: ## Generate api typescript schemas from openapi docs
	docker run -it --rm -v ${PWD}:/app -u $$(id -u ${USER}):$$(id -g ${USER}) -w /app/.dev/tools/swagger-typescript-api node:20 bash -c \
		"npx \
			swagger-typescript-api --path ${OPEN_API_SPECIFICATION_URL} \
			--no-client \
			--output /app/src/types \
			--name ApiSchema.ts \
		"


###@ Docker commands

.DEFAULT: .docker.env.local
.docker.env.local: ## Create .docker.env.local file
	touch .docker.env.local

docker-up: .docker.env.local ## Run docker compose up
	docker compose -f ${COMPOSE_FILE} up -d

docker-build: .docker.env.local acr-login ## Run docker compose build
	docker compose -f ${COMPOSE_FILE} build

docker-config:.docker.env.local ## Run docker compose config
	docker compose -f ${COMPOSE_FILE} config

docker-down: .docker.env.local ## Run docker compose down
	docker compose -f ${COMPOSE_FILE} down --remove-orphans

docker-down-remove: .docker.env.local ## Run docker compose down and remove volumes
	docker compose -f ${COMPOSE_FILE} down --volumes --remove-orphans

docker-stop: .docker.env.local ## Run docker compose stop
	docker compose -f ${COMPOSE_FILE} stop -t0

attach: ## Attach to the node container
	docker compose -f ${COMPOSE_FILE} exec -it app bash

attach-root: ## Attach to the node container as root
	docker compose -f ${COMPOSE_FILE} exec -it -u 0 app bash

docker-compose.ide.yaml: ## Generate docker-compose.ide.yaml file for IDE integration when the IDE does not support env variables in docker-compose.yaml
	@set -o allexport && source .docker.env && set +o allexport && envsubst < docker-compose.yaml > docker-compose.ide.yaml


###@ NPM

.npmrc:
	cp .npmrc.template .npmrc

install: ## Install dependencies
	docker compose -f ${COMPOSE_FILE} exec -t app pnpm install

dev: ## Start development server
	${pnpm} dev


###@ Tests

check: lint-fix ## Run all checks

lint: ## Run lint
	${pnpm} lint

lint-fix: ## Run lint with --fix
	${pnpm} lint:fix

format-check:
	${pnpm} format:check

format-write:
	${pnpm} format:write

test-coverage:
	${pnpm} coverage

test-e2e:
	${pnpm} test:e2e

##@ Build

build-dev-sources: clear-build ## Build project in dev mode for local development
	${pnpm} build --mode=dev

build-dev_test-sources: clear-build ## Build project in dev_test mode for test environment
	${pnpm} build --mode=dev_test

build-stage-sources: clear-build ## Build project in stage mode for stage environment
	${pnpm} build --mode=stage

build-prod-sources: clear-build ## Build project in prod mode for prod environment
	${pnpm} build --mode=prod --minify

build-serve-static-image-from-sources:
	if [ -z "${SERVE_STATIC_BUILD_TARGET}" ]; then \
		echo "SERVE_STATIC_BUILD_TARGET is not set"; \
		exit 1; \
	fi

	if [ -z "${RESULTING_TAG}" ]; then \
		echo "RESULTING_TAG is not set"; \
		exit 1; \
	fi

	if [ -z "${IMAGE_REPOSITORY}" ]; then \
		echo "IMAGE_REPOSITORY is not set"; \
		exit 1; \
	fi

	if [ -z "${IMAGE_REGISTRY}" ]; then \
		echo "IMAGE_REGISTRY is not set"; \
		exit 1; \
	fi

	if [ ! -d "./build" ]; then \
		echo "Build directory does not exist. Please run 'make build-${SERVE_STATIC_BUILD_TARGET}-sources' first."; \
		exit 1; \
	fi

	docker build \
		--file "${WORKSPACE}/.docker/serve-static/Dockerfile" \
    	--tag "${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}:${RESULTING_TAG}" \
    	--target "${SERVE_STATIC_BUILD_TARGET}" \
    	--build-arg "UID=${UID}" \
    	--build-arg "GID=${GID}" \
    	"${WORKSPACE}"

build-and-serve-static-image-locally:  ## Build static image serving content in given mode
	$(MAKE) build-${SERVE_STATIC_BUILD_TARGET}
	docker run --rm -it -p 8080:8080 "${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}:${RESULTING_TAG}"

build-dev: ## Build project in dev mode for local development
	$(MAKE) build-dev-sources
	$(MAKE) build-serve-static-image-from-sources SERVE_STATIC_BUILD_TARGET=dev

build-dev_test: ## Build project in dev_test mode for test environment
	$(MAKE) build-dev_test-sources
	$(MAKE) build-serve-static-image-from-sources SERVE_STATIC_BUILD_TARGET=dev_test

build-stage: ## Build project in stage mode for stage environment
	$(MAKE) build-stage-sources
	$(MAKE) build-serve-static-image-from-sources SERVE_STATIC_BUILD_TARGET=stage

build-prod: ## Build project in prod mode for prod environment
	$(MAKE) build-prod-sources
	$(MAKE) build-serve-static-image-from-sources SERVE_STATIC_BUILD_TARGET=prod


##@ Pipeline

pipeline-check: ## Run all checks for validation pipeline
	$(MAKE) lint
	$(MAKE) format-check


##@ Helper commands

set-permissions:
	chmod a+x bin/*

clear-build:
	rm -rf ./build/


##@ Deps / External

acr-login: ## Login to Azure Container Registry
	az acr login --name ${REMOTE_IMAGE_REGISTRY}
