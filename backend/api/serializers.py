from rest_framework import serializers
from .models import Member, SHGGroup, Transaction, Loan, Meeting, AgendaItem, LoanApplication, Notification

class MemberSerializer(serializers.ModelSerializer):
    trust_score = serializers.IntegerField(read_only=True)
    class Meta:
        model = Member
        fields = '__all__'

class SHGGroupSerializer(serializers.ModelSerializer):
    members = MemberSerializer(many=True, read_only=True)
    member_count = serializers.SerializerMethodField()

    class Meta:
        model = SHGGroup
        fields = '__all__'
    
    def get_member_count(self, obj):
        return obj.members.count()

class TransactionSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.name', read_only=True)
    
    class Meta:
        model = Transaction
        fields = '__all__'

class LoanSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.name', read_only=True)

    class Meta:
        model = Loan
        fields = '__all__'

class AgendaItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = AgendaItem
        fields = ['item']

class MeetingSerializer(serializers.ModelSerializer):
    agenda_items = AgendaItemSerializer(many=True, read_only=True)
    attendees = serializers.SlugRelatedField(many=True, slug_field='id', read_only=True)

    class Meta:
        model = Meeting
        fields = '__all__'

class LoanApplicationSerializer(serializers.ModelSerializer):
    applicant_name = serializers.CharField(source='applicant.name', read_only=True)

    class Meta:
        model = LoanApplication
        fields = '__all__'

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
