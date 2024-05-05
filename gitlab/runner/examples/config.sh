#!/bin/bash

set -x

# Docker in Docker
# https://docs.gitlab.com/ee/ci/docker/using_docker_build.html
url="http://192.168.2.158:7080"
docker_version="docker:24.0.5"

REGISTRATION_TOKEN=""
sudo gitlab-runner register -n \
  --url $url \
  --registration-token $REGISTRATION_TOKEN \
  --executor docker \
  --description "Docker in Docker 24.0.5" \
  --docker-image $docker_version \
  --docker-privileged \
  --docker-volumes "/certs/client" \

set +x
