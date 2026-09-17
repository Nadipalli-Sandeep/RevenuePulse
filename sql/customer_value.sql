DROP TABLE IF EXISTS analytics.customer_value;

CREATE TABLE analytics.customer_value AS
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.is_delivered,
        o.is_late,
        o.is_cancelled,
        o.is_unavailable,
        COALESCE(SUM(i.item_total_value), 0) AS order_value
    FROM analytics.dim_customers c
    JOIN analytics.fact_orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN analytics.fact_order_items i
        ON o.order_id = i.order_id
    GROUP BY
        c.customer_unique_id,
        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.is_delivered,
        o.is_late,
        o.is_cancelled,
        o.is_unavailable
),

rfm_base AS (
    SELECT
        customer_unique_id,

        MAX(order_purchase_timestamp) AS last_order_date,

        COUNT(DISTINCT order_id) AS frequency,

        ROUND(SUM(order_value)::numeric, 2) AS monetary,

        ROUND(AVG(order_value)::numeric, 2) AS avg_order_value,

        SUM(is_delivered) AS delivered_orders,

        SUM(is_late) AS late_orders,

        SUM(is_cancelled) AS cancelled_orders,

        SUM(is_unavailable) AS unavailable_orders,

        MIN(order_purchase_timestamp) AS first_order_date

    FROM customer_orders
    GROUP BY customer_unique_id
),

rfm_scores AS (
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY last_order_date DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM rfm_base
),

segmented AS (
    SELECT
        *,

        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 4
             AND frequency_score >= 3
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
             AND monetary_score >= 3
                THEN 'High Potential'

            WHEN recency_score <= 2
             AND frequency_score >= 4
                THEN 'At Risk - Valuable'

            WHEN recency_score <= 2
             AND monetary_score >= 4
                THEN 'At Risk - High Value'

            WHEN recency_score <= 2
                THEN 'Hibernating'

            WHEN recency_score >= 4
                THEN 'Recent Customers'

            ELSE 'Needs Attention'
        END AS customer_segment

    FROM rfm_scores
)

SELECT
    *,
    (recency_score + frequency_score + monetary_score) AS rfm_score,

    ROUND(
        EXTRACT(
            EPOCH FROM (last_order_date - first_order_date)
        ) / 86400.0,
        2
    ) AS customer_lifetime_days,

    ROUND(
        100.0 * late_orders / NULLIF(delivered_orders, 0),
        2
    ) AS late_order_rate_pct

FROM segmented;

CREATE INDEX idx_customer_value_segment
    ON analytics.customer_value(customer_segment);

CREATE INDEX idx_customer_value_rfm
    ON analytics.customer_value(rfm_score);

CREATE INDEX idx_customer_value_customer
    ON analytics.customer_value(customer_unique_id);

ANALYZE analytics.customer_value;
