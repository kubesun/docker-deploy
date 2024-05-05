#!/bin/bash

declare host
declare driverName
declare user
declare pass
declare db_port

mkdir -p /home/casdoor
cd /home/casdoor || exit

# https://casdoor.org/zh/docs/basic/try-with-docker/

user="root"
pass="msdnmm"
db_port="5432"
# 必须提供一个数据库和表存储用户数据, 这里是Postgres数据库和casdoor表,安装如下, 安装完成之后自行创建casdoor表
# export DATA_DIR="/home/postgres/data"
# mkdir -p $DATA_DIR
# chmod -R 777 $DATA_DIR
# docker run \
# --name postgres \
# -d \
# --restart=always \
# -v $DATA_DIR:/var/lib/postgresql/data \
# -e POSTGRES_USER=${user} \
# -e POSTGRES_PASSWORD=${pass} \
# -e POSTGRES_DB=postgres \
# -p 0.0.0.0:${db_port}:5432 \
# postgres

# 创建casdoor表:
# DO $$
# BEGIN
#     IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'casdoor') THEN
#         CREATE DATABASE casdoor;
#     END IF;
# END $$;

# 修改app.conf: https://github.com/casdoor/casdoor/blob/master/conf/app.conf
# export host="192.168.2.158"
driverName="postgres"
host=$(wget -qO- ifconfig.me)
dataSourceName="user=${user} password=${pass} host=${host} port=${db_port} sslmode=disable dbname=casdoor"
cat > app.conf <<EOF
appname = casdoor
httpport = 8000
runmode = dev
copyrequestbody = true
driverName = ${driverName}
dataSourceName = ${dataSourceName}
dbName = casdoor
EOF

# 运行Casdoor
docker run \
-itd \
-p 8000:8000 \
-v /home/casdoor/:/conf \
casbin/casdoor:latest
