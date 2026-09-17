from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw")

FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

def load(name):
    return pd.read_csv(RAW_DIR / FILES[name])

def check_duplicates(df, columns):
    return int(df.duplicated(columns).sum())

def main():
    customers = load("customers")
    orders = load("orders")
    items = load("order_items")
    payments = load("payments")
    reviews = load("reviews")
    products = load("products")
    sellers = load("sellers")
    translation = load("category_translation")

    print("\n========== REVENUEPULSE DATA QUALITY REPORT ==========\n")

    datasets = {
        "customers": customers,
        "orders": orders,
        "order_items": items,
        "payments": payments,
        "reviews": reviews,
        "products": products,
        "sellers": sellers,
        "translation": translation,
    }

    print("1. ROW COUNTS")
    print("-" * 50)

    for name, df in datasets.items():
        print(f"{name:20s}: {len(df):,}")

    print("\n2. MISSING VALUES")
    print("-" * 50)

    for name, df in datasets.items():
        missing = int(df.isna().sum().sum())
        print(f"{name:20s}: {missing:,}")

    print("\n3. DUPLICATES")
    print("-" * 50)

    print(
        f"customers.customer_id: "
        f"{check_duplicates(customers, ['customer_id']):,}"
    )

    print(
        f"orders.order_id: "
        f"{check_duplicates(orders, ['order_id']):,}"
    )

    print(
        f"products.product_id: "
        f"{check_duplicates(products, ['product_id']):,}"
    )

    print(
        f"sellers.seller_id: "
        f"{check_duplicates(sellers, ['seller_id']):,}"
    )

    print(
        f"payments.order_id + payment_sequential: "
        f"{check_duplicates(payments, ['order_id', 'payment_sequential']):,}"
    )

    print("\n4. REFERENTIAL INTEGRITY")
    print("-" * 50)

    customer_ids = set(customers["customer_id"])
    order_ids = set(orders["order_id"])
    product_ids = set(products["product_id"])
    seller_ids = set(sellers["seller_id"])

    missing_order_customers = (
        ~orders["customer_id"].isin(customer_ids)
    ).sum()

    missing_item_orders = (
        ~items["order_id"].isin(order_ids)
    ).sum()

    missing_item_products = (
        ~items["product_id"].isin(product_ids)
    ).sum()

    missing_item_sellers = (
        ~items["seller_id"].isin(seller_ids)
    ).sum()

    missing_payment_orders = (
        ~payments["order_id"].isin(order_ids)
    ).sum()

    missing_review_orders = (
        ~reviews["order_id"].isin(order_ids)
    ).sum()

    print(f"Orders ? Customers : {missing_order_customers:,}")
    print(f"Items ? Orders     : {missing_item_orders:,}")
    print(f"Items ? Products   : {missing_item_products:,}")
    print(f"Items ? Sellers    : {missing_item_sellers:,}")
    print(f"Payments ? Orders  : {missing_payment_orders:,}")
    print(f"Reviews ? Orders   : {missing_review_orders:,}")

    print("\n5. ORDER STATUS")
    print("-" * 50)
    print(orders["order_status"].value_counts(dropna=False).to_string())

    print("\n6. PAYMENT TYPES")
    print("-" * 50)
    print(payments["payment_type"].value_counts(dropna=False).to_string())

    print("\n7. REVIEW SCORES")
    print("-" * 50)
    print(reviews["review_score"].value_counts().sort_index().to_string())

    print("\n8. MONETARY VALIDATION")
    print("-" * 50)

    negative_prices = (items["price"] < 0).sum()
    negative_freight = (items["freight_value"] < 0).sum()
    zero_prices = (items["price"] == 0).sum()

    print(f"Negative item prices : {negative_prices:,}")
    print(f"Negative freight     : {negative_freight:,}")
    print(f"Zero item prices     : {zero_prices:,}")

    print("\n9. DATE VALIDATION")
    print("-" * 50)

    date_columns = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]

    for column in date_columns:
        orders[column] = pd.to_datetime(
            orders[column],
            errors="coerce"
        )

    invalid_date_order = (
        orders["order_delivered_customer_date"].notna()
        &
        orders["order_purchase_timestamp"].notna()
        &
        (
            orders["order_delivered_customer_date"]
            <
            orders["order_purchase_timestamp"]
        )
    ).sum()

    print(
        "Delivered before purchase: "
        f"{invalid_date_order:,}"
    )

    delivery_beyond_estimate = (
        orders["order_delivered_customer_date"].notna()
        &
        orders["order_estimated_delivery_date"].notna()
        &
        (
            orders["order_delivered_customer_date"]
            >
            orders["order_estimated_delivery_date"]
        )
    ).sum()

    print(
        "Delivered after estimate: "
        f"{delivery_beyond_estimate:,}"
    )

    print("\n10. ORDER / PAYMENT CONSISTENCY")
    print("-" * 50)

    item_totals = (
        items.groupby("order_id")
        .agg(
            item_revenue=("price", "sum"),
            freight=("freight_value", "sum")
        )
    )

    payment_totals = (
        payments.groupby("order_id")
        .agg(payment_value=("payment_value", "sum"))
    )

    comparison = item_totals.join(
        payment_totals,
        how="inner"
    )

    comparison["difference"] = (
        comparison["payment_value"]
        -
        comparison["item_revenue"]
        -
        comparison["freight"]
    )

    large_difference = (
        comparison["difference"].abs() > 0.01
    ).sum()

    print(
        f"Orders with payment mismatch: "
        f"{large_difference:,}"
    )

    print("\n11. BASIC BUSINESS METRICS")
    print("-" * 50)

    delivered = orders["order_status"].eq("delivered").sum()

    total_item_revenue = items["price"].sum()
    total_freight = items["freight_value"].sum()

    print(f"Delivered orders : {delivered:,}")
    print(f"Item revenue     : {total_item_revenue:,.2f}")
    print(f"Freight value    : {total_freight:,.2f}")
    print(
        f"Average order value: "
        f"{total_item_revenue / orders['order_id'].nunique():,.2f}"
    )

    print("\n========================================================")
    print("DATA QUALITY CHECK COMPLETED")
    print("========================================================")

if __name__ == "__main__":
    main()
