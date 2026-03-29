-- validation.sql

-- Compare row counts between raw and cleaned tables
-- Ensures no rows were lost during casting/cleaning

SELECT 'raw.customers' AS table_name, COUNT(*) AS total_rows
FROM raw.customers
UNION ALL
SELECT 'analytics.customers_clean', COUNT(*)
FROM analytics.customers_clean;

SELECT 'raw.order_payments' AS table_name, COUNT(*) AS total_rows
FROM raw.order_payments
UNION All
SELECT 'analytics.order_payments_clean', COUNT(*)
FROM analytics.order_payments_clean;

SELECT 'raw.order_items' AS table_name, COUNT(*) AS total_rows
FROM raw.order_items
UNION ALL
SELECT 'analytics.order_items_clean', COUNT(*)
FROM analytics.order_items_clean;

SELECT 'raw.products' AS table_name, COUNT(*) AS total_rows
FROM raw.products
UNION ALL
SELECT 'analytics.products_clean', COUNT(*)
FROM analytics.products_clean;

SELECT 'raw.orders' AS table_name, COUNT(*) AS total_rows
FROM raw.orders
UNION ALL
SELECT 'analytics.orders_clean', COUNT(*)
FROM analytics.orders_clean;

-- Check for orders referencing non-existent customers
-- Expected: 0 (every order should have a valid customer_id)

SELECT COUNT(*) AS missing_references
FROM analytics.orders_clean oc
LEFT JOIN analytics.customers_clean cc
    ON oc.customer_id = cc.customer_id
WHERE cc.customer_id IS NULL;

-- Check for order_items referencing non-existent orders
-- Expected: 0 (every order_item should belong to a valid order)

SELECT COUNT(*) AS missing_references
FROM analytics.order_items_clean oic
LEFT JOIN analytics.orders_clean oc
    ON oic.order_id = oc.order_id
WHERE oc.order_id IS NULL;

-- Check for order_payments referencing non-existent orders
-- Expected: 0 (every payment should belong to a valid order)

SELECT COUNT(*) AS missing_references
FROM analytics.order_payments_clean opc
LEFT JOIN analytics.orders_clean oc
    ON opc.order_id = oc.order_id
WHERE oc.order_id IS NULL;

-- Check for order_items referencing non-existent products
-- Expected: 0 (every order_item should reference a valid product)

SELECT COUNT(*) AS missing_references
FROM analytics.order_items_clean oic
LEFT JOIN analytics.products_clean pc
    ON oic.product_id = pc.product_id
WHERE pc.product_id IS NULL;

-- Define primary keys for all cleaned tables
-- Ensures uniqueness and creates indexes for efficient joins

ALTER TABLE analytics.customers_clean
ADD PRIMARY KEY (customer_id);

ALTER TABLE analytics.orders_clean
ADD PRIMARY KEY (order_id);

ALTER TABLE analytics.order_items_clean
ADD PRIMARY KEY (order_id, order_item_id);

ALTER TABLE analytics.products_clean
ADD PRIMARY KEY (product_id);

ALTER TABLE analytics.order_payments_clean
ADD PRIMARY KEY (order_id, payment_sequential);

-- Add foreign key constraints to enforce referential integrity
-- Ensures that relationships between tables are consistent

ALTER TABLE analytics.orders_clean
ADD CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id)
REFERENCES analytics.customers_clean(customer_id);

ALTER TABLE analytics.order_items_clean
ADD CONSTRAINT fk_order_items_order_id FOREIGN KEY (order_id)
REFERENCES analytics.orders_clean(order_id);

ALTER TABLE analytics.order_items_clean
ADD CONSTRAINT fk_order_items_product_id FOREIGN KEY (product_id)
REFERENCES analytics.products_clean(product_id);

ALTER TABLE analytics.order_payments_clean
ADD CONSTRAINT fk_order_payments_order_id FOREIGN KEY (order_id)
REFERENCES analytics.orders_clean(order_id);
