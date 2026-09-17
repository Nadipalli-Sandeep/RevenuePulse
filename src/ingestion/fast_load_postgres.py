from pathlib import Path
import psycopg

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data" / "raw"

password = input("PostgreSQL password: ")

conn = psycopg.connect(
    host="localhost",
    port=5432,
    dbname="revenuepulse",
    user="postgres",
    password=password
)

FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

try:
    with conn.cursor() as cur:

        for table, filename in FILES.items():

            path = DATA_DIR / filename

            print(f"Loading {table}...", flush=True)

            cur.execute(f"TRUNCATE TABLE staging.{table}")

            with open(path, "rb") as f:
                with cur.copy(
                    f"COPY staging.{table} FROM STDIN WITH (FORMAT csv, HEADER true)"
                ) as copy:
                    while True:
                        data = f.read(1024 * 1024)
                        if not data:
                            break
                        copy.write(data)

            cur.execute(f"SELECT COUNT(*) FROM staging.{table}")
            count = cur.fetchone()[0]

            print(f"{table}: {count:,}", flush=True)

        conn.commit()

    print("\n========== LOAD SUCCESSFUL ==========")

except Exception as e:
    conn.rollback()
    print("\n========== LOAD FAILED ==========")
    print(type(e).__name__)
    print(str(e))

finally:
    conn.close()
