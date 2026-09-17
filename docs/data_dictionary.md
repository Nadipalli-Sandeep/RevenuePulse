# Data Dictionary

## Customer

| Field | Description |
|---|---|
| customer_id | Order-level customer identifier |
| customer_unique_id | Unique customer identifier across orders |
| customer_zip_code_prefix | Customer ZIP code prefix |
| customer_city | Customer city |
| customer_state | Customer state |

## Orders

| Field | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer associated with the order |
| order_status | Current order status |
| order_purchase_timestamp | Order purchase timestamp |
| order_approved_at | Payment approval timestamp |
| order_delivered_carrier_date | Date handed to carrier |
| order_delivered_customer_date | Customer delivery date |
| order_estimated_delivery_date | Estimated delivery date |
| delivery_delay_days | Difference between delivery and estimated delivery |
| is_late | Late-delivery indicator |
| is_delivered | Delivered-order indicator |

## Order Items

| Field | Description |
|---|---|
| order_id | Order identifier |
| order_item_id | Item sequence within an order |
| product_id | Product identifier |
| seller_id | Seller identifier |
| price | Product item price |
| freight_value | Freight/shipping value |
| item_total_value | Item price plus freight |

## Payments

| Field | Description |
|---|---|
| order_id | Order identifier |
| payment_sequential | Payment sequence within an order |
| payment_type | Payment method |
| payment_installments | Number of installments |
| payment_value | Payment amount |

## Reviews

| Field | Description |
|---|---|
| review_id | Review identifier |
| order_id | Associated order |
| review_score | Customer review score |
| review_comment_title | Review title |
| review_comment_message | Review text |
| negative_review_flag | Indicator for negative review signal |

## Products

| Field | Description |
|---|---|
| product_id | Product identifier |
| product_category_name | Original product category |
| product_category_name_english | Translated category |
| product_weight_g | Product weight |
| product_length_cm | Product length |
| product_height_cm | Product height |
| product_width_cm | Product width |

## Sellers

| Field | Description |
|---|---|
| seller_id | Seller identifier |
| seller_zip_code_prefix | Seller ZIP code prefix |
| seller_city | Seller city |
| seller_state | Seller state |

## Analytical Metrics

| Metric | Meaning |
|---|---|
| Recency | Time since customer's most recent purchase |
| Frequency | Number of orders associated with a customer |
| Monetary Value | Customer revenue/value contribution |
| Late Rate | Late delivered orders divided by delivered orders |
| Freight Ratio | Freight value relative to item value |
| Risk Signal Count | Number of risk indicators associated with an order |
