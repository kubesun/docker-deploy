#!/bin/bash

set -xeu

docker build -f Dockerfile --no-cache -t otel-gin .

docker-compose up -d

curl localhost:30001:/

set +x
