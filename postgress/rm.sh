#!/bin/bash

docker stop postgres
docker rm postgres
rm -rf "$DATA_DIR"
