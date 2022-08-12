#!/usr/bin/env sh
# shellcheck shell=dash

set -ex

mkdir build
cd build
../build-nginx.sh
cd nginx-*
make install
cd ../..
cp -R root/. /
tar -c -v -J -f "nginx.tar.xz" -C / etc/nginx etc/systemd/system/nginx.service usr/local/bin/nginx-pull-config usr/local/bin/nginx-upgrade usr/sbin/nginx usr/lib/nginx/modules
