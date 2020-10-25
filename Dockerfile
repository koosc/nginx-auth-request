FROM ubuntu:18.04

RUN mkdir /data && mkdir /certs

RUN apt-get update && apt-get install -y git wget zlib1g gcc libxslt-dev openssl

COPY . /data

RUN mkdir /module && cd /module; git clone https://github.com/perusio/nginx-auth-request-module.git

RUN  wget ftp://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && \
 tar -zxf pcre-8.42.tar.gz && \
 cd pcre-8.42 && \
 ./configure && \
 make && \
  make install

RUN wget http://zlib.net/zlib-1.2.11.tar.gz && \
 tar -zxf zlib-1.2.11.tar.gz 

RUN wget http://www.openssl.org/source/openssl-1.1.1c.tar.gz && \
 tar -zxf openssl-1.1.1c.tar.gz && \
 cd openssl-1.1.1c

RUN wget https://nginx.org/download/nginx-1.17.4.tar.gz && \
 tar zxf nginx-1.17.4.tar.gz && \
 cd nginx-1.17.4 && \
 ./configure --prefix=/etc/nginx  --sbin-path=/usr/sbin/nginx  --modules-path=/usr/lib64/nginx/modules  --add-module=/module/nginx-auth-request-module  --conf-path=/etc/nginx/nginx.conf   --error-log-path=/var/log/nginx/error.log  --pid-path=/var/run/nginx.pid  --lock-path=/var/run/nginx.lock  --user=root  --group=root   --builddir=nginx-1.15.7  --with-select_module  --with-poll_module  --with-threads  --with-file-aio  --with-http_ssl_module  --with-http_v2_module  --with-http_realip_module  --with-http_addition_module  --with-http_xslt_module=dynamic   --with-http_sub_module  --with-http_dav_module  --with-http_flv_module  --with-http_mp4_module  --with-http_gunzip_module  --with-http_gzip_static_module    --with-http_random_index_module  --with-http_secure_link_module  --with-http_degradation_module  --with-http_slice_module  --with-http_stub_status_module     --http-log-path=/var/log/nginx/access.log  --http-client-body-temp-path=/var/cache/nginx/client_temp  --http-proxy-temp-path=/var/cache/nginx/proxy_temp  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp  --http-scgi-temp-path=/var/cache/nginx/scgi_temp  --with-mail=dynamic  --with-mail_ssl_module  --with-stream=dynamic  --with-stream_ssl_module  --with-stream_realip_module    --with-stream_ssl_preread_module  --with-compat  --with-pcre=../pcre-8.42  --with-pcre-jit  --with-zlib=../zlib-1.2.11  --with-openssl=../openssl-1.1.1c  --with-openssl-opt=no-nextprotoneg  --with-debug && \
 make && make install

RUN mkdir -p /var/cache/nginx

COPY docker-entrypoint.sh /
COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY 20-envsubst-on-templates.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
