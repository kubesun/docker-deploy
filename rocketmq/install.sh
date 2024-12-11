#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 公网IP地址
HOST_IP=""
# Web UI 是8082

cat > compose.yml <<EOF
services:

  namesrv:
    image: apache/rocketmq:5.3.1
    container_name: rmqnamesrv
    ports:
      - 9876:9876
    networks:
      - rocketmq
    command: sh mqnamesrv

  broker:
    image: apache/rocketmq:5.3.1
    container_name: rmqbroker
    ports:
      - 10909:10909
      - 10911:10911
      - 10912:10912
    environment:
      - NAMESRV_ADDR=rmqnamesrv:9876
    depends_on:
      - namesrv
    networks:
      - rocketmq
    command: sh mqbroker

  proxy:
    image: apache/rocketmq:5.3.1
    container_name: rmqproxy
    networks:
      - rocketmq
    depends_on:
      - broker
      - namesrv
    ports:
      - 8080:8080
      - 8081:8081
    restart: on-failure
    environment:
      - NAMESRV_ADDR=rmqnamesrv:9876
    command: sh mqproxy

  dashboard:
    depends_on:
      - broker
      - namesrv
      - proxy
    image: apacherocketmq/rocketmq-dashboard:latest
    container_name: rmqui
    environment:
      - JAVA_OPTS=-Drocketmq.namesrv.addr=$HOST_IP:9876
    ports:
      - 8082:8080
    networks:
      - rocketmq

networks:
  rocketmq:
    driver: bridge
EOF
