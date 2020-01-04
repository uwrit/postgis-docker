from django.db import models
from django.db import connection


# Create your models here.
class Address(models.Model):
    raw_text = models.CharField(max_length=256)
    street_number = models.CharField(max_length=16)
    street_name = models.CharField(max_length=128)
    street_type = models.CharField(max_length=32)
    unit_number = models.CharField(max_length=16)
    city = models.CharField(max_length=32)
    state = models.CharField(max_length=2)
    zip_code = models.CharField(max_length=16)
    latlong_text = models.CharField(max_length=128)
    latitude = models.CharField(max_length=16)
    longitude = models.CharField(max_length=16)

    def geocode(self):
        sql = """
        SELECT g.rating, ST_AsText(ST_SnapToGrid(g.geomout,0.00001)) As wktlonlat, 
                ST_X(ST_SnapToGrid(g.geomout,0.00001)) As longitude,
                ST_Y(ST_SnapToGrid(g.geomout,0.00001)) As latitude,
                (addy).address As stno,
                (addy).streetname As street, (addy).streettypeabbrev As styp, (addy).location As city, (addy).stateabbrev As st,(addy).zip
        FROM geocode(%(address)s,1) As g;
        """

        print(sql)

        with connection.cursor() as cursor:
            cursor.execute(sql, {'address': self.raw_text})
            rows = cursor.fetchall()

        print(rows)

        if (len(rows) > 0):
            result = rows[0]
            print(rows[0])
            self.latlong_text = rows[0][1] or ""
            self.longitude = rows[0][2] or ""
            self.latitude = rows[0][3] or ""
            self.street_number = rows[0][4] or ""
            self.street_name = rows[0][5] or ""
            self.street_type = rows[0][6] or ""
            self.city = rows[0][7] or ""
            self.state = rows[0][8] or ""
            self.zip_code = rows[0][9] or ""
        else:
            self.latlong_text = ""

        print(self.latlong_text)
        self.save()

    def geocode_complete_success(self):
        print(1)
        response = True
        if self.latitude == "" or \
                self.longitude == "" or \
                self.latlong_text == "" or \
                self.street_number == "" or \
                self.city == "" or \
                self.state == "" or \
                self.zip_code == "":
            print(2)
            response = False
        print(3)
        return response
