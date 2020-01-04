import psycopg2
import json
import os
import sys

from datetime import datetime

class PostgisConnector:

    def __init__(self):
        self.host = 'postgis-docker_db_1'
        self.user = os.environ['POSTGRES_USER']
        self.pwd = os.environ['POSTGRES_PASSWORD']
        self.db = os.environ['POSTGRES_DB']
        self.conn = psycopg2.connect(host=self.host,
                                     database=self.db,
                                     user=self.user,
                                     password=self.pwd)
        self.conn.set_session(autocommit=True)

    def get_lat_long(self, var_address):

        with self.conn.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    g.rating
                  , ST_AsText(ST_SnapToGrid(g.geomout,0.00001)) As wktlonlat
                  , (addy).address As stno
                  , (addy).streetname As street
                  , (addy).streettypeabbrev As styp
                  , (addy).location As city
                  , (addy).stateabbrev As st
                  , (addy).zip
                FROM geocode(%(var_address)s) As g;
            """, {
                'var_address': var_address
            })
            result = cursor.fetchone()

        if result is None:
            return None

        sys.stdout.write(result)
        wktlonlat, = result
        return json.loads(wktlonlat)
    