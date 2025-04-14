#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir /home/docker/casdoor/conf
cd /home/docker/casdoor || exit

# 前端端口
CASDOOR_FRENTEND_PORT=8081
# 后端地址, 包含协议主机和端口
CASDOOR_BACKEND_ENDPOINT=http://casdoor:8000

# Casdoor 的 app.conf 配置文件, 具体编写参考https://casdoor.org/zh/docs/basic/server-installation
# 这里只列出常用的配置项
# redis 地址, 如果包含密码则使用: redis_addr:3028,username,password 格式, 不需要则填空字符串
REDIS_ENDPOINT=
# 域名, 例如: example.com
DOMAIN=
# 数据库类型, 例如: mysql, postgres, sqlite
DRIVER_NAME=
# 数据库连接地址字符串
DATA_SOURCE_NAME=

cat > compose.yml <<EOF
services:

  nginx:
    image: ccr.ccs.tencentyun.com/sumery/nginx-http3
    container_name: casdoor-nginx
    build:
      context: .
      dockerfile: .
      target: final
    ports:
      - '8081:8081/udp'
      - '8081:8081/tcp'
    networks:
      - casdoor
    # 环境变量
    environment:
      DOMAIN: ${DOMAIN} # 这里需要替换成你的域名
    restart: on-failure:4 # 重启策略，最多重启n次
    volumes:
      - /home/docker/casdoor/conf:/etc/nginx/conf.d
      - /home/docker/nginx/ssl:/etc/nginx/ssl:ro

  casdoor:
    image: casbin/casdoor:latest
    container_name: casdoor
    networks:
      - casdoor
    ports:
      - "8000:8000"
    environment:
      DRIVER_NAME: postgres
      dbName: casdoor
#      DATA_SOURCE_NAME: "user=postgres password=citus host=citus port=5432 sslmode=disable dbname=casdoor"
    volumes:
      - ./:/conf

networks:
  casdoor:
EOF

cat > conf/nginx.conf <<EOF
server {
    server_name ${DOMAIN};

    # HTTP/3 with QUIC
    listen ${CASDOOR_FRENTEND_PORT} quic reuseport;

    # HTTP/2 and HTTP/1.1
    listen ${CASDOOR_FRENTEND_PORT} ssl;
    http2 on;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDOMAINs; preload" always;
    add_header X-XSS-Protection          "1; mode=block" always;
    add_header X-Frame-Options           SAMEORIGIN always;
    add_header X-Content-Type-Options    nosniff always;
    add_header Alt-Svc                   'h3=":${CASDOOR_FRENTEND_PORT}"; ma=86400; h3-29=":${CASDOOR_FRENTEND_PORT}"; ma=86400';

    # SSL/TLS configuration
    ssl_protocols               TLSv1.3 TLSv1.2;
    ssl_ecdh_curve              X25519:P-256:P-384;

    # 通用兼容性密码套件
    ssl_ciphers                 "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256";

    ssl_prefer_server_ciphers   on;

    # 显式声明 TLS 1.3 密码（需要 OpenSSL 1.1.1+）
    ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256;

    # SSL certificates
    ssl_certificate     /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        proxy_set_header    Host            \$http_host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_redirect      off;
        #proxy_pass http://127.0.0.1:8000;
        proxy_pass ${CASDOOR_BACKEND_ENDPOINT};
    }
}
EOF

cat > app.conf <<EOF
appname = casdoor
httpport = 8000
runmode = prod
copyrequestbody = true
driverName = ${DRIVER_NAME}
dataSourceName = ${DATA_SOURCE_NAME}
dbName = casdoor
tableNamePrefix =
showSql = false
redisEndpoint = ${REDIS_ENDPOINT}
defaultStorageProvider =
isCloudIntranet = false
authState = "casdoor"
socks5Proxy = "127.0.0.1:7890"
verificationCodeTimeout = 10
initScore = 0
logPostOnly = true
isUsernameLowered = false
origin = https://${DOMAIN}:${CASDOOR_FRENTEND_PORT}
originFrontend =
staticBaseUrl = "https://cdn.casbin.org"
isDemoMode = false
batchSize = 100
enableErrorMask = false
enableGzip = true
inactiveTimeoutMinutes =
ldapServerPort = 389
ldapsCertId = ""
ldapsServerPort = 636
radiusServerPort = 1812
radiusDefaultOrganization = "built-in"
radiusSecret = "secret"
quota = {"organization": -1, "user": -1, "application": -1, "provider": -1}
logConfig = {"filename": "logs/casdoor.log", "maxdays":99999, "perm":"0770"}
initDataNewOnly = false
initDataFile = "./init_data.json"
frontendBaseDir = "../cc_0"
EOF

docker compose up -d
docker compose logs

