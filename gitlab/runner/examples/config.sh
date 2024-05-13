#!/bin/bash

set -x

# Docker in Docker
# https://docs.gitlab.com/ee/ci/docker/using_docker_build.html
URL="https://gitlab.com"
docker_version="docker:24.0.5"

REGISTRATION_TOKEN=""
sudo gitlab-runner register -n \
  --URL $URL \
  --registration-token "$REGISTRATION_TOKEN" \
  --executor docker \
  --description "Docker in Docker 24.0.5" \
  --docker-image $docker_version \
  --docker-privileged \
  --docker-volumes "/certs/client"

set +x
