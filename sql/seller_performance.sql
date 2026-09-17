DROP TABLE IF EXISTS analytics.seller_performance;

CREATE TABLE analytics.seller_performance AS
WITH seller_orders AS (
    SELECT
        i.seller_id,
        i.order_id,
        i.price,
        i.freight_value,
        o.customer_id,
        o.is_delivered,
        o.is_late
    FROM analytics.fact_order_items i
    JOIN analytics.fact_orders o
        ON i.order_id = o.order_id
),

seller_reviews AS (
    SELECT
        i.seller_id,
        COUNT(r.order_id) AS reviewed_orders,
        COUNT(*) FILTER (WHERE r.review_score <= 2) AS negative_reviews,
        ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
    FROM analytics.fact_order_items i
    JOIN staging.order_reviews r
        ON i.order_id = r.order_id
    GROUP BY i.seller_id
),

seller_risk AS (
    SELECT
        i.seller_id,
        COUNT(*) FILTER (WHERE r.payment_mismatch_flag = 1) AS payment_mismatches,
        COUNT(*) FILTER (WHERE r.late_delivery_flag = 1) AS late_orders,
        COUNT(*) FILTER (WHERE r.high_freight_ratio_flag = 1) AS high_freight_orders
    FROM analytics.fact_order_items i
    JOIN analytics.order_risk r
        ON i.order_id = r.order_id
    GROUP BY i.seller_id
)

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(DISTINCT so.order_id) AS orders,

    COUNT(DISTINCT so.customer_id) AS customers,

    ROUND(SUM(so.price)::numeric, 2) AS revenue,

    ROUND(SUM(so.freight_value)::numeric, 2) AS freight_value,

    ROUND(
        SUM(so.price + so.freight_value)::numeric,
        2
    ) AS gross_value,

    ROUND(
        AVG(so.price + so.freight_value)::numeric,
        2
    ) AS avg_order_value,

    COUNT(*) FILTER (
        WHERE so.is_delivered = 1
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE so.is_late = 1
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE so.is_late = 1
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE so.is_delivered = 1
            ), 0
        ),
        2
    ) AS late_rate_pct,

    COALESCE(sr.reviewed_orders, 0) AS reviewed_orders,

    COALESCE(sr.negative_reviews, 0) AS negative_reviews,

    sr.avg_review_score,

    ROUND(
        100.0 * COALESCE(sr.negative_reviews, 0)
        / NULLIF(sr.reviewed_orders, 0),
        2
    ) AS negative_review_rate_pct,

    COALESCE(sk.payment_mismatches, 0) AS payment_mismatches,

    COALESCE(sk.late_orders, 0) AS risk_late_orders,

    COALESCE(sk.high_freight_orders, 0) AS high_freight_orders

FROM staging.sellers s
LEFT JOIN seller_orders so
    ON s.seller_id = so.seller_id
LEFT JOIN seller_reviews sr
    ON s.seller_id = sr.seller_id
LEFT JOIN seller_risk sk
    ON s.seller_id = sk.seller_id

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state,
    sr.reviewed_orders,
    sr.negative_reviews,
    sr.avg_review_score,
    sk.payment_mismatches,
    sk.late_orders,
    sk.high_freight_orders;

CREATE INDEX idx_seller_performance_revenue
    ON analytics.seller_performance(revenue);

CREATE INDEX idx_seller_performance_late
    ON analytics.seller_performance(late_rate_pct);

ANALYZE analytics.seller_performance;
