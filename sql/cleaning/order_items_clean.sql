-- order_items_clean.sql

CREATE TABLE analytics.order_items_clean AS
SELECT
    order_id,
    order_item_id::INT,
    product_id,
    seller_id,
    shipping_limit_date::TIMESTAMP(0),
    price::NUMERIC(10, 2),
    freight_value::NUMERIC(10, 2)
FROM raw.order_items;