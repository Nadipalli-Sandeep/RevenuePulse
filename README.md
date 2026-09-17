# RevenuePulse
## Customer Value, Revenue Leakage & Operational Risk Analytics

RevenuePulse is an end-to-end analytics project built using the public Olist Brazilian E-Commerce dataset.

The project combines Python data quality and cleaning, PostgreSQL, SQL analytics, customer value segmentation, revenue-risk signals, seller performance analysis, category analysis, and Power BI visualization.

## Business Problem

E-commerce businesses need to understand not only how much revenue they generate, but also:

- Which customer segments contribute the most value?
- Where is revenue exposed to operational risk?
- Which orders show multiple risk signals?
- Which sellers generate high revenue but also experience delivery or review issues?
- Which product categories contribute significant revenue and freight costs?
- How can management monitor these indicators through an executive dashboard?

## Data

Source: Olist Brazilian E-Commerce Public Dataset

Dataset scale:

- 99K+ orders
- 96K+ unique customers
- 112K+ order items
- 103K+ payment records
- 99K+ review records
- 32K+ products
- 3K+ sellers
## Technology Stack

- Python
- Pandas
- PostgreSQL
- SQL
- Power BI
- Git/GitHub

## Analytics Pipeline

```text
Olist CSV Data
      ?
Python Data Quality Checks
      ?
Data Cleaning & Feature Engineering
      ?
PostgreSQL Staging Layer
      ?
SQL Analytical Layer
      ?
Customer Value / RFM
      ?
Revenue Risk Signals
      ?
Seller & Category Analytics
      ?
Power BI Executive Dashboard

## Power BI Dashboard

The Executive Overview contains:

- Total Orders KPI
- Revenue KPI
- Gross Value KPI
- Unique Customers KPI
- Late Rate KPI
- Multi-Signal Risk KPI
- Top 10 Revenue Categories
- Monthly Revenue Trend
- Customer Value Segments
- Order Risk Signal Distribution
- Top 10 Sellers by Revenue
- Customer State filter
- Order Status filter

## Data Quality

The project includes checks for:

- Row counts
- Missing values
- Duplicate records
- Referential integrity
- Order status distribution
- Payment types
- Review scores
- Monetary validity
- Delivery timing
- Order/payment consistency

## Project Structure

```text
RevenuePulse/
+-- data/
+-- docs/
+-- notebooks/
+-- sql/
+-- src/
+-- tests/
+-- main.py
+-- requirements.txt
+-- README.md
+-- RevenuePulse.pbix
