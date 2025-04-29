# Minio 开发自签TLS

## 生成证书
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

## 在浏览器或者系统级别信任目录下的 CA 和 TLS 证书

## 参考
https://min.io/docs/minio/container/operations/network-encryption.html#self-signed-internal-private-certificates-and-public-cas-with-intermediate-certificates
