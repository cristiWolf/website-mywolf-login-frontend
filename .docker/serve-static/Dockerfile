FROM nginxinc/nginx-unprivileged:1.27-bookworm AS static_base

COPY ./.docker/serve-static/etc/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./build/ /var/www/html/


# Dev target
# ------------------------------------------------------------
FROM static_base AS dev


# Dev_Test target
# ------------------------------------------------------------
FROM static_base AS dev_test


# Stage target
# ------------------------------------------------------------
FROM static_base AS stage


# Prod target
# ------------------------------------------------------------
FROM static_base AS prod
