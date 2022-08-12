#!/usr/bin/env sh
# shellcheck shell=dash

set -eux

mkdir -p artifacts
docker build -f "$1.Dockerfile" -t "build-$1" .
docker cp "$(docker create "build-$1"):/usr/src/nginx-build/nginx.tar.xz" "artifacts/nginx_$1.tar.xz"
