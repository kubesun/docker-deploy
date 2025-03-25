# Minio 开发自签TLS

## 生成证书和
```shell
 ./gen.sh
```

## 启动
```shell
mkdir -p /home/docker/minio/data
mkdir -p /home/docker/minio/tls

mv ./* /home/docker/minio

docker compose up -d
```
