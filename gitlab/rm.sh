#!/bin/bash

set -x
config="/mnt/data/docker-gitlab-158/config"
logs="/mnt/data/docker-gitlab-158/logs"
data="/mnt/data/docker-gitlab-158/data"

rm -rf $config
rm -rf logs
rm -rf data

container_id=""
docker stop "$container_id"
docker rm "$container_id"

set +x
