FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG GITHUB_TOKEN
ARG UPLOAD_URL
ARG NGINX_VERSION

RUN set -eu; \
    [ -n "$GITHUB_TOKEN" ]; \
    [ -n "$UPLOAD_URL" ]; \
    [ -n "$NGINX_VERSION" ]

COPY . /usr/src/nginx-build/

WORKDIR /usr/src/nginx-build/

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-suggests --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        file \
        wget \
        patch \
        libxslt1-dev \
    ; \
    ./build-upload-binary.sh
