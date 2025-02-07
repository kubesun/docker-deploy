#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 8300 TCP协议，用于Consul集群中各个节点相互连结通信的端口
# 8301 TCP或者UDP协议，用于Consul节点之间相互使用Gossip协议健康检查等交互
# 8302 TCP或者UDP协议，用于单个或多个数据中心之间的服务器节点的信息同步
# 8500 HTTP协议，用于API接口或者我们上述的网页管理界面访问
# 8600 TCP或者UDP协议，作为DNS服务器，用于通过节点名查询节点信息
#
# 所以如果是在服务器上面部署，记得配置好防火墙放行上述端口。在Spring Cloud模块集成Consul服务发现时，需要配置8500端口。
# 除此之外，我们来看一下命令最后的几个参数：
#
# agent 表示启动一个Agent进程
# -server 表示该节点类型为Server节点（下面会讲解集群中的节点类型）
# -ui 开启网页可视化管理界面
# -node 指定该节点名称，注意每个节点的名称必须唯一不能重复！上面指定了第一台服务器节点的名称为n1，那么别的节点就得用其它名称
# -bootstrap-expect 最少集群的Server节点数量，少于这个值则集群失效，这个选项必须指定，由于这里是单机部署，因此设定为1即可
# -advertise 这里要指定本节点外网地址，用于在集群时告诉其它节点自己的地址，如果是在自己电脑上或者是内网搭建单节点/集群则不需要带上这个参数
# -client 指定可以外部连接的地址，0.0.0.0表示外网全部可以连接
#
# 除此之外，还可以加上-datacenter参数自定义一个数据中心名，同一个数据中心的节点数据中心名应当指定为一样！
rm -rf /home/docker/consul/data/*

mkdir -p /home/docker/consul/data
mkdir -p /home/docker/consul/config

cat > /home/docker/consul/config/config.json <<EOF
{
  "datacenter": "dc1",
  "acl": {
    "enabled": true,
    "default_policy": "deny",
    "enable_token_persistence": true,
    "tokens": {
      "master": "master-token",
      "agent": "agent-token"
    }
  },
  "server": true,
  "bootstrap_expect": 1,
  "ui": true
}
EOF

docker stop consul
docker rm consul
docker run -itd \
 --name=consul \
 -p 8300:8300 \
 -p 8301:8301 \
 -p 8302:8302 \
 -p 8500:8500 \
 -p 8600:8600 \
 -v /home/docker/consul/data:/consul/data \
 -v /home/docker/consul/config:/consul/config \
 hashicorp/consul agent -server -ui -node=n1 -bootstrap-expect=1 -client=0.0.0.0
docker ps
docker logs -f consul

server:
  http:
    addr: 0.0.0.0:30001
    timeout: 3s
  grpc:
    addr: 0.0.0.0:30002
    timeout: 3s
data:
  database:
    driver: postgres
    source: "postgresql://postgres:msdnmm@node1.apikv.com:5432/ecommence?sslmode=disable&timezone=Asia/Shanghai"
  redis:
    addr: 192.168.3.121:6379
    username: default
    password: msdnmm
    read_timeout: 3.0s
    write_timeout: 3.0s
    dial_timeout: 5s
casdoor:
  certificate: |
    -----BEGIN CERTIFICATE-----
    MIIE2TCCAsGgAwIBAgIDAeJAMA0GCSqGSIb3DQEBCwUAMCYxDjAMBgNVBAoTBWFk
    bWluMRQwEgYDVQQDDAtjZXJ0X3R4ZHEyYzAeFw0yNTAxMzAwNjI4MDlaFw00NTAx
    MzAwNjI4MDlaMCYxDjAMBgNVBAoTBWFkbWluMRQwEgYDVQQDDAtjZXJ0X3R4ZHEy
    YzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANW+/EpX7slndOY1zDEJ
    NktAYPs33Ij9qPGxJrNpkNjYt2ukOaVy/w3RMnLpQoP7tu+2mXKn1+/BqO4eb++8
    /znRQRoMQspLmeDqEMTGmz55zQNVrSb1i1/6reBq/2aBKaSSQB7DwM2vMdQtYl2u
    r3k/mOgJ0rnvoq42fIslnBRLXVg2hjLRB35uPz0ydbFDJwrZfKp9qs3hlXk+KpHH
    cIlbWWN8FEb9Vd5YNK1YSHUgNpx9bW0hfyO1DFG3i/OWq0niB/ZC1yU9UR5Hup+t
    tiG7R/S5jD8QcrWGD3ExpVM+WxgULfJkzk0Sroq+rMfvfm6AK/wHpt6UuFfBSUox
    7YTP4gzoS2lzlmV4c6nz3OSedIaNDso1x7rUpnB6G5EMDxNF+v9w7nKRbZETzg4n
    +cFLqIOnSDGL/KWcNXtHB7IMYoTbes7/+HFYYDdQNqlTrCpeWwuEbpwNS/5Q2SYD
    E3Og7kfJ46YA4QPi3IProqND6tVwLEje7QFpgd3/SbePjs0A1yIqqYrgSeAwr7X8
    8ZmJWAEC4nsUmIUFTDqbsT4vIeWoq9gQ/n234RcoM75vAOUieQKm4o4jP+mtVD9u
    G1tSZmpi55lE79iVQMSJ1oGh/jOM4HrdswA4wLX/k5MwGL0IRnd91Sr2nk0l261G
    BEN8MT9WmWV4o6d78q6kAzU7AgMBAAGjEDAOMAwGA1UdEwEB/wQCMAAwDQYJKoZI
    hvcNAQELBQADggIBAKq7OEvLkKWtleF1H+roDd/Qg6Z9ngN/5ovFT0OOyMsF3fc5
    LzDgHWRYG59/AsI2hdNFbjF1zo+hu3NPgXqlyOnNelWfQgG8SovTbJ1WDFSWAWus
    tOoII2zcVWMVgqwkLIiCGdvQ0szU0IgxdA2qRocLa3maofo/KG2EF+9DlinPWoKZ
    5wyAsTtH8jc7BtmH6M5TYonXp+S9D0k8v/ZzE2zbPkIsyivGBjhjqDR6tAmucREM
    z+6hbVJfLJsHD8Bdd+pOxYcwbCJ6p4Fa2GH5fMoo/leqdAg5Q8kUfY6hRn6jrWP9
    NZm5LSmY3BW3RHcA1ZzOhbdFNh5tV2pFpUBFidXq+woa+I6jTVK3y2bEbKYxP/nN
    5Cle4uLCGgS6r0+BXa/qPG9oOr9zPnObcOqfJltLBV2nj0onm88YwOqi8ucgPwqn
    zy61pUNV+RrSYmASikrjKnU6c+6YeirZ3atgqM1TuJkc8HMQ/dLxptGKCJ1agjIb
    WzJAYALfof+1kfmQb2Bj+DemZTywt6h8gjOXTEByZvwYF0EnIC1BMRpnyzlAUFiO
    2wK+D7YYFCcEkMpql2KaSi7vAb21kzfspVndQQgkBzOHR297wiXiAoMITWslUwUl
    NdIltWymNqg14GpTHUPIPD97HyjIejSybNkpNRjeXKGcgnOxri9dS1bJ18Tv
    -----END CERTIFICATE-----
  server:
    # casdoor url
    endpoint: "http://node1.apikv.com:8000"
    client_id: "58ae47eed5903ca1c3ce"
    client_secret: "d092bd2b51a075fe7a790e01e8a2b1a8176a2d40"
    organization: "tiktok"
    application: "e-commence"

jwt:
  service_key: service_key

registryCenter:
  address: 159.75.231.54:8500 # NodePort 外网可访问的Consul HTTP API地址
  scheme: http
  healthCheck: true

configCenter:
  address: 159.75.231.54:8500

# 可观测性
jaeger:
  service_name: "ecommerce-user-account-v1"
  grpc:
    endpoint: 192.168.3.128:4317
    # endpoint: localhost:4317
  http:
    endpoint: 192.168.3.128:4318
    # endpoint: localhost:4318
