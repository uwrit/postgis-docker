import psycopg2
import json
import os
import sys
import time

from psycopg2 import pool

class PostgisConnector:

    def __init__(self):
        self.host = 'postgis-docker_db_1'
        self.user = os.environ['POSTGRES_USER']
        self.pwd = os.environ['POSTGRES_PASSWORD']
        self.db = os.environ['POSTGRES_DB']
        
    def __get_pool(self):
        self.pool = psycopg2.pool.SimpleConnectionPool(1, 20,
                                host=self.host,
                                database=self.db,
                                user=self.user,
                                password=self.pwd)

    def __get_connection(self):
        if not self.pool:
            self.__get_pool()
        return self.pool.getconn()

    def __close_connection(self, conn):
        self.pool.putconn(conn)
    
    def get_lat_long(self, addr):

        conn = self.__get_connection()
        with conn.cursor() as cursor:
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
                FROM geocode(%(addr)s) As g;
            """, {
                'addr': addr
            })
            result = cursor.fetchone()
        self.__close_connection(conn)

        if result is None:
            return None

        # Remove text and split into len-2 array
        latlong = result[1].replace('POINT(','').replace(')','',).split(' ')

        output = {
            'lat': float(latlong[1]),
            'long': float(latlong[0]),
            'building': result[2],
            'street': result[3],
            'streetType': result[4],
            'city': result[5],
            'state': result[6],
            'zip': result[7]
        }

        return output