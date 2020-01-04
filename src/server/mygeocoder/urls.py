from django.urls import path, include
from rest_framework import routers
from . import views


router = routers.DefaultRouter()
router.register(r'addresses', views.AddressViewSet)

urlpatterns = [
    path('search/', views.SearchView.as_view()),
    path('geocode_address/', views.SearchView.geocode_address),
    path('', include(router.urls)),
]