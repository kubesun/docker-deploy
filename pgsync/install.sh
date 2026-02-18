#!/bin/bash
set -x

# sql
CREATE DATABASE book;
CREATE SCHEMA my_book_library;
DROP TABLE my_book_library.book;
CREATE TABLE my_book_library.book(
    id serial primary key,
    isbn varchar(255),
    title varchar(255)
);
# 插入 15 条示例书籍数据
INSERT INTO my_book_library.book (isbn, title) VALUES
('978-0321765723', 'The Lord of the Rings'),
('978-1449302634', 'The Hobbit'),
('978-0743273565', 'The Great Gatsby'),
('978-0061120084', 'To Kill a Mockingbird'),
('978-0062315007', 'The Catcher in the Rye'),
('978-0451524935', '1984'),
('978-0141439518', 'Pride and Prejudice'),
('978-0307593259', 'The Girl with the Dragon Tattoo'),
('978-0385537854', 'Gone Girl'),
('978-0345339617', 'The Hitchhiker''s Guide to the Galaxy'),
('978-0735211293', 'Educated: A Memoir'),
('978-1501142971', 'The Silent Patient'),
('978-0060935342', 'One Hundred Years of Solitude'),
('978-0307277773', 'The Road'),
('978-1984801990', 'Where the Crawdads Sing');

cat >> schema.json <<EOF
[
  {
    "database": "book",
    "index": "book_index",
    "setting": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "nodes": {
      "table": "book",
      "schema": "my_book_library",
      "columns": [
        "id",
        "isbn",
        "title"
      ],
      "transform": {
        "mapping": {
          "isbn": {
            "type": "keyword"
          },
          "title": {
            "type": "text",
            "analyzer": "standard"
          }
        }
      }
    }
  }
]
EOF

# REDIS_HOST=<redis_host_address>
# PG_URL=postgres://<username>:<password>@<postgres_host>/<database>
# ELASTICSEARCH_URL=http://<elasticsearch_host>:9200
export REDIS_HOST="apikv.com"
export REDIS_DB="14"
export REDIS_USER="default"
export REDIS_AUTH="msdnmm"
export PG_USER=root
export PG_HOST=apikv.com
export PG_PORT=5432
export PG_PASSWORD=msdnmm
export ELASTICSEARCH_URL="http://apikv.com:9200"
export POLL_TIMEOUT=20
export REDIS_POLL_INTERVAL=20
export LOG_INTERVAL=20
export REPLICATION_SLOT_CLEANUP_INTERVAL=180

docker run --rm -it \
-e REDIS_CHECKPOINT=true \
-e REDIS_HOST=$REDIS_HOST \
-e REDIS_DB=$REDIS_DB \
-e REDIS_USER=$REDIS_USER \
-e REDIS_AUTH=$REDIS_AUTH \
-e PG_USER=$PG_USER \
-e PG_HOST=$PG_HOST \
-e PG_PORT=$PG_PORT \
-e PG_PASSWORD=$PG_PASSWORD \
-e ELASTICSEARCH_URL=$ELASTICSEARCH_URL \
-e POLL_TIMEOUT=$POLL_TIMEOUT \
-e REDIS_POLL_INTERVAL=$REDIS_POLL_INTERVAL \
-e LOG_INTERVAL=$LOG_INTERVAL \
-e REPLICATION_SLOT_CLEANUP_INTERVAL=$REPLICATION_SLOT_CLEANUP_INTERVAL \
-v "./schema.json:/app/schema.json" \
toluaina1/pgsync:latest -c schema.json -d -b

set +x
