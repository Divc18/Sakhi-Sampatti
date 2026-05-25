from django.contrib import admin
from .models import Member, SHGGroup, Transaction, Loan, Meeting, AgendaItem, LoanApplication, Notification

# Register all models for admin panel visibility
admin.site.register(Member)
admin.site.register(SHGGroup)
admin.site.register(Transaction)
admin.site.register(Loan)
admin.site.register(Meeting)
admin.site.register(AgendaItem)
admin.site.register(LoanApplication)
admin.site.register(Notification)
