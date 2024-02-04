#!/bin/sh
set -x

mkdir -p /home/gitlab/config
mkdir -p /home/gitlab/logs
mkdir -p /home/gitlab/data

docker run -d \
-h 192.168.2.158 \
-p 6080:80 \
-p 6443:443 \
-p 2222:22 \
-e TZ=Asia/Shanghai \
--shm-size 256m \
--name gitlab \
--restart always \
-v /home/gitlab/config:/etc/gitlab \
-v /home/gitlab/logs:/var/log/gitlab \
-v /home/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest

vi /home/gitlab/config/gitlab.rb

set +x
