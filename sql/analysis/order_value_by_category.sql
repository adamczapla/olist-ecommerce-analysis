-- order_value_by_category.sql

-- Analyze how product categories relate to order value and presence in high-value orders
-- Excludes orders with missing category assignments (NULL categories)

WITH order_category_base AS
(
    -- Build base at grain: order_id + category
    -- Attach full order_value to each order-category pair

    SELECT DISTINCT
        oic.order_id
        ,pc.product_category_name AS category
        ,SUM(oic.price + oic.freight_value) OVER (PARTITION BY order_id) order_value
    FROM analytics.order_items_clean oic
    INNER JOIN analytics.products_clean pc
        ON oic.product_id = pc.product_id
            AND pc.product_category_name IS NOT NULL
),
order_category_stats AS
(
    -- Compute core distribution metrics per category
    -- AVG: sensitive to outliers
    -- Median: robust typical order value

    SELECT
        category
        ,ROUND(AVG(order_value)::NUMERIC, 2) AS average_order_value
        ,ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_value)::NUMERIC, 2) AS median_order_value
    FROM order_category_base
    GROUP BY 1
),

-- Order value characteristics per category
-- (average, median, and skew via AVG-Median gap)

category_order_value_stats AS
(
    -- Derive gap between AVG and Median to measure skew / outlier impact

    SELECT
        category
        ,average_order_value
        ,median_order_value
        ,ROUND(average_order_value - median_order_value, 2) AS avg_median_gap
    FROM order_category_stats
),
order_value_base AS
(
    -- Build pure order-level dataset (1 row per order_id)
    -- Required for correct global percentile calculation

    SELECT
        order_id
        ,SUM(price + freight_value) order_value
    FROM analytics.order_items_clean
    GROUP BY 1
),
global_order_value_threshold AS
(
    -- Compute global P75 threshold across all orders
    -- Defines what is considered a "high-value" order

    SELECT
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY order_value) AS order_value_threshold
    FROM order_value_base
),
high_value_indicator_base AS
(
    -- Build order_id + category pairs
    -- Attach binary indicator: 1 if order is high-value, else 0

    SELECT DISTINCT
        ovb.order_id
        ,pc.product_category_name AS category
        ,CASE
            WHEN ovb.order_value >= govt.order_value_threshold THEN 1 ELSE 0
        END AS high_value_indicator
    FROM global_order_value_threshold AS govt
    CROSS JOIN order_value_base AS ovb
    INNER JOIN analytics.order_items_clean AS oic
        ON ovb.order_id = oic.order_id
    INNER JOIN analytics.products_clean pc
        ON oic.product_id = pc.product_id
    WHERE pc.product_category_name IS NOT NULL
),

-- High-value order share per category
-- (based on global P75 threshold)

category_high_value_stats AS
(
    -- Aggregate high-value behavior per category
    -- total_orders: number of orders containing the category
    -- high_value_orders: number of those orders classified as high-value
    -- ratio: share of high-value orders within the category

    SELECT
        category
        ,COUNT(*) AS total_orders
        ,SUM(high_value_indicator) AS high_value_orders
        ,ROUND(SUM(high_value_indicator)::NUMERIC / COUNT(*), 2)  AS high_value_order_ratio
    FROM high_value_indicator_base
    GROUP BY 1
)

-- Final combined view
-- Merge order value characteristics with high-value behavior per category

SELECT
    covs.category
    ,chvs.total_orders
    ,covs.average_order_value
    ,covs.median_order_value
    ,covs.avg_median_gap
    ,chvs.high_value_order_ratio
FROM category_order_value_stats AS covs
INNER JOIN category_high_value_stats AS chvs
    ON covs.category = chvs.category
-- Filter out categories with insufficient sample size for reliable interpretation
WHERE chvs.total_orders > 30
ORDER BY 6 DESC;