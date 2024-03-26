#!/usr/bin/env bash

# https://mmxblog.com/p-3059/Mmx.html
# https://cloud.tencent.com/developer/article/1990829

mkdir -pv /home/acme
cd /home/acme || exit

apt install -y socat

git clone --depth 1 https://github.com/acmesh-official/acme.sh.git

mkdir -pv /home/acme/certs

./acme.sh --install -m my@example.com

acme.sh -v

# 重新更换默认服务商为ZeroSSL
acme.sh --set-default-ca --server zerossl

# 配置DNS API
# SSL证书验证可通过DNS验证、文件验证等多种方式，为了方便多个域名申请以及后续证书更新，推荐使用DNS API方式，不过在使用前需要先进行设置。 如果使用的DNSPOD（国内版），命令为
# 腾讯云: https://console.dnspod.cn/account/token/token
export DP_Id="485361"
export DP_Key="64e5d10b69287fba0ebb38f1fde20e40"

# acme.sh部署完成后我们来申请ZeroSSL泛域名SSL证书，需要先关联账户，执行下面的命令会自动关联账户，命令如下（admin@imotao.com改成你自己的ZeroSSL邮箱，即使没注册，运行命令之后也会自动注册的）：
acme.sh --register-account -m admin@xicon.com --server zerossl

# 泛域名
# acme.sh --issue --dns dns_dp -d *.lookeke.com -d lookeke.com

# 多级域名
acme.sh --issue \
-d lookeke.com --dns dns_dp lookeke.com \
-d lookeke.cn --dns dns_dp lookeke.cn \
-d lookeke.cc --dns dns_dp lookeke.cc \
-d lookeke.top --dns dns_dp lookeke.top

# 复制到Nginx
mkdir -p /usr/local/nginx/ssl/lookeke.com
acme.sh --installcert -d *.lookeke.com \
        --key-file /usr/local/nginx/ssl/lookeke.com/*.lookeke.com.key \
        --fullchain-file /usr/local/nginx/ssl/lookeke.com/fullchain.cer \
        --reloadcmd "/usr/local/nginx/sbin/nginx -s reload"

ls /usr/local/nginx/ssl/
