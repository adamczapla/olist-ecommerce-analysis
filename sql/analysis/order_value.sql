-- order_value.sql

-- Analyze how average order value changes with item count
-- Only include item counts with at least 100 orders
-- to avoid unstable results in very small groups

WITH order_item_base AS (
    SELECT
        order_id
         ,COUNT(order_item_id) AS item_count
         ,SUM(price + freight_value) AS order_value
    FROM analytics.order_items_clean
    GROUP BY 1
)
SELECT
    item_count
     ,COUNT(*) order_count
     ,ROUND(AVG(order_value), 2) AS avg_order_value
FROM order_item_base
GROUP BY 1
HAVING count(*) >= 100
ORDER BY 1;

-- Reverse the perspective:
-- segment orders by order value and examine
-- how item count changes across value segments
-- This checks whether high-value orders
-- actually contain more items

WITH order_item_base AS
(
    SELECT
        order_id
        ,COUNT(order_item_id) AS item_count
        ,SUM(price + freight_value) AS order_value
    FROM analytics.order_items_clean
    GROUP BY 1
),
order_segments AS
(
    SELECT
        order_id
        ,item_count
        ,order_value
        ,NTILE(4) OVER (ORDER BY order_value) AS value_segment
    FROM order_item_base
)
SELECT
    value_segment
    ,COUNT(*) AS order_count
    ,ROUND(AVG(order_value), 2) AS avg_order_value
    ,ROUND(AVG(item_count), 2) AS avg_item_count
FROM order_segments
GROUP BY 1
ORDER BY 1;

-- Break down order value into its components
-- across order value segments:
-- product value, freight value, and price per item
-- This helps identify what actually drives
-- higher order values

WITH order_item_base AS
(
    SELECT
        order_id
        ,COUNT(order_item_id) AS item_count
        ,SUM(price + freight_value) AS order_value
        ,SUM(price) AS total_price
        ,SUM(freight_value) AS total_freight
    FROM analytics.order_items_clean
    GROUP BY 1
),
order_segments AS
(
    SELECT
        order_id
        ,item_count
        ,order_value
        ,total_price
        ,total_freight
        ,NTILE(4) OVER (ORDER BY order_value) AS value_segment
    FROM order_item_base
)
SELECT
    value_segment
    ,ROUND(AVG(order_value), 2) AS avg_order_value
    ,ROUND(AVG(total_price), 2) AS avg_product_value
    ,ROUND(AVG(total_freight), 2) AS avg_freight_value
    ,ROUND(AVG(total_price / item_count), 2) AS avg_price_per_item
FROM order_segments
GROUP BY 1
ORDER BY 1;