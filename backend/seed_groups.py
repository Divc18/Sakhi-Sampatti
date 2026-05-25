import os
import django
import sys
from datetime import date

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import SHGGroup

groups_data = [
    {
        "id": "g_2",
        "name": "Pragati Women's SHG",
        "category": "Women",
        "location": "Pune, Maharashtra",
        "description": "Empowering rural women through collective savings and micro-enterprises.",
        "bank_account": "SBI-9988776655",
        "formed": date(2022, 5, 10),
        "total_savings": 150000.00,
        "total_loan_given": 80000.00,
        "total_loan_repaid": 50000.00,
        "interest_earned": 8500.00,
        "meeting_day": "Tuesday",
        "meeting_frequency": "Weekly",
        "monthly_savings_target": 2000.00,
    },
    {
        "id": "g_3",
        "name": "Kisan Vikas Samiti",
        "category": "Farmers",
        "location": "Nashik, Maharashtra",
        "description": "A collective of farmers sharing resources for modern agriculture and crop loans.",
        "bank_account": "HDFC-11223344",
        "formed": date(2021, 11, 20),
        "total_savings": 320000.00,
        "total_loan_given": 250000.00,
        "total_loan_repaid": 200000.00,
        "interest_earned": 24000.00,
        "meeting_day": "1st of Month",
        "meeting_frequency": "Monthly",
        "monthly_savings_target": 5000.00,
    },
    {
        "id": "g_4",
        "name": "Yuva Shakti Innovators",
        "category": "Youth",
        "location": "Bangalore, Karnataka",
        "description": "Tech-savvy youth pooling funds for startup capital and skill development.",
        "bank_account": "ICICI-55443322",
        "formed": date(2023, 1, 15),
        "total_savings": 80000.00,
        "total_loan_given": 30000.00,
        "total_loan_repaid": 10000.00,
        "interest_earned": 1200.00,
        "meeting_day": "Sunday",
        "meeting_frequency": "Bi-Weekly",
        "monthly_savings_target": 1500.00,
    },
    {
        "id": "g_5",
        "name": "Sahayog Mixed Enterprise",
        "category": "Mixed",
        "location": "Indore, MP",
        "description": "Community group focused on local commerce and retail store funding.",
        "bank_account": "BOI-99008877",
        "formed": date(2020, 8, 5),
        "total_savings": 500000.00,
        "total_loan_given": 400000.00,
        "total_loan_repaid": 350000.00,
        "interest_earned": 45000.00,
        "meeting_day": "Friday",
        "meeting_frequency": "Weekly",
        "monthly_savings_target": 3000.00,
    }
]

for g_data in groups_data:
    group, created = SHGGroup.objects.get_or_create(
        id=g_data["id"],
        defaults=g_data
    )
    if created:
        print(f"Created group: {group.name}")
    else:
        print(f"Group already exists: {group.name}")

print("Done injecting groups.")
