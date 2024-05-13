#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 检查变量是否存在
if [ -z "$URL" ] || [ -z "$REGISTRATION_TOKEN" ] || [ -z "$IMG_NAME" ] || [ -f "$CONFIG" ] || [ -z "$DESCRIPTION" ]|| [ -z "$IMAGE" ]; then
    echo "其中一个或多个变量不存在，请提供所有必要的变量"
    exit 1
fi

# 如果所有变量都存在，继续执行后续操作
echo "所有变量都存在，继续执行脚本..."
echo "URL: $URL"
echo "REGISTRATION_TOKEN: $REGISTRATION_TOKEN"
echo "IMG_NAME: $IMG_NAME"
echo "CONFIG: $CONFIG"
echo "DESCRIPTION: $DESCRIPTION"

docker exec -it "$IMG_NAME" gitlab-runner register \
  --non-interactive \
  --url "$URL" \
  --token "$REGISTRATION_TOKEN" \
  --executor docker \
  --docker-image "$IMAGE" \
  --description "$DESCRIPTION" \
  gitlab/gitlab-runner

docker exec -it $IMG_NAME gitlab-runner restart
