CREATE SCHEMA IF NOT EXISTS analytics;

DROP TABLE IF EXISTS analytics.fact_order_items CASCADE;
DROP TABLE IF EXISTS analytics.fact_orders CASCADE;
DROP TABLE IF EXISTS analytics.dim_customers CASCADE;
DROP TABLE IF EXISTS analytics.dim_products CASCADE;
DROP TABLE IF EXISTS analytics.dim_sellers CASCADE;

CREATE TABLE analytics.dim_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM staging.customers;

CREATE TABLE analytics.dim_products AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM staging.products p
LEFT JOIN staging.category_translation t
    ON p.product_category_name = t.product_category_name;

CREATE TABLE analytics.dim_sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    INITCAP(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM staging.sellers;

CREATE TABLE analytics.fact_orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN EXTRACT(
            EPOCH FROM (
                o.order_delivered_customer_date
                - o.order_purchase_timestamp
            )
        ) / 86400.0
    END AS delivery_days,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late,

    CASE
        WHEN o.order_status = 'delivered' THEN 1
        ELSE 0
    END AS is_delivered,

    CASE
        WHEN o.order_status = 'canceled' THEN 1
        ELSE 0
    END AS is_cancelled,

    CASE
        WHEN o.order_status = 'unavailable' THEN 1
        ELSE 0
    END AS is_unavailable

FROM staging.orders o;

CREATE TABLE analytics.fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_total_value
FROM staging.order_items oi;

CREATE INDEX idx_fact_orders_customer
    ON analytics.fact_orders(customer_id);

CREATE INDEX idx_fact_orders_purchase
    ON analytics.fact_orders(order_purchase_timestamp);

CREATE INDEX idx_fact_items_order
    ON analytics.fact_order_items(order_id);

CREATE INDEX idx_fact_items_product
    ON analytics.fact_order_items(product_id);

CREATE INDEX idx_fact_items_seller
    ON analytics.fact_order_items(seller_id);

CREATE INDEX idx_customers_unique
    ON analytics.dim_customers(customer_unique_id);

ANALYZE analytics.dim_customers;
ANALYZE analytics.dim_products;
ANALYZE analytics.dim_sellers;
ANALYZE analytics.fact_orders;
ANALYZE analytics.fact_order_items;
