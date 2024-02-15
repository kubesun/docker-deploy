#!/bin/bash

set -x

url="http://192.168.2.158:7080"
token="glrt-nvzcGRKQEXKKAQqtnZy5"

mkdir -p $config

#docker run \
#-d \
#--name $img_name \
#--restart always \
#--privileged=true \
#-v $config:/etc/gitlab-runner \
#-v /var/run/docker.sock:/var/run/docker.sock \
#gitlab/gitlab-runner:latest

img_name="runner4"
config="/mnt/data/158/gitlab-runner/${img_name}/config"
mkdir -p $config
docker run \
  -d \
  -v $config:/etc/gitlab-runner \
  --name $img_name \
  --restart always \
  --privileged=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner

gitlab-runner verify
gitlab-runner restart

set +x
