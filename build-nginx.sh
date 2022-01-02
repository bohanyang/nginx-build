#!/bin/sh
# shellcheck shell=dash disable=SC2064

set -eu

fetch_source() {
    local tmp
    tmp=$(mktemp)
    trap "rm -f '$tmp'" EXIT
    wget -O "$tmp" "$2"
    rm -rf "$1"
    mkdir -p "$1"
    tar -xzof "$tmp" -C "$1" --strip-components=1
    rm -f "$tmp"
    trap - EXIT
}

with_lib() {
    fetch_source "$2" "$3"
    CONFIGURE_ARGS="$CONFIGURE_ARGS --with-$1=../$2"
}

with_zlib() {
    case $1 in
        madler)
            with_lib zlib "zlib-$2" "https://www.zlib.net/zlib-$2.tar.gz"
            ;;
        ng)
            with_lib zlib "zlib-ng-$2" "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$2.tar.gz"
            make -C "zlib-ng-$2" -f Makefile.in distclean
            cd "nginx-${NGINX_VERSION}"
            patch -p1 << 'EOF'
diff --git a/auto/lib/zlib/make b/auto/lib/zlib/make
index 0082ad5..6f486e8 100644
--- a/auto/lib/zlib/make
+++ b/auto/lib/zlib/make
@@ -127,7 +127,7 @@ $ZLIB/libz.a:	$NGX_MAKEFILE
 	cd $ZLIB \\
 	&& \$(MAKE) distclean \\
 	&& CFLAGS="$ZLIB_OPT" CC="\$(CC)" \\
-		./configure \\
+		./configure --zlib-compat \\
 	&& \$(MAKE) libz.a

 END
EOF
            cd ..
            ;;
        cloudflare)
            with_lib zlib "zlib-cloudflare-$2" "https://github.com/cloudflare/zlib/archive/$2.tar.gz"
            make -C "zlib-cloudflare-$2" -f Makefile.in distclean
    esac
}

NGINX_VERSION=1.21.5
PCRE_VERSION=8.45
PCRE2_VERSION=10.39
OPENSSL_VERSION=3.0.1
NGX_BROTLI_VERSION=1.0.0rc
BROTLI_VERSION=1.0.9
NGX_GEOIP2_VERSION=3.3
LIBMAXMINDDB_VERSION=1.6.0

NGINX_URL="https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
PCRE_URL="https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz"
PCRE2_URL="https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
NGX_BROTLI_URL="https://github.com/google/ngx_brotli/archive/refs/tags/v${NGX_BROTLI_VERSION}.tar.gz"
BROTLI_URL="https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz"
NGX_GEOIP2_URL="https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/${NGX_GEOIP2_VERSION}.tar.gz"
LIBMAXMINDDB_URL="https://github.com/maxmind/libmaxminddb/releases/download/${LIBMAXMINDDB_VERSION}/libmaxminddb-${LIBMAXMINDDB_VERSION}.tar.gz"

CONFIGURE_ARGS="--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/run/nginx.pid \
--lock-path=/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-pcre-jit"

fetch_source "nginx-${NGINX_VERSION}" "$NGINX_URL"

#with_lib pcre "pcre-${PCRE_VERSION}" "$PCRE_URL"
with_lib pcre "pcre2-${PCRE2_VERSION}" "$PCRE2_URL"
with_lib openssl "openssl-${OPENSSL_VERSION}" "$OPENSSL_URL"

#with_zlib madler 1.2.11
#with_zlib cloudflare 959b4ea
with_zlib ng 2.0.5

fetch_source "ngx_brotli-${NGX_BROTLI_VERSION}" "$NGX_BROTLI_URL"

fetch_source "ngx_brotli-${NGX_BROTLI_VERSION}/deps/brotli" "$BROTLI_URL"
CONFIGURE_ARGS="$CONFIGURE_ARGS --add-module=../ngx_brotli-${NGX_BROTLI_VERSION}"

cd "nginx-${NGINX_VERSION}"

# shellcheck shell=dash disable=SC2086
./configure $CONFIGURE_ARGS
make "-j$(nproc)"
