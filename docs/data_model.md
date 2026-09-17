# RevenuePulse Data Model

## Source

Brazilian E-Commerce Public Dataset by Olist.

## Source Tables

The project works with the following Olist datasets:

- Customers
- Orders
- Order Items
- Order Payments
- Order Reviews
- Products
- Sellers
- Geolocation
- Product Category Translation

## Core Relationships

```text
Customers
   │
   ├── customer_id ─────┐
   │                     │
   v                     v
Orders ───────────────┬── Order Items
   │                  │
   │                  └── Products
   │
   ├── Order Payments
   │
   └── Order Reviews

Customers / Sellers
   │
   v
Geolocation
```

## Important Customer Identifier

The Olist dataset contains both `customer_id` and `customer_unique_id`.

- `customer_id` identifies the customer associated with an order.
- `customer_unique_id` is used to identify the same underlying customer across multiple orders and is important for repeat-purchase and customer lifetime analysis.

## Planned Analytical Model

### Fact Tables

- `fact_orders`
- `fact_order_items`
- `fact_payments`
- `fact_reviews`

### Dimension Tables

- `dim_customer`
- `dim_product`
- `dim_seller`
- `dim_date`
- `dim_location`

### Analytical Views / Tables

- `monthly_revenue`
- `customer_rfm`
- `customer_value`
- `product_performance`
- `seller_performance`
- `delivery_performance`
- `revenue_leakage`
- `customer_risk`
- `anomaly_signals`

## Design Goal

The PostgreSQL layer should contain reusable business-ready analytical structures so that Power BI does not contain the entire transformation logic.

Important metrics should have a traceable path:

```text
Source Dataset
  → Cleaned Table
  → SQL Transformation
  → Analytical Metric
  → Power BI
  → Business Insight
```
