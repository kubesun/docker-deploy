# Kafka Golang Client

## 注意事项
1. 本项目是没有安全认证, 仅适合快速部署开发, 对需要安全的环境请添加安全相关的参数

## 使用
1. 修改`client.properties`的`bootstrap.servers`为你的kafka的URL, 例如`127.0.0.1:9092`
2. 编译生产者: 
    ```shell
    go build -o out/producer util.go producer.go
    ```
3. 编译消费者
    ```shell
    go build -o out/consumer util.go consumer.go
    ```

### 生产消息 
```shell
./out/producer ./client.properties
```

### 消费消息
```shell
./out/consumer ./client.properties
```

## 参考
1. [go客户端](https://developer.confluent.io/get-started/go)
2. [安全](https://kafka.apache.org/documentation/#security)
