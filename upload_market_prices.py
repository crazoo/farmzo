import mysql.connector
import requests
import json
from datetime import datetime

# MySQL Database Configuration (Update these)
MYSQL_HOST = "localhost"
MYSQL_USER = "SUNDARSSAV86108838"
MYSQL_PASSWORD = "SUNDAR8838"
MYSQL_DATABASE = "market_prices"

# API Configuration (Update API key)
API_KEY = "579b464db66ec23bdd000001efafcb95abb149a258d2697c3c5fc058"
RESOURCE_ID = "9ef84268-d588-465a-a308-a864a43d0070"
API_URL = f"https://api.data.gov.in/resource/{RESOURCE_ID}?api-key={API_KEY}&format=json&limit=10000"

# Connect to MySQL
def connect_db():
    return mysql.connector.connect(
        host=MYSQL_HOST,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        database=MYSQL_DATABASE
    )

# Fetch market prices from API
def fetch_market_prices():
    response = requests.get(API_URL)
    if response.status_code == 200:
        data = response.json()
        return data.get("records", [])
    else:
        print("Failed to fetch market prices")
        return []

# Check if entry exists in MySQL
def record_exists(cursor, date, state, district, market, commodity):
    query = """
        SELECT COUNT(*) FROM market_prices 
        WHERE date = %s AND state = %s AND district = %s AND market = %s AND commodity = %s
    """
    cursor.execute(query, (date, state, district, market, commodity))
    return cursor.fetchone()[0] > 0

# Insert data into MySQL
def insert_market_prices(data):
    connection = connect_db()
    cursor = connection.cursor()

    insert_query = """
        INSERT INTO market_prices (date, state, district, market, commodity, variety, min_price, max_price, modal_price) 
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    for record in data:
        try:
            date = record.get("arrival_date")
            state = record.get("state")
            district = record.get("district")
            market = record.get("market")
            commodity = record.get("commodity")
            variety = record.get("variety", "N/A")
            min_price = float(record.get("min_price", 0)) / 100
            max_price = float(record.get("max_price", 0)) / 100
            modal_price = float(record.get("modal_price", 0)) / 100

            # Check if entry exists
            if not record_exists(cursor, date, state, district, market, commodity):
                cursor.execute(insert_query, (date, state, district, market, commodity, variety, min_price, max_price, modal_price))
                print(f"Inserted: {commodity} in {market}, {district}, {state} on {date}")
            else:
                print(f"Skipping duplicate entry: {commodity} in {market}, {district}, {state} on {date}")

        except Exception as e:
            print(f"Error inserting record: {record} -> {e}")

    connection.commit()
    cursor.close()
    connection.close()

# Main Execution
if __name__ == "__main__":
    print("Fetching market prices...")
    market_data = fetch_market_prices()
    if market_data:
        print("Uploading data to MySQL...")
        insert_market_prices(market_data)
        print("Upload completed successfully!")
    else:
        print("No new data found.")
