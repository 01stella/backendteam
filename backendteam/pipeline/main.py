from dotenv import load_dotenv
import os
import pandas as pd
from sqlalchemy import create_engine, text

load_dotenv()
# 1. Connect to the shared MySQL database
DB_PASSWORD = os.environ.get('DB_PASSWORD')

if not DB_PASSWORD:
    raise ValueError("SECURITY ALERT: No database password found. Check your .env file!")

engine = create_engine(f"mysql+pymysql://root:{DB_PASSWORD}@lumiora-db:3306/lumiora_db")

def run_pipeline_metrics():
    print("Starting pipeline: Crunching all 4 metrics...")
    
    # --- METRIC 1: Total Sales per day (remains the same) ---
    query_1 = """
        SELECT DATE(created_at) as sale_date, SUM(total) as total_sales 
        FROM orders GROUP BY DATE(created_at);
    """
    pd.read_sql(query_1, engine).to_sql('metrics_daily_sales', engine, if_exists='replace', index=False)
    
    # --- METRIC 2: Total Sales per day per item (including menu) ---
    # Note: If bundles are sold as items, they are already captured if they exist in menu.
    query_2 = """
        SELECT DATE(o.created_at) as sale_date, m.item_name, SUM(oi.quantity * oi.item_price) as item_revenue
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN menu m ON oi.menu_id = m.id
        GROUP BY DATE(o.created_at), m.item_name;
    """
    pd.read_sql(query_2, engine).to_sql('metrics_sales_per_item', engine, if_exists='replace', index=False)

    # --- METRIC 3: Total quantity sold per day per item ---
    query_3 = """
        SELECT DATE(o.created_at) as sale_date, m.item_name, SUM(oi.quantity) as total_quantity
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN menu m ON oi.menu_id = m.id
        GROUP BY DATE(o.created_at), m.item_name;
    """
    pd.read_sql(query_3, engine).to_sql('metrics_qty_per_item', engine, if_exists='replace', index=False)

    # --- METRIC 4: Total quantity ordered per hour per day ---
    query_4 = """
        SELECT 
            DATE(o.created_at) as sale_date, 
            CONCAT(HOUR(o.created_at), ':00') as sale_hour, 
            SUM(oi.quantity) as hourly_quantity
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        GROUP BY DATE(o.created_at), HOUR(o.created_at), sale_hour;
    """
    pd.read_sql(query_4, engine).to_sql('metrics_hourly_qty', engine, if_exists='replace', index=False)