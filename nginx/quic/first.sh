#!/usr/bin/env bash

# DOMAIN="lookeke.cn"
DOMAIN="lookeke.top"
server_name=$DOMAIN

if [ -z "${DOMAIN}" ]; then
    exit 1
    echo "请编写你的域名"
fi

# 判断 NGINX_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${NGINX_DIR}" ]; then
    export NGINX_DIR="/home/nginx"
fi

# 判断 WEB_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${WEB_DIR}" ]; then
    export WEB_DIR="${NGINX_DIR}/html"
fi

# 判断 CONF_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${CONF_DIR}" ]; then
    export CONF_DIR="${NGINX_DIR}/conf"
fi

# 判断 SSL_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${SSL_DIR}" ]; then
    export SSL_DIR="${NGINX_DIR}/ssl"
fi

mkdir -p $WEB_DIR
mkdir -p $CONF_DIR
mkdir -p $SSL_DIR
cd $NGINX_DIR || exit

#SSL_DIR=$(pwd)
cp $SSL_DIR/*.crt $SSL_DIR/nginx.crt
cp $SSL_DIR/*.key $SSL_DIR/nginx.key

# https://github.com/macbre/docker-nginx-http3
docker pull ghcr.io/macbre/nginx-http3:latest

export server_name="server_name"

cat > ${CONF_DIR}/nginx.conf <<EOF
server {
    listen 80;
    server_name $server_name; # server_name
    return 301 https://${DOMAIN}; # webside
}

server {
    server_name ${DOMAIN} www.${DOMAIN};  # 服务器名称

    # UDP listener for QUIC+HTTP/3
    # http/3
    listen 443 quic reuseport;

    # http/2 and http/1.1
    listen 443 ssl;
    http2 on;

    # 以下为各种 HTTP 安全相关头部的设置
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "DENY";
    add_header Alt-Svc 'h3=":443"; ma=86400, h3-29=":443"; ma=86400';

    # SSL/TLS 相关配置
    ssl_protocols TLSv1.3 TLSv1.2;  # 设置支持的 SSL 协议版本
    # ssl_ciphers ...;  # 设置 SSL 密码套件
    ssl_prefer_server_ciphers on;  # 优先使用服务器的密码套件
    ssl_ecdh_curve X25519:P-256:P-384;  # 设置 ECDH 曲线
    ssl_early_data on;  # 启用 TLS 1.3 的 0-RTT 特性
    ssl_stapling on;  # 启用 OCSP Stapling
    ssl_stapling_verify on;  # 启用 OCSP Stapling 的验证

    # SSL 证书路径配置
    ssl_certificate     /etc/nginx/ssl/nginx.crt;  # SSL 证书路径
    ssl_certificate_key /etc/nginx/ssl/nginx.key;  # SSL 证书密钥路径

    location / {
        root   /etc/nginx/html;  # 设置根目录路径
        index  index.html index.htm default.html default.htm;  # 设置默认index首页文件
    }
}
EOF

docker stop nginx-quic || true
docker rm nginx-quic || true

# WEB_DIR=""
# CONF_DIR=""
# SSL_DIR=""
docker run -itd \
--name nginx-quic \
-v ${WEB_DIR}:/etc/nginx/html \
-v ${CONF_DIR}:/etc/nginx/conf.d \
-v ${SSL_DIR}:/etc/nginx/ssl \
-p '443:443/tcp' \
-p '443:443/udp' \
-p 80:80 \
ghcr.io/macbre/nginx-http3

echo "正在查看日志, 按 Ctrl + C 退出"
docker logs nginx-quic | head -n 10
