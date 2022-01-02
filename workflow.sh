#!/bin/sh

set -eux

mkdir build-nginx
cd build-nginx
../build-nginx.sh
cd nginx-*
sudo make install
cd ../..
sudo cp -R root/. /
tar -c -v -J -f "nginx.tar.xz" -C / etc/nginx etc/systemd/system/nginx.service usr/local/bin/nginx-pull-config usr/sbin/nginx
