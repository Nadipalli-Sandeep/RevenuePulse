# RevenuePulse Architecture

## End-to-End Architecture

```text
Olist Public Dataset
        ↓
Data Ingestion
        ↓
Data Quality Validation
        ↓
Cleaned Data
        ↓
PostgreSQL
        ↓
├───────────────────────┬───────────────────────┐
│                       │                       │
↓                       ↓                       ↓
Revenue SQL        Customer SQL        Operations SQL
        │                       │                       │
        └───────────────────────┴───────────────────────┘
                                ↓
                    Analytical Data Layer
                                ↓
           ┌───────────────────────┬───────────────────────┐
           │                       │                       │
           ↓                       ↓                       ↓
      Revenue Risk         Customer Value            Anomalies
           │                       │                       │
           └───────────────────────┴───────────────────────┘
                                ↓
                            Power BI
                                ↓
                  Business Decision Support
```

## Technology Stack

### Development
- VS Code
- Git
- GitHub

### Programming
- Python

### Data Processing
- Pandas
- NumPy

### Database
- PostgreSQL

### Query Language
- SQL

### Analytics
- Pandas
- Scikit-learn
- Statistical analysis

### Business Intelligence
- Power BI

## Data Flow

```text
Olist CSV Files
  → Python Ingestion
  → Data Quality Validation
  → PostgreSQL
  → SQL Transformations
  → Analytical Tables
  → Business Analytics
  → Power BI Dashboard
  → Business Insights
```

## Traceability Principle

Important dashboard metrics should be traceable back to the original Olist source data through the PostgreSQL analytical layer.
