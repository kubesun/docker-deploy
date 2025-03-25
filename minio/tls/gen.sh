#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 生成 CA 私钥（无密码）
openssl genrsa -out ca.key 2048
# 生成自签名 CA 根证书（有效期 10 年）
openssl req -x509 -new -key ca.key -days 3650 -out ca.crt -subj "/O=MyOrg/CN=MyRootCA"

# 生成服务器私钥
openssl genrsa -out public.key 2048
# 生成证书签名请求（CSR）
openssl req -new -key public.key -out server.csr -subj "/CN=minio.example.com"
# 使用 CA 签名生成服务器证书（有效期 1 年）
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out private.crt -days 365

mkdir -p ./CAs
mv ca.* ./CAs
