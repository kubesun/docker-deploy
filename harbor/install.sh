#!/bin/bash

set -xeu

export HARBOR_HOME="/home/harbor"
mkdir -p $HARBOR_HOME

cd $HARBOR_HOME || exit

# 访问 https://github.com/goharbor/harbor/releases/ 查看版本并把 VERSION 变量替换为指定版本
export VERSION="v2.10.0-rc2"
wget https://github.com/goharbor/harbor/releases/download/${VERSION}/harbor-offline-installer-${VERSION}.tgz
tar -xzvf harbor-offline-installer-${VERSION}.tgz

set +x
