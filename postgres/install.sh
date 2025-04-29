#!/bin/bash

set -x

export DATA_DIR="/home/docker/postgres/data"
mkdir -p $DATA_DIR
chmod -R 777 $DATA_DIR
docker run \
-d \
--restart=always \
--name postgres \
-v $DATA_DIR:/var/lib/postgresql/data \
-e POSTGRES_USER="root" \
-e POSTGRES_PASSWORD="msdnmm" \
-e POSTGRES_DB=postgres \
-p 0.0.0.0:5432:5432 \
postgres:17.2-alpine3.21

set +x
