#!/bin/sh
set -x

config="/mnt/data/docker-gitlab/config"
logs="/mnt/data/docker-gitlab/logs"
data="/mnt/data/docker-gitlab/data"
mkdir -p $config
mkdir -p $logs
mkdir -p $data

host="192.168.2.100"
http_port="7080"
https_port="7443"
ssh_port="2222"
docker run -d \
-h $host \
-p $http_port:80 \
-p $https_port:443 \
-p $ssh_port:22 \
-e TZ=Asia/Shanghai \
--shm-size 256m \
--name gitlab \
--restart always \
-v $config:/etc/gitlab \
-v $logs:/var/log/gitlab \
-v $data:/var/opt/gitlab \
gitlab/gitlab-ce:latest

# 查看密码, 账号默认是root
cat $config/initial_root_password


# vi $config/gitlab.rb

set +x
