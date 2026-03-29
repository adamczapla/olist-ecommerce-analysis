-- order_payments_clean.sql

CREATE TABLE analytics.order_payments_clean AS
SELECT
    order_id,
    payment_sequential::INT,
    payment_type,
    payment_installments::INT,
    payment_value::NUMERIC(10, 2)
FROM raw.order_payments;