CREATE DATABASE ecommerce;
CREATE SCHEMA product;
SET search_path to product;

CREATE TYPE product_status AS ENUM (
    'draft',-- 草稿
    'pending_review', -- 待审核
    'active', -- 上架
    'inactive', -- 下架
    'deleted' -- 删除，进入回收站，无法搜索，30天后物理删除
    );

-- 商品表
CREATE TABLE product.products
(
    id            bigserial primary key,
    name          varchar(255)   not null,
    description   text, -- 商品描述
    price         decimal(10, 2) not null,
    status        product_status not null default 'draft',
    merchant_id   uuid           not null,
    category_id   int            not null,
    category_name VARCHAR(100)   not null,
    cover_image   text           not null,
    attributes    jsonb          not null default '{}',
    sales_count   int            not null default 0,
    rating_score  decimal(2, 1)  not null default 0.0,
    created_at    timestamptz    not null default now(),
    updated_at    timestamptz    not null default now(),
    deleted_at    timestamptz    not null default now()
);

-- 商品图片表
CREATE TABLE product.images
(
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT       NOT NULL REFERENCES product.products (id) ON DELETE CASCADE,
    url        VARCHAR(500) NOT NULL,
    type       VARCHAR(20)  NOT NULL DEFAULT 'detail', -- cover/detail
    sort_order INTEGER               DEFAULT 0,
    alt_text   TEXT,
    created_at TIMESTAMPTZ           DEFAULT NOW(),

    -- 约束和索引
    UNIQUE (product_id, sort_order),
    CHECK (type IN ('cover', 'detail'))
);
