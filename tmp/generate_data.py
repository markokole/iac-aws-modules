import boto3
import json
import pymysql
import logging

class Generate_data:
    def __init__(self, secret_name, database_name):
        self.secret_name = secret_name
        self.database_name = database_name
        self.host = ""
        self.user = ""
        self.passwd = ""
        self.conn = ""
        pymysql.install_as_MySQLdb()
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
    
    def secret(self):
        region_name = "eu-west-1"
        # Create a Secrets Manager client
        session = boto3.session.Session()
        client = session.client(
                service_name='secretsmanager',
                region_name=region_name
        )
        get_secret_value_response = client.get_secret_value(
            SecretId=self.secret_name
        )
    
        secret_json = json.loads(get_secret_value_response['SecretString'])
        self.host = secret_json['host']
        self.user = secret_json['username']
        self.passwd = secret_json['password']

    def connect(self):
        try:
            self.conn = pymysql.connect(host=self.host, user=self.user, passwd=self.passwd, connect_timeout=5)
        except pymysql.MySQLError as e:
            self.logger.error("Could not connect to the instance!")
            self.logger.error(e)

    def cursor(self):
        self.cursor = self.conn.cursor()
        
    def create_database(self):
        sql = "CREATE DATABASE IF NOT EXISTS {}".format(self.database_name)
        out = self.cursor.execute(sql)
        if out == 1:
            self.logger.info("Database {} created or already exists.".format(self.database_name))
        else:
            self.logger.error("Database {} not created!".format(self.database_name))

    def create_table(self, table_name, create_table_sql):
        self.cursor.execute(create_table_sql)