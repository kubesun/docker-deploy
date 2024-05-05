#!/usr/bin/env bash
set -o errexit -o pipefail

export OS="linux"
export ARCH="amd64"
#export VERSION="jenkins/jenkins:2.419-alpine-jdk17"
export VERSION="ccr.ccs.tencentyun.com/rccc/jenkins:v2"
export IMAGE_NAME="jenkins"
docker run \
-d \
-u root \
--name ${IMAGE_NAME} \
--restart=always \
-p 8086:8080 \
-p 50000:50000 \
-v /data/jenkins/data:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
${VERSION}

# Kubectl
rm -rf kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"
./kubectl version
docker cp ./kubectl ${IMAGE_NAME}:/bin/kubectl
sudo docker exec -it ${IMAGE_NAME} chmod +x /bin/kubectl
sudo docker exec -it ${IMAGE_NAME} /bin/kubectl version

# Go
export GO_VERSION="go1.22.2"
docker exec -it ${IMAGE_NAME} apk add bash
rm -rf go1.22.2.linux-amd64.tar.gz
docker exec -it ${IMAGE_NAME} wget https://golang.google.cn/dl/${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker cp ${GO_VERSION}.${OS}-${ARCH}.tar.gz ${IMAGE_NAME}:/${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} tar -C /usr/local -xzf /${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} rm -rf /${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} /bin/bash -c "echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc"
docker exec -it ${IMAGE_NAME} /bin/bash -c "source ~/.bashrc"
docker exec -it ${IMAGE_NAME} /bin/bash -c "go version"

# Node
docker exec -it ${IMAGE_NAME} apk add nodejs
docker exec -it ${IMAGE_NAME} apk add npm
docker exec -it ${IMAGE_NAME} npm install -g pnpm
docker exec -it ${IMAGE_NAME} pnpm -v

# Push Images in Harbor
docker commit ${IMAGE_NAME} 192.168.2.152:30003/jenkins/jenkins:v1
docker push 192.168.2.152:30003/jenkins/jenkins:v1
