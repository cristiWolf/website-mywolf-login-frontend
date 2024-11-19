FROM node:20.15 AS app_base

RUN corepack enable

RUN pnpm dlx playwright@1.47.2 install --with-deps chromium

# Dev stage
# ------------------------------------------------------------
FROM app_base AS app_dev

RUN apt-get -y update && apt-get -y install \
    git \
    && rm -rf /var/lib/apt/lists/*

USER node


# Ci stage
# ------------------------------------------------------------
FROM app_base AS app_ci