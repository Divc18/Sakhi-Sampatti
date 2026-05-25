import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'package:flutter/foundation.dart';

class DataProvider {
  static final DataProvider _instance = DataProvider._internal();
  factory DataProvider() => _instance;
  DataProvider._internal();

  final String baseUrl = 'http://127.0.0.1:8000/api';

  late Member currentUser;
  List<SHGGroup> allGroups = [];
  List<Transaction> allTransactions = [];
  List<Loan> allLoans = [];
  List<LoanApplication> loanApplications = [];
  List<Meeting> meetings = [];
  List<NotificationModel> notifications = [];

  List<SHGGroup> get myGroups => allGroups.where((g) => g.isMember).toList();
  List<SHGGroup> get availableGroups => allGroups.where((g) => !g.isMember && !g.isPending).toList();

  String? _userId;

  void setUserId(String id) {
    _userId = id;
  }

  /// Refresh only the current user data from the backend
  Future<void> refreshUser() async {
    final uid = _userId ?? currentUser.id;
    try {
      final userRes = await http.get(Uri.parse('$baseUrl/members/$uid/'));
      if (userRes.statusCode == 200) {
        final userData = json.decode(userRes.body);
        currentUser = Member(
          id: userData['id'],
          name: userData['name'],
          phone: userData['phone'],
          role: userData['role'],
          avatar: userData['avatar'],
          savingsBalance: double.parse(userData['savings_balance'].toString()),
          loanBalance: double.parse(userData['loan_balance'].toString()),
          trustScore: userData['trust_score'] ?? 60,
          isActive: userData['is_active'],
        );
      }
    } catch (e) {
      debugPrint("Error refreshing user: $e");
    }
  }

  Future<void> initData() async {
    final uid = _userId ?? 'u1';
    try {
      // Fetch live user data from backend
      final userRes = await http.get(Uri.parse('$baseUrl/members/$uid/'));
      if (userRes.statusCode == 200) {
        final userData = json.decode(userRes.body);
        currentUser = Member(
          id: userData['id'],
          name: userData['name'],
          phone: userData['phone'],
          role: userData['role'],
          avatar: userData['avatar'],
          savingsBalance: double.parse(userData['savings_balance'].toString()),
          loanBalance: double.parse(userData['loan_balance'].toString()),
          trustScore: userData['trust_score'] ?? 60,
          isActive: userData['is_active'],
        );
      } else {
        currentUser = Member(id: 'u1', name: 'Meena Devi', phone: '+91 98765 43210', role: 'Member', avatar: 'MD', savingsBalance: 4500, loanBalance: 0, isActive: true);
      }

      // Fetch groups with full member details
      final groupsRes = await http.get(Uri.parse('$baseUrl/groups/'));
      if (groupsRes.statusCode == 200) {
        final List data = json.decode(groupsRes.body);
        allGroups = data.map((g) {
          // Parse members from group response
          final membersList = (g['members'] as List? ?? []).map((m) {
            return Member(
              id: m['id'],
              name: m['name'],
              phone: m['phone'],
              role: m['role'],
              avatar: m['avatar'],
              savingsBalance: double.tryParse(m['savings_balance'].toString()) ?? 0,
              loanBalance: double.tryParse(m['loan_balance'].toString()) ?? 0,
              trustScore: m['trust_score'] ?? 60,
              isActive: m['is_active'] ?? true,
            );
          }).toList();

          final isMem = membersList.any((m) => m.id == currentUser.id);

          return SHGGroup(
            id: g['id'],
            name: g['name'],
            category: g['category'],
            location: g['location'],
            description: g['description'],
            bankAccount: g['bank_account'],
            formed: DateTime.parse(g['formed']),
            members: membersList,
            totalSavings: double.tryParse(g['total_savings'].toString()) ?? 0,
            totalLoanGiven: double.tryParse(g['total_loan_given'].toString()) ?? 0,
            totalLoanRepaid: double.tryParse(g['total_loan_repaid'].toString()) ?? 0,
            interestEarned: double.tryParse(g['interest_earned'].toString()) ?? 0,
            isMember: isMem,
            meetingDay: g['meeting_day'],
            meetingFrequency: g['meeting_frequency'],
            monthlySavingsTarget: double.tryParse(g['monthly_savings_target'].toString()) ?? 0,
          );
        }).toList();
      }

      // Fetch all transactions
      final txnsRes = await http.get(Uri.parse('$baseUrl/transactions/'));
      if (txnsRes.statusCode == 200) {
        final List data = json.decode(txnsRes.body);
        allTransactions = data.map((t) {
          return Transaction(
            id: t['id'],
            groupId: t['group'].toString(),
            memberId: t['member'].toString(),
            memberName: t['member_name'] ?? 'Member',
            type: t['type'],
            amount: double.tryParse(t['amount'].toString()) ?? 0,
            date: DateTime.parse(t['date']),
            description: t['description'],
            approvedBy: t['approved_by'],
            receiptNo: t['receipt_no'],
          );
        }).toList();
      }

      // Fetch all loans
      final loansRes = await http.get(Uri.parse('$baseUrl/loans/'));
      if (loansRes.statusCode == 200) {
        final List data = json.decode(loansRes.body);
        allLoans = data.map((l) {
          return Loan(
            id: l['id'],
            groupId: l['group'].toString(),
            memberId: l['member'].toString(),
            memberName: l['member_name'] ?? 'Member',
            principalAmount: double.tryParse(l['principal_amount'].toString()) ?? 0,
            interestRate: double.tryParse(l['interest_rate'].toString()) ?? 0,
            tenureMonths: l['tenure_months'] ?? 6,
            amountRepaid: double.tryParse(l['amount_repaid'].toString()) ?? 0,
            disbursedDate: DateTime.parse(l['disbursed_date']),
            closedDate: l['closed_date'] != null ? DateTime.parse(l['closed_date']) : null,
            status: l['status'] ?? 'active',
            purpose: l['purpose'] ?? '',
            approvedBy: l['approved_by'] ?? '',
          );
        }).toList();
      }

      // Fetch loan applications
      final appsRes = await http.get(Uri.parse('$baseUrl/loan-applications/'));
      if (appsRes.statusCode == 200) {
        final List data = json.decode(appsRes.body);
        loanApplications = data.map((a) {
          return LoanApplication(
            id: a['id'],
            groupId: a['group'].toString(),
            applicantId: a['applicant'].toString(),
            applicantName: a['applicant_name'] ?? 'Member',
            requestedAmount: double.tryParse(a['requested_amount'].toString()) ?? 0,
            tenureMonths: a['tenure_months'] ?? 6,
            purpose: a['purpose'] ?? '',
            appliedDate: DateTime.parse(a['applied_date']),
            status: a['status'] ?? 'pending',
            rejectionReason: a['rejection_reason'],
          );
        }).toList();
      }

      // Fetch meetings
      final meetingsRes = await http.get(Uri.parse('$baseUrl/meetings/'));
      if (meetingsRes.statusCode == 200) {
        final List data = json.decode(meetingsRes.body);
        meetings = data.map((m) {
          return Meeting(
            id: m['id'],
            groupId: m['group'].toString(),
            date: DateTime.parse(m['date']),
            attendees: List<String>.from(m['attendees'] ?? []),
            totalCollected: double.tryParse(m['total_collected'].toString()) ?? 0,
            minutesSummary: m['minutes_summary'] ?? '',
            agendaItems: (m['agenda_items'] as List?)?.map((a) => a['item'].toString()).toList() ?? [],
            isCompleted: m['is_completed'] ?? false,
          );
        }).toList();
      }

      // Fetch notifications
      final notifsRes = await http.get(Uri.parse('$baseUrl/notifications/'));
      if (notifsRes.statusCode == 200) {
        final List data = json.decode(notifsRes.body);
        notifications = data
            .where((n) => n['member'] == currentUser.id)
            .map((n) {
              return NotificationModel(
                id: n['id'],
                title: n['title'],
                message: n['message'],
                type: n['type'],
                isRead: n['is_read'],
                createdAt: DateTime.parse(n['created_at']),
              );
            })
            .toList();
      }

    } catch (e) {
      debugPrint("Error fetching from API: $e");
      // Fallback to empty if fails
      allGroups = [];
      allTransactions = [];
      allLoans = [];
      loanApplications = [];
      meetings = [];
      notifications = [];
    }
  }

  // Helper methods
  List<Transaction> transactionsForGroup(String groupId) => allTransactions.where((t) => t.groupId == groupId).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<Transaction> transactionsForMember(String memberId) => allTransactions.where((t) => t.memberId == memberId).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<Loan> loansForGroup(String groupId) => allLoans.where((l) => l.groupId == groupId).toList();
  List<Loan> loansForMember(String memberId) => allLoans.where((l) => l.memberId == memberId).toList();
  List<Meeting> meetingsForGroup(String groupId) => meetings.where((m) => m.groupId == groupId).toList()..sort((a, b) => b.date.compareTo(a.date));

  void joinGroup(String groupId) {
    final idx = allGroups.indexWhere((g) => g.id == groupId);
    if (idx != -1) allGroups[idx].isPending = true;
  }

  void addTransaction(Transaction t) {
    allTransactions.insert(0, t);
  }

  void addLoanApplication(LoanApplication app) {
    loanApplications.insert(0, app);
  }

  void approveLoan(String appId) {
    final aIdx = loanApplications.indexWhere((a) => a.id == appId);
    if (aIdx != -1) {
      loanApplications[aIdx].status = 'approved';
    }
  }
}
