#!/bin/bash

set -xeu

export HARBOR_HOME="/home/harbor"

mkdir -p $HARBOR_HOME/conf
mkdir -p $HARBOR_HOME/logs
mkdir -p $HARBOR_HOME/data

cd $HARBOR_HOME || exit

访问 https://github.com/goharbor/harbor/releases/ 查看版本并把 VERSION 变量替换为指定版本

export VERSION="v2.10.0-rc2"
wget https://github.com/goharbor/harbor/releases/download/${VERSION}/harbor-offline-installer-${VERSION}.tgz
tar -xzvf harbor-offline-installer-${VERSION}.tgz

cd harbor || exit
mv ../harbor.yaml .

chmod +x ./install.sh
./install.sh

#生成ssl证书
#生成私钥文件（.key）：
openssl genrsa -out harbor.key 4096

#生成证书签名请求文件（.csr）：
# 在README步骤已执行
#在生成证书签名请求文件时，您需要填写一些证书信息，如国家、省份、组织、通用名称等。
#openssl req -new -key harbor.key -out harbor.csr

#使用生成的证书签名请求文件和私钥文件生成自签名的TLS证书（.crt）：
openssl x509 -req -in harbor.csr -signkey harbor.key -out harbor.crt

set +x
