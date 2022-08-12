#!/usr/bin/env sh
# shellcheck shell=dash

set -eux

VERSION_CODENAME=$(. /etc/os-release; echo "$ID $VERSION_CODENAME $VERSION_ID")
ARCHITECTURE=$(dpkg --print-architecture)

mkdir build
cd build
../build-nginx.sh
cd "nginx-$NGINX_VERSION"
make install
cd ../..
cp -R root/. /
tar -c -v -J -f nginx.tar.xz -C / etc/nginx etc/systemd/system/nginx.service usr/local/bin/nginx-pull-config usr/local/bin/nginx-upgrade usr/sbin/nginx usr/lib/nginx/modules
curl -f -X POST -D - \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H 'Accept: application/vnd.github.v3+json' \
  -H 'Content-Type: application/x-xz' \
  --data-binary '@nginx.tar.xz' \
  "${UPLOAD_URL}?name=nginx-${NGINX_VERSION}-${VERSION_CODENAME}_${ARCHITECTURE}.tar.xz"
