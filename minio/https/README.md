# TLS

1. 在minio目录下创建一个目录用于存储tls文件
    ```shell
    mkdir -p /home/docker/minio/tls
    ```
2. 将nginx类型的SSL文件,例如: .cer, .crt 重命名并存放到刚刚创建的tls目录
    ```shell
    cd /home/docker/minio/tls
    
    cp /home/docker/nginx/ssl/nginx.crt .
    cp /home/docker/nginx/ssl/nginx.key .
    ```

3. 重启minio服务
    ```shell
    docker compose restart
    ```
