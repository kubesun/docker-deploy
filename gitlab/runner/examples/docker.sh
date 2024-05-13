#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

DOCKER_VERSION="docker:24.0.5"
docker exec -it "$IMG_NAME" gitlab-runner register \
  --non-interactive \
  --URL "$URL" \
  --token "$REGISTRATION_TOKEN" \
  --executor docker \
  --docker-image "$DOCKER_VERSION" \
  --description "$DESCRIPTION" \
  gitlab/gitlab-runner
