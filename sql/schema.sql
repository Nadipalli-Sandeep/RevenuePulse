CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS staging.customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE IF NOT EXISTS staging.orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.order_items (
    order_id TEXT NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id TEXT NOT NULL,
    seller_id TEXT NOT NULL,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE IF NOT EXISTS staging.order_payments (
    order_id TEXT NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(12,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE IF NOT EXISTS staging.order_reviews (
    review_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE IF NOT EXISTS staging.sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE IF NOT EXISTS staging.category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);
