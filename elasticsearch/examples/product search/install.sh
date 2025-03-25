#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

https://n5n1jvl8yo.feishu.cn/docx/VBT9dat91oPgaqxwE0BcVuF3n6d?from=from_copylink

cat > compose.yml <<EOF
services:
  elasticsearch:
    container_name: elasticsearch
    image: docker.elastic.co/elasticsearch/elasticsearch:8.9.1
    environment:
      - node.name=elasticsearch
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - 9200:9200
      - 9300:9300
    networks:
      - elastic
  kibana:
    image: docker.elastic.co/kibana/kibana:8.9.1
    container_name: kibana
    environment:
      I18N_LOCALE: zh-CN
    ports:
      - 5601:5601
    networks:
      - elastic
    depends_on:
      - elasticsearch

networks:
  elastic:
EOF
docker compose up -d
