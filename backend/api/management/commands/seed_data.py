from django.core.management.base import BaseCommand
from api.models import Member, SHGGroup, Transaction, Loan, Meeting
from django.utils import timezone
from datetime import timedelta

class Command(BaseCommand):
    help = 'Seed database with initial SHG data'

    def handle(self, *args, **kwargs):
        Member.objects.all().delete()
        SHGGroup.objects.all().delete()
        Transaction.objects.all().delete()
        Loan.objects.all().delete()
        Meeting.objects.all().delete()

        # Members
        m1 = Member.objects.create(id='g1m1', name='Sunita Sharma', phone='98001', role='President', avatar='SS', savings_balance=6000)
        m2 = Member.objects.create(id='g1m2', name='Radha Patel', phone='98002', role='Secretary', avatar='RP', savings_balance=5500)
        m3 = Member.objects.create(id='g1m3', name='Gita Yadav', phone='98003', role='Treasurer', avatar='GY', savings_balance=5000, loan_balance=3000)
        m4 = Member.objects.create(id='g1m4', name='Priya Singh', phone='98004', role='Member', avatar='PS', savings_balance=4800)
        m5 = Member.objects.create(id='u1', name='Meena Devi', phone='98765', role='Member', avatar='MD', savings_balance=4500)

        # Groups
        g1 = SHGGroup.objects.create(
            id='g1', name='Mahila Shakti Mandal', category='Women', location='Ward 4, Pune',
            description='Empowering women through micro-finance and skill development since 2019.',
            bank_account='SBI - XXXXXX4521', formed=timezone.now().date() - timedelta(days=1500),
            total_savings=48500, total_loan_given=25000, total_loan_repaid=18000, interest_earned=2400,
            meeting_day='Sunday', meeting_frequency='Monthly', monthly_savings_target=500
        )
        g1.members.add(m1, m2, m3, m4, m5)

        g2 = SHGGroup.objects.create(
            id='g2', name='Nav Chetna Bachat Gat', category='Women', location='Kothrud, Pune',
            description='A vibrant group focused on women entrepreneurship and savings culture.',
            bank_account='BOI - XXXXXX7834', formed=timezone.now().date() - timedelta(days=1000),
            total_savings=62000, total_loan_given=40000, total_loan_repaid=30000, interest_earned=4500,
            meeting_day='Saturday', meeting_frequency='Monthly', monthly_savings_target=500
        )
        
        # Transactions
        Transaction.objects.create(id='t1', group=g1, member=m5, type='savings_deposit', amount=500, description='Monthly savings - March', approved_by='Radha Patel', receipt_no='RCP0023', date=timezone.now() - timedelta(days=2))
        Transaction.objects.create(id='t2', group=g1, member=m3, type='loan_disbursal', amount=5000, description='Loan for business', approved_by='Secretary', receipt_no='RCP0022', date=timezone.now() - timedelta(days=5))
        Transaction.objects.create(id='t3', group=g1, member=m3, type='loan_repayment', amount=2000, description='EMI payment', approved_by='Sunita', receipt_no='RCP0021', date=timezone.now() - timedelta(days=10))

        # Meetings
        Meeting.objects.create(id='m1', group=g1, date=timezone.now() + timedelta(days=28), total_collected=0, is_completed=False)

        self.stdout.write(self.style.SUCCESS('Successfully seeded data'))
