from django.db import models
from django.utils import timezone

class Member(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20)
    role = models.CharField(max_length=50) # 'President', 'Secretary', 'Treasurer', 'Member'
    avatar = models.CharField(max_length=10)
    savings_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    loan_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    password = models.CharField(max_length=128, default='123456')
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

    @property
    def trust_score(self):
        # Realistic Trust Score Calculation (max 100)
        # Base score starts at 50
        base_score = 50
        
        # Add points for savings (1 point per 1000 saved, max 20)
        savings_points = min(20, int(float(self.savings_balance) / 1000))
        
        # Debt management points (max 20)
        debt_ratio = float(self.loan_balance) / float(self.savings_balance) if self.savings_balance > 0 else 0
        if debt_ratio == 0:
            debt_points = 20
        elif debt_ratio < 1:
            debt_points = 15
        elif debt_ratio < 2:
            debt_points = 10
        else:
            debt_points = 0
            
        # Active participation points (based on transactions, max 10)
        tx_count = self.transaction_set.count()
        tx_points = min(10, tx_count * 2)
        
        return base_score + savings_points + debt_points + tx_points

class SHGGroup(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=150)
    category = models.CharField(max_length=50) # 'Women', 'Farmers', 'Youth', 'Mixed'
    location = models.CharField(max_length=200)
    description = models.TextField()
    bank_account = models.CharField(max_length=50)
    formed = models.DateField()
    total_savings = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_loan_given = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_loan_repaid = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    interest_earned = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    meeting_day = models.CharField(max_length=20)
    meeting_frequency = models.CharField(max_length=20)
    monthly_savings_target = models.DecimalField(max_digits=10, decimal_places=2)
    members = models.ManyToManyField(Member, related_name='groups')

    def __str__(self):
        return self.name

class Transaction(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    group = models.ForeignKey(SHGGroup, on_delete=models.CASCADE)
    member = models.ForeignKey(Member, on_delete=models.CASCADE)
    type = models.CharField(max_length=50) # savings_deposit, loan_repayment, etc.
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(default=timezone.now)
    description = models.TextField()
    approved_by = models.CharField(max_length=100)
    receipt_no = models.CharField(max_length=50)

    def __str__(self):
        return f"{self.type} - {self.amount}"

class Loan(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    group = models.ForeignKey(SHGGroup, on_delete=models.CASCADE)
    member = models.ForeignKey(Member, on_delete=models.CASCADE)
    principal_amount = models.DecimalField(max_digits=12, decimal_places=2)
    interest_rate = models.DecimalField(max_digits=5, decimal_places=2)
    tenure_months = models.IntegerField()
    amount_repaid = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    disbursed_date = models.DateTimeField(default=timezone.now)
    closed_date = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=20) # active, closed, overdue
    purpose = models.TextField()
    approved_by = models.CharField(max_length=100)

class Meeting(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    group = models.ForeignKey(SHGGroup, on_delete=models.CASCADE)
    date = models.DateTimeField()
    attendees = models.ManyToManyField(Member, related_name='meetings_attended')
    total_collected = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    minutes_summary = models.TextField(blank=True)
    is_completed = models.BooleanField(default=False)

class AgendaItem(models.Model):
    meeting = models.ForeignKey(Meeting, related_name='agenda_items', on_delete=models.CASCADE)
    item = models.CharField(max_length=200)

class LoanApplication(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    group = models.ForeignKey(SHGGroup, on_delete=models.CASCADE)
    applicant = models.ForeignKey(Member, on_delete=models.CASCADE)
    requested_amount = models.DecimalField(max_digits=12, decimal_places=2)
    tenure_months = models.IntegerField()
    purpose = models.TextField()
    applied_date = models.DateTimeField(default=timezone.now)
    status = models.CharField(max_length=20, default='pending') # pending, approved, rejected
    rejection_reason = models.TextField(null=True, blank=True)

class Notification(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=150)
    message = models.TextField()
    type = models.CharField(max_length=50) # alert, success, warning
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return self.title

class OTP(models.Model):
    phone = models.CharField(max_length=20)
    otp_code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_verified = models.BooleanField(default=False)
    attempts = models.IntegerField(default=0)

    def is_expired(self):
        from datetime import timedelta
        return timezone.now() > self.created_at + timedelta(minutes=5)

    def __str__(self):
        return f"OTP for {self.phone}: {self.otp_code}"
