#!/bin/bash

set -x

#docker run \
#-d \
#--name $img_name \
#--restart always \
#--privileged=true \
#-v $config:/etc/gitlab-runner \
#-v /var/run/docker.sock:/var/run/docker.sock \
#gitlab/gitlab-runner:latest

url="https://gitlab.com"
token="glrt-ck3f9RDuY74Fp7aAvw9G"

img_name="runner2"
config="/mnt/data/158/docker/runner/${img_name}/config"
mkdir -p $config
docker run \
  -d \
  -v $config:/etc/gitlab-runner \
  --name $img_name \
  --restart always \
  --privileged=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner

# 常用命令
# gitlab-runner verify
# gitlab-runner restart

set +x
