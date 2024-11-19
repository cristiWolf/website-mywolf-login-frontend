# website-mywolf-login-frontend

![Validate](https://github.com/wolf-gmbh/website-mywolf-login-frontend/actions/workflows/validate.yaml/badge.svg?branch=main)

Contains the source code of the frontend-application (React) for the myWolf Login

## Local development without docker

If you are not using docker for local development, you have to initialize the project manually by running the following commands:

```shell
pnpm install
```

## Local development with docker

To ease the setup, a Makefile is included that has some helpful commands to work with the project.

### Requirements

- Docker
- Docker Compose
- Make (sudo apt-get install make)
- Direnv (sudo apt-get install direnv), see https://direnv.net/docs/installation.html

### Setup

First we need to add a personal access token to the .npmrc file. This is needed to install private packages from the
github npm registry. To do this, run `make .npmrc`. This will copy the .npmrc.template file to .npmrc. Then
create a personal access token in github with the following scope: package:read. Copy the token and
replace the `__TOKEN__` placeholder in the .npmrc file with the token.

Now we can setup the project by running `make init`. This will install all dependencies and create a
docker-compose.ide.yaml that can be used for running ide interpreters based on the docker containers.

### Running the project

To run the project, run `make start`. This will start docker containers and start up the vite development server.
Alternatively you can start only the docker containers first with `make docker-up` and then start the vite development
server with `make dev`.

There are also other commands, e.g. for building or linting. You can find them in the Makefile or run `make help` to
see the available commands.
