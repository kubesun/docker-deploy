#!/bin/bash
set -x

docker pull docker.elastic.co/kibana/kibana:8.12.1

docker run \
  --name kib01 \
  --net elastic \
  -itd \
  -p 5601:5601 \
  docker.elastic.co/kibana/kibana:8.12.1
docker logs -f kib01

docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

#若要重新生成令牌，请运行：
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

#使用启动 Elasticsearch 时生成 elastic 的密码以用户身份登录 Kibana。
#若要重新生成Elasticsearch的密码，请运行：
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
# lJgqCLle3yWZf5mAHOaz
set +x
