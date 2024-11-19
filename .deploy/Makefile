SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

MAKEFLAGS += --silent

.PHONY: *

BIN := $(CURDIR)/bin
export PATH := $(BIN):$(PATH)

DEPLOY_PATH := ./blueprint

DOMAIN ?= $(shell bash -c 'read -p "Domain (e.g. website): " domain; echo $$domain')
PRODUCT ?= $(shell bash -c 'read -p "Product (e.g. wolfeu): " product; echo $$product')
APPLICATION ?= $(shell bash -c 'read -p "Application (e.g. api): " application; echo $$application')


## Commands

get-settings:
	@echo Domain › $(DOMAIN)
	@echo Product › $(PRODUCT)
	@echo Application › $(APPLICATION)


## Kpt package update

kpt-update: kpt-update-frontend

kpt-update-%:
	kpt pkg update "$(DEPLOY_PATH)/$*"
	$(MAKE) sed-$*
	$(MAKE) kpt-render-$*

kpt-render-%:
	kpt fn render "$(DEPLOY_PATH)/$*"

sed-%:
	find "$(DEPLOY_PATH)/$*/" -type f -exec sed -i "s/<domain>/$(DOMAIN)/g" {} \;
	find "$(DEPLOY_PATH)/$*/" -type f -exec sed -i "s/<product>/$(PRODUCT)/g" {} \;
	find "$(DEPLOY_PATH)/$*/" -type f -exec sed -i "s/<application>/$(APPLICATION)/g" {} \;


## Quality checks

check: lint kube-audit kube-conform  ## Run all quality checks

lint: $(BIN)/yamlfmt  ## Lint yaml files
	if ! $(BIN)/yamlfmt $(DEPLOY_PATH)/**/* -conf $(CURDIR)/.yamlfmt -lint >/dev/null 2>&1; then \
  		echo "Linting failed. Run 'make lint-fix'"; \
	fi

lint-fix: $(BIN)/yamlfmt  ## Lint yaml files
	$(BIN)/yamlfmt $(DEPLOY_PATH)/**/* -conf $(CURDIR)/.yamlfmt >/dev/null 2>&1

kube-audit: $(BIN)/kpt  ## Check kubernetes audit
	$(BIN)/kpt fn source | $(BIN)/kpt fn eval - -i msvcweu.azurecr.io/kube/krmfn/kubeaudit --fn-config=$(CURDIR)/.config/kubeaudit.yaml --truncate-output=false;

kube-conform: $(BIN)/kpt  ## Check kubernetes conformance
	$(BIN)/kpt fn source | $(BIN)/kpt fn eval - -i msvcweu.azurecr.io/kube/krmfn/kubeconform --fn-config=$(CURDIR)/.config/kubeconform.yaml >/dev/null 2>&1



## Dependencies

deps: $(BIN)/kpt $(BIN)/yamlfmt  ## Install dependencies

.DEFAULT: $(BIN)/kpt
$(BIN)/kpt:  ## Install kpt
	mkdir -p $(BIN)

	echo "Downloading kpt ..."
	curl -fsSL https://github.com/GoogleContainerTools/kpt/releases/download/v1.0.0-beta.54/kpt_linux_amd64 \
		| install /dev/stdin $(BIN)/kpt
	chmod a+x $(BIN)/kpt

.DEFAULT: $(BIN)/yamlfmt
$(BIN)/yamlfmt:  ## Install yamlfmt
	mkdir -p $(BIN)

	echo "Downloading yamlfmt ..."
	curl -fsSL https://github.com/google/yamlfmt/releases/download/v0.13.0/yamlfmt_0.13.0_Linux_x86_64.tar.gz \
		| tar -O -xzf - yamlfmt \
		| install /dev/stdin $(BIN)/yamlfmt
	chmod a+x $(BIN)/yamlfmt