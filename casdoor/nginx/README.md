# 配置 Casdoor 为 HTTPS

## 使用 NGINX
1. 创建目录和编写变量
2. 编写 compose.yml, 定义 NGINX 和 Casdoor 的服务, 让它们处在同一个子网
3. 使用 NGINX 作为 HTTPS 基底, 处理 HTTPS 请求, 转发到 HTTP 的Cadoor后端, 这里使用了自定义的 QUIC+HTTP/3 协议的自定义 NGINX 镜像, 也可以使用官方的 NGINX镜像, 但nginx.conf 的配置内容需要自行修改
4. 定制 nginx.conf, 条件充裕情况下, 直接把8081替换成 443 端口
5. 定义 Casdoor 的配置文件 app.conf

```bash
chmod +x ./start.sh
./start.sh
```
