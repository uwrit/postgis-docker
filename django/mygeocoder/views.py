from django.http import HttpResponse, JsonResponse
from django.db import connection
from django.shortcuts import render
from django.views import View
from rest_framework import viewsets
from mygeocoder.GeocodedAddressSerializer import *
from mygeocoder.models import *


class AddressViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = Address.objects.all()
    serializer_class = AddressSerializer


class SearchView(View):
    template_name = 'geocode.html'

    # def get(self, request, *args, **kwargs):
    #     q = (request.GET.get('q') or '').strip()
    #     address_obj, created = Address.objects.get_or_create(raw_text=q)
    #     if address_obj is None:
    #         context = {
    #             'result': 'Address could not be parsed',
    #         }
    #     else:
    #         context = {
    #             'result': address_obj.latlong_text
    #         }
    #
    #     return render(request, self.template_name, context)

    def geocode_address(request):
        q = (request.GET.get('q') or '').strip()
        print(q)
        address_obj, created = Address.objects.get_or_create(raw_text=q)
        print(address_obj)
        address_obj.geocode()
        http_response_status = (200 if address_obj.geocode_complete_success() else 206)
        serializer = AddressSerializer(address_obj)
        return JsonResponse(serializer.data, status=http_response_status)
