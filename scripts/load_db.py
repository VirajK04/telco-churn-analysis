"""Load the cleaned CSV into a SQLite database so we can query it with SQL."""
import sqlite3
import pandas as pd

df = pd.read_csv("data/telco_clean.csv")

conn = sqlite3.connect("data/telco.db")
df.to_sql("customers", conn, if_exists="replace", index=False)

print("Rows in table:", conn.execute("SELECT COUNT(*) FROM customers").fetchone()[0])
conn.close()
