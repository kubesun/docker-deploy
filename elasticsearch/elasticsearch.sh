#!/bin/bash
set -x

docker network create elastic
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.12.1

mkdir -p /mnt/data/158/docker/es/data
mkdir -p /mnt/data/158/docker/es/plugins
chmod -R 777 /mnt/data/158/docker/es/data
chmod -R 777 /mnt/data/158/docker/es/plugins

# -e ES_JAVA_OPTS="-Xms256m -Xmx256m" 控制运行内存
#-p 9200:9200 -p 9300:9300 两个ES端口的映射
#-p 5601:5601 kibana端口的映射
rm -rf /mnt/data/158/docker/es/data/*
rm -rf /mnt/data/158/docker/es/plugins/*
docker stop es01;docker rm es01
docker run \
  --name es01 \
  --net elastic \
  -e ES_JAVA_OPTS="-Xms256m -Xmx256m" \
  -e "discovery.type=single-node" \
  -v /mnt/data/158/docker/es/data:/usr/share/elasticsearch/data \
  -v /mnt/data/158/docker/es/plugins:/usr/share/elasticsearch/plugins \
  -p 9200:9200 \
  -itd \
  -m 3GB \
  docker.elastic.co/elasticsearch/elasticsearch:8.12.1

docker logs -f es01

docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

# 启动错误78: 可能的解决方案
cp /etc/sysctl.conf{,back}
cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=262144
EOF
sysctl -p
sysctl -a|grep vm.max_map_count

set +x
