from mygeocoder.models import Address
from rest_framework import serializers



class AddressSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Address
        fields = ['raw_text',
                  'street_number',
                  'street_name',
                  'street_type',
                  'unit_number',
                  'city',
                  'state',
                  'zip_code',
                  'latlong_text',
                  'latitude',
                  'longitude']

