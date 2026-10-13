"""Run a .sql file against data/telco.db and print the result as a table."""
import sqlite3
import sys
import pandas as pd

with open(sys.argv[1]) as f:
    query = f.read()

conn = sqlite3.connect("data/telco.db")
result = pd.read_sql_query(query, conn)
conn.close()

print(result.to_string(index=False))
