from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MemberViewSet, SHGGroupViewSet, TransactionViewSet,
    LoanViewSet, MeetingViewSet, LoanApplicationViewSet, NotificationViewSet
)

router = DefaultRouter()
router.register(r'members', MemberViewSet)
router.register(r'groups', SHGGroupViewSet)
router.register(r'transactions', TransactionViewSet)
router.register(r'loans', LoanViewSet)
router.register(r'meetings', MeetingViewSet)
router.register(r'loan-applications', LoanApplicationViewSet)
router.register(r'notifications', NotificationViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
