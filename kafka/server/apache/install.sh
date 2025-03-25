#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 定义域名
kafka_host="99.suyiiyii.top"

# 节点1-Controller
docker run -id --name=kafka-1 \
	-p 10001:9093 \
	-v kafka-config-1:/mnt/shared/config \
	-v kafka-data-1:/var/lib/kafka/data \
	-v kafka-secret-1:/etc/kafka/secrets \
	-e LANG=C.UTF-8 \
	-e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
	-e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
	-e CLUSTER_ID=the-custom-id \
	-e KAFKA_NODE_ID=1 \
	-e KAFKA_PROCESS_ROLES=controller \
	-e KAFKA_CONTROLLER_QUORUM_VOTERS="1@$kafka_host:10001" \
	-e KAFKA_LISTENERS="CONTROLLER://:9093" \
	apache/kafka

# 节点2-Broker
docker run -id --name=kafka-2 \
	-p 9002:9092 \
	-v kafka-config-2:/mnt/shared/config \
	-v kafka-data-2:/var/lib/kafka/data \
	-v kafka-secret-2:/etc/kafka/secrets \
	-e LANG=C.UTF-8 \
	-e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
	-e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
	-e CLUSTER_ID=the-custom-id \
	-e KAFKA_NODE_ID=2 \
	-e KAFKA_PROCESS_ROLES=broker \
	-e KAFKA_CONTROLLER_QUORUM_VOTERS="1@$kafka_host:10001" \
	-e KAFKA_LISTENERS="PLAINTEXT://:9092" \
	-e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://$kafka_host:9002" \
	apache/kafka

# 节点3-Broker
docker run -id --name=kafka-3 \
	-p 9003:9092 \
	-v kafka-config-3:/mnt/shared/config \
	-v kafka-data-3:/var/lib/kafka/data \
	-v kafka-secret-3:/etc/kafka/secrets \
	-e LANG=C.UTF-8 \
	-e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
	-e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
	-e CLUSTER_ID=the-custom-id \
	-e KAFKA_NODE_ID=3 \
	-e KAFKA_PROCESS_ROLES=broker \
	-e KAFKA_CONTROLLER_QUORUM_VOTERS="1@$kafka_host:10001" \
	-e KAFKA_LISTENERS="PLAINTEXT://:9092" \
	-e KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://$kafka_host:9003" \
	apache/kafka
