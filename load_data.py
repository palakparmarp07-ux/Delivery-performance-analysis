import pandas as pd
from sqlalchemy import create_engine
import getpass

password = getpass.getpass('Enter MySQL password: ')
engine = create_engine(f'mysql+pymysql://root:{password}@localhost/olist_ecommerce')

files_to_tables = {
    'olist_customers_dataset.csv': 'olist_customers',
    'olist_orders_dataset.csv': 'olist_orders',
    'olist_order_reviews_dataset.csv': 'olist_order_reviews',
}

for csv_file, table_name in files_to_tables.items():
    df = pd.read_csv(csv_file)
    df.to_sql(table_name, con=engine, if_exists='append', index=False)
    print(f'Loaded {table_name}: {len(df)} rows')