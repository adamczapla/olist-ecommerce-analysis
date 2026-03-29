-- products_clean.sql

CREATE TABLE analytics.products_clean AS
SELECT
    product_id,
    product_category_name,
    product_name_lenght::INT AS product_name_length,
    product_description_lenght::INT AS product_description_length,
    product_photos_qty::INT,
    product_weight_g::INT,
    product_length_cm::INT,
    product_height_cm::INT,
    product_width_cm::INT
FROM raw.products;