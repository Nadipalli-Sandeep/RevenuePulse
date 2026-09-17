DROP VIEW IF EXISTS analytics.v_executive_kpis;

CREATE VIEW analytics.v_executive_kpis AS
WITH item_totals AS (
    SELECT
        order_id,
        SUM(price) AS revenue,
        SUM(freight_value) AS freight_value
    FROM analytics.fact_order_items
    GROUP BY order_id
),

risk AS (
    SELECT
        order_id,
        payment_mismatch_flag,
        cancelled_paid_flag,
        risk_signal_count
    FROM analytics.order_risk
)

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN o.is_delivered = 1 THEN o.order_id
    END) AS delivered_orders,

    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    (SELECT COUNT(*) FROM analytics.dim_sellers) AS active_sellers,

    ROUND(COALESCE(SUM(it.revenue), 0)::numeric, 2) AS revenue,

    ROUND(COALESCE(SUM(it.freight_value), 0)::numeric, 2) AS freight_value,

    ROUND(
        COALESCE(SUM(it.revenue + it.freight_value), 0)::numeric,
        2
    ) AS gross_value,

    ROUND(
        COALESCE(SUM(it.revenue), 0)::numeric
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_order_value,

    ROUND(AVG(o.delivery_days)::numeric, 2) AS avg_delivery_days,

    COUNT(DISTINCT CASE
        WHEN o.is_late = 1 THEN o.order_id
    END) AS late_orders,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.is_late = 1 THEN o.order_id
        END)
        / NULLIF(
            COUNT(DISTINCT CASE
                WHEN o.is_delivered = 1 THEN o.order_id
            END),
            0
        ),
        2
    ) AS late_rate_pct,

    COUNT(DISTINCT CASE
        WHEN r.payment_mismatch_flag = 1 THEN r.order_id
    END) AS payment_mismatches,

    COUNT(DISTINCT CASE
        WHEN r.cancelled_paid_flag = 1 THEN r.order_id
    END) AS cancelled_paid_orders,

    COUNT(DISTINCT CASE
        WHEN r.risk_signal_count >= 2 THEN r.order_id
    END) AS multi_signal_risk_orders

FROM analytics.fact_orders o

LEFT JOIN analytics.dim_customers c
    ON o.customer_id = c.customer_id

LEFT JOIN item_totals it
    ON o.order_id = it.order_id

LEFT JOIN risk r
    ON o.order_id = r.order_id;
