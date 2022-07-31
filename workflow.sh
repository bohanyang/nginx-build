#!/bin/sh

set -eux

sudo apt-get install -y libxslt1-dev
mkdir build-nginx
cd build-nginx
../build-nginx.sh
cd nginx-*
sudo make install
cd ../..
sudo cp -R root/. /
tar -c -v -J -f "nginx.tar.xz" -C / etc/nginx etc/systemd/system/nginx.service usr/local/bin/nginx-pull-config usr/local/bin/nginx-upgrade usr/sbin/nginx usr/lib/nginx/modules
