#!/bin/bash
set -x

export DIR="/mnt/data/158/docker/kafka"
export DATA_DIR="/mnt/data/158/docker/kafka/config"
export CONFIG_DIR="/mnt/data/158/docker/kafka/data"
export LOGS_DIR="/mnt/data/158/docker/kafka/logs"
export HOST="192.168.2.101"
export PORT="9192"
export WEB_UI_PORT="9191"
export CONTROLLER_PORT="9193"
export INTERNAL_PORT="9194"

rm -rf $DIR
rm -rf $DATA_DIR
rm -rf $CONFIG_DIR
rm -rf $LOGS_DIR

mkdir -p $DIR
mkdir -p $DATA_DIR
mkdir -p $CONFIG_DIR
mkdir -p $LOGS_DIR

chmod -R 755 $DIR
chmod -R 755 $DATA_DIR
chmod -R 755 $CONFIG_DIR
chmod -R 755 $LOGS_DIR

# TODO
# https://juejin.cn/post/7294556533932884020
# https://docs.kafka-ui.provectus.io/overview/getting-started
cat > kafka-docker-compose <<EOF
version: '3.5'
services:
  kafka:
    image: bitnami/kafka:latest
    container_name: kafka
    # 初始化一写数据 写入kafka的数据，会被保存在容器的/tmp/logs目录下
    command:
      - 'sh'
      - '-c'
      - '/opt/bitnami/scripts/kafka/setup.sh && kafka-storage.sh format --config "$${KAFKA_CONF_FILE}" --cluster-id "lkorDA4qT6W1K_dk0LHvtg" --ignore-formatted  && /opt/bitnami/scripts/kafka/run.sh' # Kraft specific initialise
    environment:
      - BITNAMI_DEBUG=yes
      - ALLOW_PLAINTEXT_LISTENER=yes # 允许使用PLAINTEXT监听器，默认false，不建议在生产环境使用
      - KAFKA_CFG_NODE_ID=1 # 节点id，必须唯一
      - KAFKA_CFG_BROKER_ID=1 # broker.id，必须唯一
      - KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=1@kafka:$CONTROLLER_PORT   # 集群地址
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,INTERNAL:PLAINTEXT # 定义安全协议
      - KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER # 指定供外部使用的控制类请求信息
      - KAFKA_CFG_LOG_DIRS=/tmp/logs # 日志目录
      - KAFKA_CFG_PROCESS_ROLES=broker,controller # kafka角色，做broker，也要做controller
      - KAFKA_CFG_LISTENERS=PLAINTEXT://0.0.0.0:$PORT,CONTROLLER://0.0.0.0:$CONTROLLER_PORT,INTERNAL://0.0.0.0:$INTERNAL_PORT # 定义kafka服务端socket监听端口
      - KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true # 是否允许自动创建主题
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://$HOST:$PORT,INTERNAL://kafka:$INTERNAL_PORT # 定义外网访问地址（宿主机ip地址和端口）
    ports:
      - "0.0.0.0:$PORT:9092"
    volumes:
      - $DIR:/bitnami/kafka
      - $CONFIG_DIR/config:/bitnami/kafka/config
      - $DATA_DIR/data:/bitnami/kafka/data
      - $LOGS_DIR/logs:/bitnami/kafka/logs

  kafka-ui:
    image: provectuslabs/kafka-ui
    container_name: kafka-ui
    ports:
      - "$WEB_UI_PORT:8080" # kafka-ui的Web端口
    restart: "always"
    environment:
      KAFKA_CLUSTERS_0_NAME: "lkorDA4qT6W1K_dk0LHvtg" # 集群id
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:$INTERNAL_PORT # 集群地址
    depends_on:
      - kafka

EOF

docker-compose -f kafka-docker-compose up -d

set +x
