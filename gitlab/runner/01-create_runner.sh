#!/bin/bash

set -x

# 容器名字, 用于docker容器时的别名
export IMG_NAME="alpine_shell"
# 配置, 用于docker runner容器运行时的存储路径
export CONFIG="/mnt/data/158/docker/runner/${IMG_NAME}/config"
# tag, 用于gitlab的tags标签选择器
export DESCRIPTION="shell"
# 镜像名, 用于在runner内运行的镜像, 例如golang:alpine, docker:dind, node:18-alpine3.19
export IMAGE="ccr.ccs.tencentyun.com/lisa/alpine:latest"

mkdir -pv $CONFIG
rm -rf ${CONFIG:?}/*
docker stop $IMG_NAME
docker rm $IMG_NAME
docker run \
  -itd \
  -v $CONFIG:/etc/gitlab-runner \
  --name $IMG_NAME \
  --restart always \
  --privileged=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner

docker exec -it $IMG_NAME gitlab-runner verify
docker exec -it $IMG_NAME gitlab-runner restart

# 常用命令
# gitlab-runner verify
# gitlab-runner restart

set +x
