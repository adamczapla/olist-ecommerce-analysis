-- raw_tables.sql

-- all columns are stored as TEXT (raw ingestion)

-- raw.orders table
-- source: olist_orders_dataset.csv

CREATE TABLE raw.orders
(
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

-- raw.order_items table
-- source: olist_order_items_dataset.csv

CREATE TABLE raw.order_items
(
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

-- raw.products table
-- source: olist_products_dataset.csv

CREATE TABLE raw.products
(
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,
    product_description_lenght TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);

-- raw.customers table
-- source: olist_customers_dataset.csv

CREATE TABLE raw.customers
(
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- raw.order_payments table
-- source: olist_order_payments_dataset.csv

CREATE TABLE raw.order_payments
(
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);
