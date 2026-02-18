#!/bin/bash

set -x

export DATA_DIR="/home/docker/postgres"
mkdir -p $DATA_DIR
mkdir -p $DATA_DIR/conf
cd $DATA_DIR || exit

cat >> conf/postgres.conf <<EOF
listen_addresses = '*'
# DB Version: 17
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 8 GB
# CPUs num: 8
# Connections num: 1500
# Data Storage: ssd

max_connections = 300
shared_buffers = 2GB
effective_cache_size = 6GB
maintenance_work_mem = 512MB
checkpoint_completion_target = 0.9
wal_level = logical
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 349kB
huge_pages = off
min_wal_size = 1GB
max_wal_size = 4GB
max_replication_slots = 1
max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
max_parallel_maintenance_workers = 4
EOF

export POSTGRES_USER=user
export POSTGRES_PASSWORD=password
export POSTGRES_DB=root

cat >> compose.yml <<EOF
services:

  postgres:
    container_name: postgres
    image: postgres:18-alpine
    restart: always
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./conf/postgresql.conf:/etc/postgresql/postgresql.conf
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    ports:
      - "5432:5432"
    command:
      - -c
      - 'config_file=/etc/postgresql/postgresql.conf'
volumes:
  postgres_data:
EOF

docker compose up -d

set +x
