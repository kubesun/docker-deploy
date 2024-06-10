#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 检查变量是否存在
if [ -z "$URL" ] || [ -z "$TOKEN" ] || [ -z "$IMG_NAME" ] || [ -f "$CONFIG" ] || [ -z "$DESCRIPTION" ]|| [ -z "$IMAGE" ]; then
    echo "其中一个或多个变量不存在，请提供所有必要的变量"
    exit 1
fi


# executor选择: https://docs.gitlab.com/runner/executors/index.html
# 1. ssh: 这是一个简单的执行程序，允许您通过 SSH 执行命令在远程计算机上执行构建
# 1. shell: Shell 执行程序是一个简单的执行程序，用于在安装了 GitLab Runner 的计算机上本地执行构建。它支持所有可以安装 Runner 的系统。这意味着可以使用为 Bash、PowerShell Core、Windows PowerShell 和 Windows Batch（已弃用）生成的脚本
# 1. docker: GitLab Runner 使用 Docker 执行器在 Docker 映像上运行作业。
# 1. kubernetes: 使用 Kubernetes 执行程序将 Kubernetes 集群用于构建。执行程序调用 Kubernetes 集群 API 并为每个 GitLab CI 作业创建一个 Pod。

export URL="https://gitlab.com"
export TOKEN="glrt-EArq7DWHMupxx3wqsUQo"
export EXECUTOR="shell"
# shell环境要求: https://docs.gitlab.com/runner/executors/index.html#shell-executor

# 如果所有变量都存在，继续执行后续操作
echo "所有变量都存在，继续执行脚本..."
echo "URL: $URL"
echo "REGISTRATION_TOKEN: $TOKEN"
echo "IMG_NAME: $IMG_NAME"
echo "CONFIG: $CONFIG"
echo "DESCRIPTION: $DESCRIPTION"
echo "EXECUTOR: $EXECUTOR"

docker exec -it "$IMG_NAME" gitlab-runner register \
  --non-interactive \
  --url "$URL" \
  --token "$TOKEN" \
  --executor "$EXECUTOR" \
  --docker-image "$IMAGE" \
  --description "$DESCRIPTION" \
  gitlab/gitlab-runner

docker exec -it $IMG_NAME gitlab-runner verify
docker exec -it $IMG_NAME gitlab-runner restart
