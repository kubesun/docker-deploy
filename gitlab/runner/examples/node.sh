#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 检查变量是否存在
if [ -z "$img_name" ] || [ -z "$url" ] || [ -z "$token" ] || [ -z "$image" ]; then
    echo "其中一个或多个变量不存在，请提供所有必要的变量"
    exit 1
fi

# 如果所有变量都存在，继续执行后续操作
echo "所有变量都存在，继续执行脚本..."

# node:18-alpine3.19
docker exec -it $img_name gitlab-runner register \
  --non-interactive \
  --url $url \
  --token "$token" \
  --executor "docker" \
  --docker-image node:18-alpine3.19 \
  --description "node" \
  gitlab/gitlab-runner

docker restart $img_name
