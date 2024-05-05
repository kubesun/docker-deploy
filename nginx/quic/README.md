## 说明

1. 本库意为快速搭建 `NGINX`的`QUIC` + `HTTP3`, 配置方便
2. 脚本安全, 不会保存你的任何数据
3. 开源, 任何人都可以查看代码

## 原理

1. 使用别人通过Linux发行版的打包用于QUIC编译的NGINX二进制文件和它用于QUIC+HTTP3的配置, 然后发行到Docker之类的容器注册表
2. 利用别人封装好的容器, 然后再注入自己的配置

## 快速入门

> !确保/home/nginx目录没有重要文件, 默认使用该目录

1. 定义你的域名`DOMAIN`, 例如`example.com`, 不要加前缀!, 脚本已自动加
   示例:
   ```shell
   export DOMAIN="example.com"
   ```

2. 定义`WEB_DIR`目录, 默认是`/home/web`, 该目录是前端静态文件, 只能是原生的js, html, css, 是框架(如果有)编译后的文件
   示例:
   ```shell
   export WEB_DIR="/home/web"
   ```

3. 上传ssl文件, 把`nginx.crt`PEM证书与`nginx.key`证书密钥文件到`/home/nginx/ssl`目录下, 确保只有一个文件后缀,
   不能同时存在两个或多个`.crt`或者`.key`文件, 会导致nginx识别文件出现问题

4. 执行脚本

```shell
sudo chmod +x ./config.sh
sudo ./config.sh
```

## 自定义

当你熟悉之后, 可以自定义了, 这是变量列表:

- WEB_DIR: web目录
- NGINX_DIR: NGINX的目录, 推荐用于保存配置文件与SSL文件
- CONF_DIR: NGINX的配置文件目录, 一般定义在NGINX的目录的目录下
- SSL_DIR: NGINX的SSL文件目录, 一般定义在NGINX的目录的目录下

默认值:

```shell
WEB_DIR="/home/web"
NGINX_DIR="/home/nginx"
CONF_DIR="/home/nginx/conf"
SSL_DIR="/home/nginx/ssl"
```
