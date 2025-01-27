#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://hub.docker.com/r/apache/rocketmq
# https://rocketmq.apache.org/zh/docs/quickStart/03quickstartWithDockercompose/

# docker stop rmqui && docker rm rmqui
# docker stop rmqbroker && docker rm rmqbroker
# docker stop rmqnamesrv && docker rm rmqnamesrv
# docker stop rmqproxy && docker rm rmqproxy

docker network create rocketmq
VERSION="5.3.1"
WebUiPort="8088"
IP="127.0.0.1"
namesrcAddr="127.0.0.1"
cat > broker.conf <<EOF
brokerIP1=$IP
namesrcAddr=$namesrcAddr:9876
EOF

cat > compose.yml <<EOF
services:

  # RocketMQ Web控制台, 非核心组件,可以删除
  dashboard:
    image: apacherocketmq/rocketmq-dashboard:latest
    container_name: rmqui
    ports:
      - "${WebUiPort}:8080"
    networks:
      - rocketmq
    environment:
      - JAVA_OPTS=-Drocketmq.namesrv.addr=rmqnamesrv:9876  # 配置 NameServer 地址
    depends_on:
      - namesrv
      - broker
      - proxy
    restart: always

  # NameServer 服务
  namesrv:
    image: apache/rocketmq:${VERSION}
    container_name: rmqnamesrv
    ports:
      - "9876:9876"
    networks:
      - rocketmq
    environment:
      - JAVA_OPTS=-Duser.home=/opt
    command: sh mqnamesrv
    restart: always

  # Broker 服务
  broker:
    image: apache/rocketmq:${VERSION}
    container_name: rmqbroker
    ports:
      - "10909:10909"
      - "10911:10911"
      - "10912:10912"
    networks:
      - rocketmq
    environment:
      - NAMESRV_ADDR=rmqnamesrv:9876  # 使用容器名称连接 NameServer
    volumes:
      - ./broker.conf:/home/rocketmq/rocketmq-${VERSION}/conf/broker.conf
    depends_on:
      - namesrv
    command: sh mqbroker --enable-proxy -c /home/rocketmq/rocketmq-${VERSION}/conf/broker.conf
    restart: always

  # RocketMQ 代理
  proxy:
    image: apache/rocketmq:${VERSION}
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

networks:
  rocketmq:
    driver: bridge

EOF
docker compose up -d
sleep 5
docker compose logs
docker exec -it rmqbroker bash -c "tail -n 10 /home/rocketmq/logs/rocketmqlogs/proxy.log"
