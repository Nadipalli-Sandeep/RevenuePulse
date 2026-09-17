from pathlib import Path
import pandas as pd
import numpy as np

RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


def load(name):
    return pd.read_csv(RAW_DIR / name)


def main():

    print("\n========== REVENUEPULSE DATA CLEANING ==========\n")

    customers = load("olist_customers_dataset.csv")
    orders = load("olist_orders_dataset.csv")
    items = load("olist_order_items_dataset.csv")
    payments = load("olist_order_payments_dataset.csv")
    reviews = load("olist_order_reviews_dataset.csv")
    products = load("olist_products_dataset.csv")
    sellers = load("olist_sellers_dataset.csv")
    translation = load("product_category_name_translation.csv")

    # -------------------------------------------------
    # 1. CUSTOMER DATA
    # -------------------------------------------------

    customers = customers.drop_duplicates(
        subset=["customer_id"]
    )

    customers["customer_city"] = (
        customers["customer_city"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    customers["customer_state"] = (
        customers["customer_state"]
        .astype("string")
        .str.strip()
        .str.upper()
    )

    # -------------------------------------------------
    # 2. ORDER DATA
    # -------------------------------------------------

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

    orders = orders.drop_duplicates(
        subset=["order_id"]
    )

    # Delivery metrics

    orders["delivery_delay_days"] = np.where(
        orders["order_delivered_customer_date"].notna()
        &
        orders["order_estimated_delivery_date"].notna(),
        (
            orders["order_delivered_customer_date"]
            -
            orders["order_estimated_delivery_date"]
        ).dt.days,
        np.nan
    )

    orders["is_late"] = (
        orders["delivery_delay_days"] > 0
    ).astype("Int64")

    orders["delivery_days"] = np.where(
        orders["order_delivered_customer_date"].notna()
        &
        orders["order_purchase_timestamp"].notna(),
        (
            orders["order_delivered_customer_date"]
            -
            orders["order_purchase_timestamp"]
        ).dt.total_seconds() / 86400,
        np.nan
    )

    orders["delivery_days"] = orders["delivery_days"].round(2)

    # Order lifecycle flags

    orders["is_delivered"] = (
        orders["order_status"] == "delivered"
    ).astype(int)

    orders["is_cancelled"] = (
        orders["order_status"] == "canceled"
    ).astype(int)

    orders["is_unavailable"] = (
        orders["order_status"] == "unavailable"
    ).astype(int)

    # -------------------------------------------------
    # 3. ORDER ITEMS
    # -------------------------------------------------

    items = items.drop_duplicates(
        subset=[
            "order_id",
            "order_item_id",
            "product_id",
            "seller_id"
        ]
    )

    items["shipping_limit_date"] = pd.to_datetime(
        items["shipping_limit_date"],
        errors="coerce"
    )

    items["price"] = pd.to_numeric(
        items["price"],
        errors="coerce"
    )

    items["freight_value"] = pd.to_numeric(
        items["freight_value"],
        errors="coerce"
    )

    items["item_total_value"] = (
        items["price"] +
        items["freight_value"]
    ).round(2)

    # -------------------------------------------------
    # 4. PAYMENTS
    # -------------------------------------------------

    payments = payments.drop_duplicates(
        subset=["order_id", "payment_sequential"]
    )

    payments["payment_value"] = pd.to_numeric(
        payments["payment_value"],
        errors="coerce"
    )

    payments["payment_type"] = (
        payments["payment_type"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    # -------------------------------------------------
    # 5. REVIEWS
    # -------------------------------------------------

    reviews = reviews.drop_duplicates(
        subset=["review_id"]
    )

    reviews["review_creation_date"] = pd.to_datetime(
        reviews["review_creation_date"],
        errors="coerce"
    )

    reviews["review_answer_timestamp"] = pd.to_datetime(
        reviews["review_answer_timestamp"],
        errors="coerce"
    )

    reviews["review_score"] = pd.to_numeric(
        reviews["review_score"],
        errors="coerce"
    )

    reviews["has_review_comment"] = (
        reviews["review_comment_message"]
        .notna()
        &
        reviews["review_comment_message"]
        .astype(str)
        .str.strip()
        .ne("")
    ).astype(int)

    reviews["negative_review_flag"] = (
        reviews["review_score"] <= 2
    ).astype(int)

    # -------------------------------------------------
    # 6. PRODUCTS
    # -------------------------------------------------

    products = products.drop_duplicates(
        subset=["product_id"]
    )

    products["product_category_name"] = (
        products["product_category_name"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    numeric_product_columns = [
        "product_name_lenght",
        "product_description_lenght",
        "product_photos_qty",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm",
    ]

    for column in numeric_product_columns:
        products[column] = pd.to_numeric(
            products[column],
            errors="coerce"
        )

    # -------------------------------------------------
    # 7. SELLERS
    # -------------------------------------------------

    sellers = sellers.drop_duplicates(
        subset=["seller_id"]
    )

    sellers["seller_city"] = (
        sellers["seller_city"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    sellers["seller_state"] = (
        sellers["seller_state"]
        .astype("string")
        .str.strip()
        .str.upper()
    )

    # -------------------------------------------------
    # 8. CATEGORY TRANSLATION
    # -------------------------------------------------

    translation = translation.drop_duplicates(
        subset=["product_category_name"]
    )

    translation["product_category_name"] = (
        translation["product_category_name"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    translation["product_category_name_english"] = (
        translation["product_category_name_english"]
        .astype("string")
        .str.strip()
        .str.lower()
    )

    # -------------------------------------------------
    # 9. PRODUCT CATEGORY ENRICHMENT
    # -------------------------------------------------

    products = products.merge(
        translation,
        on="product_category_name",
        how="left"
    )

    products["product_category_name_english"] = (
        products["product_category_name_english"]
        .fillna("unknown")
    )

    # -------------------------------------------------
    # 10. DATA QUALITY FLAGS
    # -------------------------------------------------

    products["missing_product_description"] = (
        products["product_description_lenght"].isna()
    ).astype(int)

    products["missing_product_weight"] = (
        products["product_weight_g"].isna()
    ).astype(int)

    orders["missing_delivery_date"] = (
        orders["order_delivered_customer_date"].isna()
    ).astype(int)

    # -------------------------------------------------
    # 11. SAVE PROCESSED DATA
    # -------------------------------------------------

    datasets = {
        "customers_clean.csv": customers,
        "orders_clean.csv": orders,
        "order_items_clean.csv": items,
        "order_payments_clean.csv": payments,
        "order_reviews_clean.csv": reviews,
        "products_clean.csv": products,
        "sellers_clean.csv": sellers,
    }

    for filename, dataframe in datasets.items():
        dataframe.to_csv(
            PROCESSED_DIR / filename,
            index=False
        )

    print("Cleaning completed successfully.\n")

    print("Processed datasets:")
    for filename, dataframe in datasets.items():
        print(f"{filename:30s}: {len(dataframe):,} rows")

    print("\nDerived fields created:")
    print("- delivery_delay_days")
    print("- is_late")
    print("- delivery_days")
    print("- is_delivered")
    print("- is_cancelled")
    print("- is_unavailable")
    print("- item_total_value")
    print("- has_review_comment")
    print("- negative_review_flag")
    print("- missing_product_description")
    print("- missing_product_weight")

    print("\nOutput directory:")
    print(PROCESSED_DIR.resolve())


if __name__ == "__main__":
    main()
