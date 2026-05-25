// ─── SHG Member ───────────────────────────────────────────────────────────────
export 'notification_model.dart';
class Member {
  final String id;
  final String name;
  final String phone;
  final String role; // 'President', 'Secretary', 'Treasurer', 'Member'
  final String avatar;
  final double savingsBalance;
  final double loanBalance;
  final int trustScore;
  bool isActive;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.avatar,
    this.savingsBalance = 0,
    this.loanBalance = 0,
    this.trustScore = 100,
    this.isActive = true,
  });
}

// ─── SHG Group ────────────────────────────────────────────────────────────────
class SHGGroup {
  final String id;
  final String name;
  final String category; // 'Women', 'Farmers', 'Youth', 'Mixed'
  final String location;
  final String description;
  final String bankAccount;
  final DateTime formed;
  final List<Member> members;
  double totalSavings;
  double totalLoanGiven;
  double totalLoanRepaid;
  double interestEarned;
  bool isMember;
  bool isPending;
  final String meetingDay; // 'Monday', 'Tuesday' etc
  final String meetingFrequency; // 'Weekly', 'Monthly', 'Fortnightly'
  final double monthlySavingsTarget;

  SHGGroup({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.bankAccount,
    required this.formed,
    required this.members,
    this.totalSavings = 0,
    this.totalLoanGiven = 0,
    this.totalLoanRepaid = 0,
    this.interestEarned = 0,
    this.isMember = false,
    this.isPending = false,
    required this.meetingDay,
    required this.meetingFrequency,
    required this.monthlySavingsTarget,
  });

  int get memberCount => members.length;
  double get loanOutstanding => totalLoanGiven - totalLoanRepaid;
  double get fundBalance => totalSavings + interestEarned - loanOutstanding;
}

// ─── Transaction ──────────────────────────────────────────────────────────────
class Transaction {
  final String id;
  final String groupId;
  final String memberId;
  final String memberName;
  final String
  type; // 'savings_deposit', 'savings_withdrawal', 'loan_disbursal', 'loan_repayment', 'fine', 'interest'
  final double amount;
  final DateTime date;
  final String description;
  final String approvedBy;
  final String receiptNo;

  Transaction({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.approvedBy,
    required this.receiptNo,
  });

  bool get isCredit =>
      ['savings_deposit', 'loan_repayment', 'interest'].contains(type);

  String get typeLabel {
    switch (type) {
      case 'savings_deposit':
        return 'Savings Deposit';
      case 'savings_withdrawal':
        return 'Savings Withdrawal';
      case 'loan_disbursal':
        return 'Loan Disbursed';
      case 'loan_repayment':
        return 'Loan Repayment';
      case 'fine':
        return 'Fine Collected';
      case 'interest':
        return 'Interest Earned';
      default:
        return type;
    }
  }
}

// ─── Loan ─────────────────────────────────────────────────────────────────────
class Loan {
  final String id;
  final String groupId;
  final String memberId;
  final String memberName;
  final double principalAmount;
  final double interestRate; // per month %
  final int tenureMonths;
  double amountRepaid;
  final DateTime disbursedDate;
  DateTime? closedDate;
  String status; // 'active', 'closed', 'overdue', 'pending'
  final String purpose;
  final String approvedBy;

  Loan({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.memberName,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    this.amountRepaid = 0,
    required this.disbursedDate,
    this.closedDate,
    required this.status,
    required this.purpose,
    required this.approvedBy,
  });

  double get totalInterest =>
      principalAmount * interestRate / 100 * tenureMonths;
  double get totalPayable => principalAmount + totalInterest;
  double get outstanding => totalPayable - amountRepaid;
  double get emiAmount => totalPayable / tenureMonths;
}

// ─── Meeting ──────────────────────────────────────────────────────────────────
class Meeting {
  final String id;
  final String groupId;
  final DateTime date;
  final List<String> attendees;
  final double totalCollected;
  final String minutesSummary;
  final List<String> agendaItems;
  bool isCompleted;

  Meeting({
    required this.id,
    required this.groupId,
    required this.date,
    required this.attendees,
    required this.totalCollected,
    required this.minutesSummary,
    required this.agendaItems,
    this.isCompleted = false,
  });
}

// ─── Loan Application ─────────────────────────────────────────────────────────
class LoanApplication {
  final String id;
  final String groupId;
  final String applicantId;
  final String applicantName;
  final double requestedAmount;
  final int tenureMonths;
  final String purpose;
  final DateTime appliedDate;
  String status; // 'pending', 'approved', 'rejected'
  String? rejectionReason;

  LoanApplication({
    required this.id,
    required this.groupId,
    required this.applicantId,
    required this.applicantName,
    required this.requestedAmount,
    required this.tenureMonths,
    required this.purpose,
    required this.appliedDate,
    this.status = 'pending',
    this.rejectionReason,
  });
}
