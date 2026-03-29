-- orders_clean.sql

CREATE TABLE analytics.orders_clean AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::TIMESTAMP(0),
    order_approved_at::TIMESTAMP(0),
    order_delivered_carrier_date::TIMESTAMP(0),
    order_delivered_customer_date::TIMESTAMP(0),
    order_estimated_delivery_date::DATE
FROM raw.orders;