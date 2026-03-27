-- load_data.sql

-- Data ingestion script
-- Loads raw Olist CSV files from data/raw/ into the raw schema
-- All raw table columns are stored as TEXT for lossless ingestion

\COPY raw.orders FROM 'data/raw/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY raw.order_items FROM 'data/raw/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY raw.order_payments FROM 'data/raw/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY raw.customers FROM 'data/raw/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY raw.products FROM 'data/raw/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;

SELECT 'raw.orders' AS table_name, COUNT(*) AS row_count FROM raw.orders
UNION ALL
SELECT 'raw.order_items' AS table_name, COUNT(*) AS row_count FROM raw.order_items
UNION ALL
SELECT 'raw.order_payments' AS table_name, COUNT(*) AS row_count FROM raw.order_payments
UNION ALL
SELECT 'raw.customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL
SELECT 'raw.products' AS table_name, COUNT(*) AS row_count FROM raw.products;

