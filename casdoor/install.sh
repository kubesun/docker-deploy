#!/bin/bash

declare host
declare driverName
declare user
declare pass
declare db_port

mkdir -p /home/docker/casdoor
cd /home/docker/casdoor || exit

# https://casdoor.org/zh/docs/basic/try-with-docker/

user="postgres"
pass="postgres"
db_port="5432"
driverName="postgres"
host=$(wget -qO- ifconfig.me)
dbname=casdoor
sslmode=disable
dataSourceName="\"user=${user} password=${pass} host=${host} port=${db_port} sslmode=$sslmode dbname=$dbname\""
echo $host
# https://github.com/casdoor/casdoor/blob/master/conf/app.conf
cat > app.conf <<EOF
appname = casdoor
httpport = 8000
runmode = dev
copyrequestbody = true
driverName = $driverName
dataSourceName = $dataSourceName
dbName = casdoor
tableNamePrefix =
showSql = false
redisEndpoint =
defaultStorageProvider =
isCloudIntranet = false
authState = "casdoor"
socks5Proxy = "127.0.0.1:10808"
verificationCodeTimeout = 10
initScore = 0
logPostOnly = true
isUsernameLowered = false
origin =
originFrontend =
staticBaseUrl = "https://cdn.casbin.org"
isDemoMode = false
batchSize = 100
enableErrorMask = false
enableGzip = true
inactiveTimeoutMinutes =
ldapServerPort = 389
radiusServerPort = 1812
radiusSecret = "secret"
quota = {"organization": -1, "user": -1, "application": -1, "provider": -1}
logConfig = {"filename": "logs/casdoor.log", "maxdays":99999, "perm":"0770"}
initDataNewOnly = false
initDataFile = "./init_data.json"
frontendBaseDir = "../cc_0"
EOF

# 运行Casdoor
docker run \
-itd \
-p 8000:8000 \
-v /home/docker/casdoor/:/conf \
casbin/casdoor:latest
