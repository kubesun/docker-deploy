#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

cat > compose.yml <<EOF
services:
  kafbat-ui:
    container_name: kafbat-ui
    image: ghcr.io/kafbat/kafka-ui
    ports:
      - 8080:8080
    depends_on:
      - kafka0
    environment:
      DYNAMIC_CONFIG_ENABLED: 'true'
EOF
