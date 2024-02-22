#!/bin/bash
# 机器IP或域名
export KAFKA_HOST="192.168.2.158"
# Kafka的Web UI端口
export KAFKA_UI_PORT="9081"
# Kafka的BROKER端口
export KAFKA_BROKER_PORT="9092"
# Kafka的数据目录
export KAFKA_VOLUME_DIR="/mnt/data/158/docker/bitnami"
# Kafka的部署文件名, 不需要修改
export FILE_NAME="docker-compose.yaml"
#KAFKA_INTER_BROKER_USER="user"
#KAFKA_INTER_BROKER_PASSWORD="msdnmm"

rm -rf $KAFKA_VOLUME_DIR
mkdir -p $KAFKA_VOLUME_DIR
mkdir -p $KAFKA_VOLUME_DIR/kafka
mkdir -p $KAFKA_VOLUME_DIR/config
mkdir -p $KAFKA_VOLUME_DIR/data
#chmod -R 755 $KAFKA_VOLUME_DIR
ls $KAFKA_VOLUME_DIR

docker-compose -f ${FILE_NAME} up -d
docker-compose -f ${FILE_NAME} ps
ls $KAFKA_VOLUME_DIR
docker-compose -f ${FILE_NAME} logs -f kafka
docker-compose -f ${FILE_NAME} logs -f kafka-ui
