#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

docker pull otel/opentelemetry-collector-contrib:latest

rm -rf /home/docker/opentelemetry/*
rm -rf /home/docker/opentelemetry/data/*
rm -rf /home/docker/opentelemetry/conf/*

docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml down || true

mkdir -pv /home/docker/opentelemetry
mkdir -pv /home/docker/opentelemetry/data
mkdir -pv /home/docker/opentelemetry/conf

chmod 600 /home/docker/opentelemetry
chmod 600 /home/docker/opentelemetry/data
chmod 600 /home/docker/opentelemetry/conf

cd /home/docker/opentelemetry || exit

# https://opentelemetry.io/zh/docs/collector/configuration
cat > /home/docker/opentelemetry/conf/otel-collector.yaml <<EOF
# 接收器
# 在启动otel-collector的服务器上所要接收的遥测数据
# 例如: otlp, kafka, opencensus, zipkin
receivers:
  # 收集otlp协议
  otlp:
    protocols:
      # 在本机启动grpc收集器, 收集使用gRPC传输的遥测数据
      grpc:
      #   endpoint: localhost:4317
      # 在本机启动http收集器, 收集json类型的遥测数据
      http:
      #   endpoint: localhost:4318

# 处理器
# 将收集到的遥测数据进行处理
# 例如: 过滤, 更新, 添加指标
processors:
  probabilistic_sampler:
    hash_seed: 22
    sampling_percentage: 100
  batch:
    timeout: 100ms

# 导出器
# 要导出到的后端服务URL
# 例如Jaeger, Prometheus, Loki
exporters:
  otlp/jaeger:
    #endpoint: 159.75.231.54:4317
    endpoint: 8.141.10.44:4317
    tls:
      # 是否使用不安全的连接, 即HTTP明文传输
      insecure: true
      # TLS证书:
      #cert_file: cert.pem
      #key_file: cert-key.pem

#  扩展器
# 扩展器是可选组件，用于扩展收集器的功能，以完成与处理遥测数据不直接相关的任务。
# 例如，您可以添加用于收集器运行状况监控、服务发现或数据转发等的扩展。
extensions:
  health_check:
  pprof:
  zpages:
  memory_ballast:
    size_mib: 512

# 服务
# https://opentelemetry.io/zh/docs/collector/configuration/#service
# 该 service 部分用于根据接收器、处理器、导出器和扩展部分中的配置配置在收集器中启用的组件。
# 如果配置了组件，但未在 service 该部分中定义，则不会启用该组件
service:
  extensions: [ health_check, pprof, zpages, memory_ballast ]
  pipelines:
    traces:
      receivers: [ otlp ]
      processors: [ probabilistic_sampler, batch ]
      exporters: [ otlp/jaeger ]
#    metrics:
#      receivers: [ ]
#      processors: [ ]
#      #exporters: [ ]
#      exporters: [ ]
#    logs:
#      receivers: [ ]
#      processors: [ ]
#      #exporters: [ ]
#      exporters: [ ]

EOF

cat > /home/docker/opentelemetry/opentelemetry-collector-compose.yml <<EOF
services:
  otel-collector:
    command:
      - --config
      - /otel-config.yaml
    #image: otel/opentelemetry-collector-contrib:0.102.1
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    volumes:
      - /home/docker/opentelemetry/conf/otel-collector.yaml:/otel-config.yaml
    ports:
      - 0.0.0.0:1888:1888 # pprof extension
      - 0.0.0.0:8888:8888 # Prometheus metrics exposed by the Collector
      - 0.0.0.0:8889:8889 # Prometheus exporter metrics
      - 0.0.0.0:13133:13133 # health_check extension
      - 0.0.0.0:4317:4317 # OTLP gRPC receiver
      - 0.0.0.0:4318:4318 # OTLP http receiver
      - 0.0.0.0:55679:55679 # zpages extension
EOF

docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml up -d
docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml logs -f
