DROP TABLE IF EXISTS analytics.category_performance;

CREATE TABLE analytics.category_performance AS
SELECT
    COALESCE(
        p.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT i.order_id) AS orders,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT o.customer_id) AS customers,

    COUNT(DISTINCT i.seller_id) AS sellers,

    ROUND(SUM(i.price)::numeric, 2) AS revenue,

    ROUND(SUM(i.freight_value)::numeric, 2) AS freight_value,

    ROUND(SUM(i.price + i.freight_value)::numeric, 2) AS gross_value,

    ROUND(
        AVG(i.price + i.freight_value)::numeric,
        2
    ) AS avg_item_value,

    ROUND(
        100.0 * SUM(i.freight_value)
        / NULLIF(SUM(i.price), 0),
        2
    ) AS freight_to_revenue_pct,

    COUNT(*) FILTER (
        WHERE o.is_late = 1
    ) AS late_items,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.is_late = 1
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct

FROM analytics.fact_order_items i

JOIN analytics.fact_orders o
    ON i.order_id = o.order_id

LEFT JOIN analytics.dim_products p
    ON i.product_id = p.product_id

GROUP BY
    COALESCE(
        p.product_category_name_english,
        p.product_category_name,
        'Unknown'
    );

CREATE INDEX idx_category_performance_revenue
    ON analytics.category_performance(revenue);

ANALYZE analytics.category_performance;
