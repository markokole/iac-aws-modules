import mysql.connector
import random
from datetime import datetime
import time
import os

def generate_transaction_data():
    
    user = os.environ['RDS_USER']
    password = os.environ['RDS_PASSWORD']
    host = os.environ['RDS_HOST'] 
    database = "bank"
    transactions_table = "transactions"
    cnx = mysql.connector.connect(user=user, password=password, host=host)
    cursor = cnx.cursor(buffered=True)
    cursor.execute("USE {}".format(database))

    counter = 1
    
    # for i in range(no_rows):
    while True:
    # random amount
        amount = round(random.uniform(0, 10000), 2)

        # random point of sale
        point_of_sale = "pos{}".format("{:04d}".format(random.randrange(1000)))

        # random customer
        customer = "customer{}".format("{:05d}".format(random.randrange(10000)))

        create_time = time.strftime('%Y-%m-%d %H:%M:%S')
        insert = "INSERT INTO {} (create_time, update_time, customer, amount, point_of_sale) VALUES ('{}', '{}', '{}', {}, '{}')".format(transactions_table, create_time, create_time, customer, amount, point_of_sale)
        cursor.execute(insert)
        cnx.commit()
        print("Inserted and committed rown number {}".format(counter))
        counter += 1
        
    cursor.close()
    cnx.close()

generate_transaction_data()