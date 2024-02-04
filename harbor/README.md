# Docker 部署 harbor

## 快速入门
推荐修改的参数:
1. HOSTNAME: IP或者当前服务器的域名

```shell
export HOSTNAME="192.168.2.101"
```

### 安装
```shell
sed -i "s/hostname: 192.168.2.101/hostname: $HOSTNAME/" ./harbor.yml
cat -n ./harbor.yml | grep hostname

./install.sh
```

查看安装结果
```shell
docker ps
```

### 访问Web
- 浏览器访问:
输入你定义的`$HOSTNAME`加上`:5443/harbor`, 例如`https://192.168.2.101:5443/harbor`

- 使用命令行:
```shell
curl --insecure https://$HOSTNAME:5443/harbor
```

## 自定义
为了安全性, 建议定义以下必须的参数:
1. HOSTNAME: IP或者当前服务器的域名
2. HTTP_PORT: harbor的http端口. 默认是80, 建议使用其他端口, 例如31280
3. HTTPS_PORT, harbor的https端口. 默认是443, 建议使用其他端口, 例如31443
4. CERTIFICATE: crt证书路径, 例如`/home/harbor/harbor/harbor.crt`, 本教程使用openSSL创建自签名证书,如果有公网证书, 替换即可
5. PRIVATE_KEY: key证书路径, 例如`/home/harbor/harbor/harbor.key`, 本教程使用openSSL创建自签名证书,如果有公网证书, 替换即可
6. HARBOR_ADMIN: WebUI的账号, 默认是`admin`
7. HARBOR_ADMIN_PASSWORD: WebUI的密码, 默认是`Harbor12345`
```shell
export HOSTNAME="192.168.2.101"
export HTTP_PORT="31280"
export HTTPS_PORT="31443"
export CERTIFICATE="/home/harbor/harbor/harbor.crt"
export PRIVATE_KEY="/home/harbor/harbor/harbor.key"
export HARBOR_ADMIN="admin"
export HARBOR_ADMIN_PASSWORD="Harbor12345"

## 测试
1. 测试打包: 进入examples/gin目录,执行start.sh
2. 测试推送: 
```
