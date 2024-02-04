#!/bin/bash

set -x

export NODE_IP="192.168.2.152"
export NODE_PORT="30003"

# 自签名证书, 如果不是自签名证书请注释掉:
# 如果是自签名的证书, 必须在全部节点安装证书!
# 如果是自签名的证书, 必须在全部节点安装证书!
# 如果是自签名的证书, 必须在全部节点安装证书!
export CONTAINERD_CONFIG_FILE_PATH="/etc/containerd/config.toml"
sed -i '/\[plugins\."io\.containerd\.grpc\.v1\.cri"\.registry\]/!b;n;s/config_path = .*/config_path = "\/etc\/containerd\/certs.d"/' /etc/containerd/config.toml
cat -n /etc/containerd/config.toml | grep -A 1 "\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.registry\]"

openssl s_client -showcerts -connect $NODE_IP:$NODE_PORT </dev/null 2>/dev/null | openssl x509 -outform PEM > harbor-cert.pem
# 将证书添加到 Docker 客户端的信任列表
mkdir -p /etc/docker/certs.d/$NODE_IP:$NODE_PORT
cp harbor-cert.pem /etc/docker/certs.d/$NODE_IP:$NODE_PORT/ca.crt

# 复制ca.crt到docker客户端所在机器
scp ca.crt root@$NODE_IP:/etc/docker/certs.d/$NODE_IP:30003/

# 尝试登录
docker login -u admin -p Harbor12345 https://$NODE_IP:$NODE_PORT

# 退出
# docker logout

set +x
