DROP TABLE IF EXISTS analytics.order_risk;

CREATE TABLE analytics.order_risk AS
WITH item_summary AS (
    SELECT
        order_id,
        ROUND(SUM(price)::numeric, 2) AS item_revenue,
        ROUND(SUM(freight_value)::numeric, 2) AS freight_value,
        COUNT(*) AS item_count
    FROM analytics.fact_order_items
    GROUP BY order_id
),

payment_summary AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value)::numeric, 2) AS payment_value,
        COUNT(*) AS payment_count,
        COUNT(DISTINCT payment_type) AS payment_type_count
    FROM staging.order_payments
    GROUP BY order_id
),

review_summary AS (
    SELECT
        order_id,
        COUNT(*) AS review_count,
        ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
    FROM staging.order_reviews
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,

    COALESCE(i.item_revenue, 0) AS item_revenue,
    COALESCE(i.freight_value, 0) AS freight_value,
    COALESCE(i.item_count, 0) AS item_count,

    COALESCE(p.payment_value, 0) AS payment_value,
    COALESCE(p.payment_count, 0) AS payment_count,
    COALESCE(p.payment_type_count, 0) AS payment_type_count,

    COALESCE(r.review_count, 0) AS review_count,
    r.avg_review_score,

    CASE
        WHEN ABS(
            COALESCE(p.payment_value, 0)
            - COALESCE(i.item_revenue, 0)
            - COALESCE(i.freight_value, 0)
        ) > 0.01
        THEN 1
        ELSE 0
    END AS payment_mismatch_flag,

    CASE
        WHEN o.order_status IN ('canceled', 'unavailable')
         AND COALESCE(p.payment_value, 0) > 0
        THEN 1
        ELSE 0
    END AS cancelled_paid_flag,

    CASE
        WHEN o.is_late = 1
        THEN 1
        ELSE 0
    END AS late_delivery_flag,

    CASE
        WHEN COALESCE(i.item_revenue, 0) > 0
         AND COALESCE(i.freight_value, 0)
             / i.item_revenue > 0.50
        THEN 1
        ELSE 0
    END AS high_freight_ratio_flag,

    CASE
        WHEN COALESCE(p.payment_count, 0) > 1
        THEN 1
        ELSE 0
    END AS multiple_payment_flag,

    CASE
        WHEN COALESCE(r.avg_review_score, 5) <= 2
        THEN 1
        ELSE 0
    END AS negative_review_flag,

    (
        CASE
            WHEN ABS(
                COALESCE(p.payment_value, 0)
                - COALESCE(i.item_revenue, 0)
                - COALESCE(i.freight_value, 0)
            ) > 0.01
            THEN 1 ELSE 0
        END
        +
        CASE
            WHEN o.order_status IN ('canceled', 'unavailable')
             AND COALESCE(p.payment_value, 0) > 0
            THEN 1 ELSE 0
        END
        +
        CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END
        +
        CASE
            WHEN COALESCE(i.item_revenue, 0) > 0
             AND COALESCE(i.freight_value, 0)
                 / i.item_revenue > 0.50
            THEN 1 ELSE 0
        END
        +
        CASE
            WHEN COALESCE(p.payment_count, 0) > 1
            THEN 1 ELSE 0
        END
        +
        CASE
            WHEN COALESCE(r.avg_review_score, 5) <= 2
            THEN 1 ELSE 0
        END
    ) AS risk_signal_count

FROM analytics.fact_orders o
LEFT JOIN item_summary i
    ON o.order_id = i.order_id
LEFT JOIN payment_summary p
    ON o.order_id = p.order_id
LEFT JOIN review_summary r
    ON o.order_id = r.order_id;

CREATE INDEX idx_order_risk_order
    ON analytics.order_risk(order_id);

CREATE INDEX idx_order_risk_status
    ON analytics.order_risk(order_status);

CREATE INDEX idx_order_risk_score
    ON analytics.order_risk(risk_signal_count);

ANALYZE analytics.order_risk;
