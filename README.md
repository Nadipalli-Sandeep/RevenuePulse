# RevenuePulse

## Customer Value, Revenue Leakage & Operational Risk Analytics

RevenuePulse is an end-to-end analytics project built on the public Olist Brazilian E-Commerce dataset. It combines Python-based data quality checks, PostgreSQL modeling, SQL analytics, customer segmentation, risk analysis, and Power BI dashboarding to help organizations understand revenue performance and operational exposure.

## Business Problem

E-commerce businesses need to understand more than just total revenue. This project helps answer questions such as:

- Which customer segments create the most value?
- Where is revenue exposed to operational risk?
- Which orders show multiple risk signals?
- Which sellers generate strong revenue while also facing delivery or review issues?
- Which product categories contribute the most revenue and freight cost?
- How can management monitor these metrics through an executive dashboard?

## Dataset

Source: Olist Brazilian E-Commerce Public Dataset

Approximate scale:

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
- NumPy
- PostgreSQL
- SQL
- Jupyter Notebook
- Power BI
- Git / GitHub

## Analytics Workflow

```text
Olist raw CSV files
   ↓
Python ingestion and data validation
   ↓
Data cleaning and feature engineering
   ↓
PostgreSQL staging layer
   ↓
SQL analytical layer
   ↓
Customer value / RFM analysis
   ↓
Revenue risk signal detection
   ↓
Seller and category performance analysis
   ↓
Power BI executive dashboard
```

## Power BI Dashboard Highlights

The executive overview includes key performance indicators and visualizations such as:

- Total orders
- Revenue
- Gross value
- Unique customers
- Late rate
- Multi-signal risk rate
- Top 10 revenue categories
- Monthly revenue trend
- Customer value segments
- Order risk signal distribution
- Top 10 sellers by revenue
- Customer state filter
- Order status filter

## Data Quality Checks

The project includes validation for:

- Row counts
- Missing values
- Duplicate records
- Referential integrity
- Order status distribution
- Payment type distribution
- Review score validity
- Monetary validity
- Delivery timing analysis
- Order/payment consistency

## Project Structure

```text
RevenuePulse/
├── data/
├── docs/
├── notebooks/
├── sql/
├── src/
├── tests/
├── .gitignore
├── README.md
├── requirements.txt
├── RevenuePulse.pbix
└── ...
```

## Documentation

Project documentation is organized in the `docs/` folder, including:

- architecture overview
- business problem framing
- data dictionary
- data model details
- methodology and insights

## Getting Started

1. Create a virtual environment:

```bash
python -m venv .venv
```

2. Activate the environment:

- Windows:

```bash
.venv\Scripts\activate
```

- macOS/Linux:

```bash
source .venv/bin/activate
```

3. Install project dependencies:

```bash
pip install -r requirements.txt
```

4. Load the Olist dataset into PostgreSQL and run the SQL scripts in the `sql/` folder to build the staging and analytical layers.

5. Open the notebook in `notebooks/` for exploratory analysis and use the Power BI dashboard for executive reporting.

## Summary

RevenuePulse is designed to bridge raw e-commerce transaction data to actionable business insight. It helps teams identify high-value customers, expose hidden revenue risks, and monitor operational health using a structured, end-to-end analytics workflow.
