FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive

COPY . /usr/src/nginx-build/

WORKDIR /usr/src/nginx-build/

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-suggests --no-install-recommends \
        build-essential \
        ca-certificates \
        wget \
        patch \
        libxslt1-dev \
    ; \
    ./build.sh
