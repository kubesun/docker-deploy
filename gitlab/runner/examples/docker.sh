#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 如果使用Docker v19.03或更高版本中，默认开启TLS，需要额外配置, 参考https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#docker-in-docker-with-tls-enabled-in-the-docker-executor
# 关闭TLS: https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#docker-in-docker-with-tls-disabled-in-the-docker-executor

# 在gitlab创建时显示的url
#export URL="http://192.168.2.158:7080"
export URL="https://gitlab.com"
# 在gitlab创建时显示的token
export REGISTRATION_TOKEN="glrt-GvMUiXWYBZmkzsmv7ULz"
# tag, 用于gitlab的tags标签选择器
export DESCRIPTION="docker_26.1.0_dind_alpine3.19"
# 镜像名, 用于在runner内运行的镜像, 例如golang:alpine, docker:24.0.5, node:18-alpine3.19
export IMAGE="docker:26.1.0-dind-alpine3.19"
# 容器名字, 用于docker容器时的别名
export IMG_NAME="docker_26.1.0_dind_alpine3.19_2"
# 配置, 用于docker runner容器运行时的存储路径
export CONFIG="/mnt/data/158/docker/runner/${IMG_NAME}/config"

mkdir -pv $CONFIG
rm -rf ${CONFIG:?}/*
docker stop $IMG_NAME
docker rm $IMG_NAME
docker run \
  -itd \
  -v $CONFIG:/etc/gitlab-runner \
  --name $IMG_NAME \
  --restart always \
  --privileged=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner

docker exec -it $IMG_NAME gitlab-runner verify
docker exec -it $IMG_NAME gitlab-runner restart

docker exec -it "$IMG_NAME" gitlab-runner register \
  --non-interactive \
  --url "$URL" \
  --registration-token "$REGISTRATION_TOKEN" \
  --executor docker \
  --docker-image "$IMAGE" \
  --description "$DESCRIPTION" \
  --docker-privileged \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --docker-volumes $CONFIG \
  gitlab/gitlab-runner

docker restart $IMG_NAME
docker exec -it $IMG_NAME gitlab-runner verify

# 如果是Docker in Docker,本例子就是, 需要添加特权, 参考https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker
cp $CONFIG/config.toml{,.back}
sed -i 's/privileged = false/privileged = true/g' $CONFIG/config.toml

# 出现错误时, 把备份替换回去
# cp $CONFIG/config.toml{.back,}

# 检查配置是否成功
if ! grep -q "volumes" "$CONFIG/config.toml" -ne 0; then
  echo "修改配置文件没有成功, 请手动配置文件"
  exit 1
fi

if ! grep -q "privileged = true" "${CONFIG}/config.toml" -ne 0 ; then
  echo "修改配置文件没有成功, 请手动配置文件"
  exit 1
fi

docker exec -it $IMG_NAME gitlab-runner restart
