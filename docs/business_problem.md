# RevenuePulse

## Project Title

RevenuePulse — Customer Value, Revenue Leakage and Operational Risk Analytics

## Business Domain

E-commerce / Retail Analytics

## Data Source

RevenuePulse uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains approximately 100,000 real, anonymized e-commerce orders from 2016 to 2018 and includes information covering orders, customers, products, payments, freight, delivery performance, and customer reviews.

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Business Problem

E-commerce businesses generate large amounts of transactional and operational data. Basic reporting can show sales and order volumes, but deeper analysis is needed to understand customer value, revenue performance, delivery issues, returns, product performance, and potential revenue leakage.

RevenuePulse builds an end-to-end analytics pipeline that transforms raw Olist data into business-ready analytical datasets and decision-support insights.

## Primary Objective

Build a reproducible analytics solution covering:

- Data ingestion
- Data quality validation
- Data transformation
- PostgreSQL data modeling
- SQL analytics
- Customer analytics
- Revenue analysis
- Operational analysis
- Risk and anomaly signals
- Power BI visualization

## Core Business Questions

### Revenue

1. How does revenue change over time?
2. Which product categories generate the most revenue?
3. Which sellers and regions contribute most to sales?
4. How does average order value change over time?

### Customer

5. How many customers make repeat purchases?
6. Which customers generate the highest value?
7. What customer segments can be identified using RFM analysis?
8. Which customer groups show weaker engagement or value?

### Revenue Leakage

9. How do freight costs affect order economics?
10. Which products or categories have weak revenue-to-cost relationships?
11. How are cancellations and delivered-order failures affecting revenue?
12. Are there combinations of discounts, freight, and order characteristics associated with weaker economics?

### Operations

13. How does delivery performance vary by region?
14. How are delivery delays related to customer review scores?
15. Which sellers or product categories have weaker delivery performance?

### Decision Support

16. Which areas should management investigate first?
17. Which customers, products, or operational segments require attention?
18. Can historical behavior be converted into useful risk or anomaly signals?

## Primary KPIs

- Total orders
- Delivered orders
- Cancelled orders
- Gross revenue
- Freight revenue
- Freight cost
- Average order value
- Repeat customer rate
- Customer lifetime value
- RFM segment
- Delivery delay rate
- Cancellation rate
- Return / review indicators
- Average review score
- Revenue concentration
- Customer risk indicators

## Analytical Layers

### Layer 1 — Raw Data

Original Olist CSV datasets.

### Layer 2 — Data Quality

Validation of:

- Missing values
- Duplicate records
- Referential integrity
- Date consistency
- Invalid values
- Outliers
- Cross-table consistency

### Layer 3 — PostgreSQL

Cleaned and modeled data stored in PostgreSQL.

### Layer 4 — Analytics

Business-focused SQL, Python, and statistical analysis.

### Layer 5 — Decision Dashboard

Power BI dashboard designed around business questions rather than only visual presentation.

## Expected Output

1. Reproducible data ingestion pipeline
2. Data quality validation
3. PostgreSQL analytical database
4. SQL transformation layer
5. Customer analytics
6. Revenue analytics
7. Operational analytics
8. Risk / anomaly analysis
9. Power BI dashboard
10. Business insights report
11. Complete GitHub repository

## Project Principle

The public dataset is the source data. The analytical framework, data model, SQL layer, derived metrics, customer-health methodology, risk signals, visualizations, and business interpretation are implemented as part of RevenuePulse.

```text
Raw Data
  → Data Quality
  → Data Engineering
  → SQL
  → Analytics
  → Risk Signals
  → Power BI
  → Business Insights
```
