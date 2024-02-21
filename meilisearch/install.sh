#!/bin/bash
set -x

mkdir -p /mnt/data/158/getmeili/meilisearch/meili_data

docker run -it --rm \
    -p 7700:7700 \
    -e MEILI_ENV='development' \
    -v /mnt/data/158/getmeili/meilisearch/meili_data:/meili_data \
    getmeili/meilisearch:v1.6

set +x
