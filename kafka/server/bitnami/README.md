# Kafka

## 说明
使用的kafka的服务端部署是bitnami/kafka

## 服务端部署
1. 修改`install.sh`的`KAFKA_HOST`参数为你的IP或当前机器的域名
2. 修改`install.sh`的`KAFKA_UI_PORT`参数为任意端口, 默认为`9081`
3. 修改`install.sh`的`KAFKA_BROKER_PORT`参数为任意端口, 默认为`9092`, 一般不需要修改
4. 修改`install.sh`的`KAFKA_VOLUME_DIR`参数为Kafka的数据目录. 手动创建, 例如`/mnt/data/158/docker/bitnami`

执行部署
```shell
chmod +x ./install.sh
./install.sh
```
