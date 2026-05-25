import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';
import 'widgets/transaction_tile.dart';

class GroupDetailScreen extends StatefulWidget {
  final SHGGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  final dp = DataProvider();
  late TabController _tab;
  late SHGGroup group;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    group = widget.group;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            title: Text(group.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            bottom: TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                  fontSize: 13),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Members'),
                Tab(text: 'Savings'),
                Tab(text: 'Loans'),
                Tab(text: 'Meetings'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _OverviewTab(group: group),
            _MembersTab(group: group),
            _SavingsTab(group: group, dp: dp, onRefresh: () => setState(() {})),
            _LoansTab(group: group, dp: dp, onRefresh: () => setState(() {})),
            _MeetingsTab(group: group, dp: dp),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF33691E)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${group.memberCount} Members',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(group.location,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── OVERVIEW TAB ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final SHGGroup group;
  const _OverviewTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fund Summary Card
          _SummaryCard(group: group),
          const SizedBox(height: 16),

          // About
          _Section(
              title: 'About',
              child: Text(group.description,
                  style: const TextStyle(
                      color: AppTheme.textMid, fontSize: 14, height: 1.6))),
          const SizedBox(height: 16),

          // Details
          _Section(
            title: 'Group Details',
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Formed',
                    value:
                        '${group.formed.day}/${group.formed.month}/${group.formed.year}'),
                _DetailRow(
                    icon: Icons.account_balance_rounded,
                    label: 'Bank Account',
                    value: group.bankAccount),
                _DetailRow(
                    icon: Icons.event_repeat_rounded,
                    label: 'Meeting',
                    value: '${group.meetingFrequency} on ${group.meetingDay}'),
                _DetailRow(
                    icon: Icons.savings_rounded,
                    label: 'Monthly Target',
                    value: '₹${group.monthlySavingsTarget.toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fund Breakdown
          _Section(
            title: 'Fund Breakdown',
            child: Column(
              children: [
                _ProgressRow(
                    label: 'Total Savings',
                    amount: group.totalSavings,
                    max: group.totalSavings,
                    color: AppTheme.success),
                const SizedBox(height: 10),
                _ProgressRow(
                    label: 'Loans Given',
                    amount: group.totalLoanGiven,
                    max: group.totalSavings,
                    color: AppTheme.warning),
                const SizedBox(height: 10),
                _ProgressRow(
                    label: 'Loan Repaid',
                    amount: group.totalLoanRepaid,
                    max: group.totalLoanGiven == 0 ? 1 : group.totalLoanGiven,
                    color: AppTheme.info),
                const SizedBox(height: 10),
                _ProgressRow(
                    label: 'Interest Earned',
                    amount: group.interestEarned,
                    max: group.totalSavings,
                    color: AppTheme.accent),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final SHGGroup group;
  const _SummaryCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primarySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Group Fund Balance',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '₹${group.fundBalance.toStringAsFixed(0)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _FundStat(
                      'Savings', '₹${group.totalSavings.toStringAsFixed(0)}')),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                  child: _FundStat('Loan Out',
                      '₹${group.loanOutstanding.toStringAsFixed(0)}')),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                  child: _FundStat('Interest',
                      '₹${group.interestEarned.toStringAsFixed(0)}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FundStat extends StatelessWidget {
  final String label, value;
  const _FundStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      );
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double amount, max;
  final Color color;
  const _ProgressRow(
      {required this.label,
      required this.amount,
      required this.max,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = max == 0 ? 0.0 : (amount / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMid,
                      fontWeight: FontWeight.w600))),
          Text('₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── MEMBERS TAB ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final SHGGroup group;
  const _MembersTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: group.members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = group.members[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.12),
                child: Text(m.avatar,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(m.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textDark)),
                      const SizedBox(width: 8),
                      if (m.role != 'Member') _RoleBadge(m.role),
                    ]),
                    Text(m.phone,
                        style: const TextStyle(
                            color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${m.savingsBalance.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppTheme.success)),
                  const Text('Savings',
                      style:
                          TextStyle(color: AppTheme.textLight, fontSize: 11)),
                  if (m.loanBalance > 0) ...[
                    Text('₹${m.loanBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppTheme.warning)),
                    const Text('Loan',
                        style:
                            TextStyle(color: AppTheme.textLight, fontSize: 11)),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);

  @override
  Widget build(BuildContext context) {
    final map = {
      'President': AppTheme.accent,
      'Secretary': AppTheme.info,
      'Treasurer': AppTheme.success,
    };
    final color = map[role] ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5)),
      child: Text(role,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── SAVINGS TAB ──────────────────────────────────────────────────────────────

class _SavingsTab extends StatelessWidget {
  final SHGGroup group;
  final DataProvider dp;
  final VoidCallback onRefresh;
  const _SavingsTab(
      {required this.group, required this.dp, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final txns = dp
        .transactionsForGroup(group.id)
        .where((t) =>
            t.type == 'savings_deposit' || t.type == 'savings_withdrawal')
        .toList();

    return Column(
      children: [
        // My Savings Card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.success, AppTheme.success.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('My Savings Balance',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${dp.currentUser.savingsBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Monthly target: ₹${group.monthlySavingsTarget.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addSavings(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Deposit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Transactions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Savings Transactions',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: txns.isEmpty
              ? const Center(
                  child: Text('No savings transactions',
                      style: TextStyle(color: AppTheme.textLight)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: txns.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppTheme.divider, height: 1),
                  itemBuilder: (_, i) => TransactionTile(transaction: txns[i]),
                ),
        ),
      ],
    );
  }

  void _addSavings(BuildContext ctx) {
    final _amtCtrl = TextEditingController();
    final _descCtrl = TextEditingController(text: 'Monthly savings');
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deposit Savings',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 16),
              TextField(
                controller: _amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.note_rounded)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(_amtCtrl.text);
                    if (amt == null || amt <= 0) return;
                    
                    // Show loading indicator in a dialog
                    showDialog(context: ctx, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.success)));

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/members/${dp.currentUser.id}/smart_deposit/'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'amount': amt, 'group_id': group.id}),
                      );

                      Navigator.pop(ctx); // pop loading
                      if (response.statusCode == 200) {
                        await dp.initData(); // Refresh all data from API
                        onRefresh();
                        Navigator.pop(modalCtx); // pop bottom sheet
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('₹${amt.toStringAsFixed(0)} deposited successfully!'),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else {
                        throw Exception('Failed to deposit');
                      }
                    } catch (e) {
                      Navigator.pop(ctx); // pop loading
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Error connecting to server.'), backgroundColor: AppTheme.error),
                      );
                    }
                  },
                  child: const Text('Confirm Deposit'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── LOANS TAB ────────────────────────────────────────────────────────────────

class _LoansTab extends StatelessWidget {
  final SHGGroup group;
  final DataProvider dp;
  final VoidCallback onRefresh;
  const _LoansTab(
      {required this.group, required this.dp, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final loans = dp.loansForGroup(group.id);
    final applications =
        dp.loanApplications.where((a) => a.groupId == group.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apply for Loan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _applyLoan(context),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Apply for Loan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pending Applications
          if (applications.isNotEmpty) ...[
            const Text('Loan Applications',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 10),
            ...applications.map((a) =>
                _LoanApplicationCard(app: a, dp: dp, onRefresh: onRefresh)),
            const SizedBox(height: 20),
          ],

          // Active Loans
          const Text('Loans',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 10),
          if (loans.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider)),
              child: const Center(
                  child: Text('No loans yet',
                      style: TextStyle(color: AppTheme.textLight))),
            )
          else
            ...loans
                .map((l) => _LoanCard(loan: l, dp: dp, onRefresh: onRefresh)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _applyLoan(BuildContext ctx) {
    final _amtCtrl = TextEditingController();
    final _tenureCtrl = TextEditingController(text: '6');
    final _purposeCtrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apply for Loan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                    'Interest rate: 2% per month. Max loan: 3x your savings.',
                    style: TextStyle(color: AppTheme.info, fontSize: 13)),
              ),
              TextField(
                  controller: _amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Loan Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee_rounded))),
              const SizedBox(height: 12),
              TextField(
                  controller: _tenureCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Tenure (months)',
                      prefixIcon: Icon(Icons.calendar_today_rounded))),
              const SizedBox(height: 12),
              TextField(
                  controller: _purposeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Purpose of loan',
                      prefixIcon: Icon(Icons.info_outline_rounded))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(_amtCtrl.text);
                    final tenure = int.tryParse(_tenureCtrl.text);
                    if (amt == null || tenure == null || _purposeCtrl.text.isEmpty) return;

                    // Loading
                    showDialog(context: ctx, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)));

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/members/${dp.currentUser.id}/apply_smart_loan/'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({
                          'amount': amt,
                          'group_id': group.id,
                          'purpose': _purposeCtrl.text,
                          'tenure_months': tenure
                        }),
                      );

                      Navigator.pop(ctx); // close loading
                      final data = json.decode(response.body);

                      if (response.statusCode == 200) {
                        await dp.initData(); // Refresh local store from API
                        onRefresh();
                        Navigator.pop(modalCtx); // close bottom sheet
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(data['message'] ?? 'Smart Loan disbursed!'),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(data['error'] ?? 'Loan rejected by AI Model.'),
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(ctx); // pop loading
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Error connecting to server.'), backgroundColor: AppTheme.error),
                      );
                    }
                  },
                  child: const Text('Submit Smart Loan Application'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanApplicationCard extends StatelessWidget {
  final LoanApplication app;
  final DataProvider dp;
  final VoidCallback onRefresh;
  const _LoanApplicationCard(
      {required this.app, required this.dp, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final statusColor = {
          'pending': AppTheme.warning,
          'approved': AppTheme.success,
          'rejected': AppTheme.error,
        }[app.status] ??
        AppTheme.textMid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                      '₹${app.requestedAmount.toStringAsFixed(0)} • ${app.tenureMonths} months',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textDark))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(app.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Purpose: ${app.purpose}',
              style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
          Text(
              'Applied: ${app.appliedDate.day}/${app.appliedDate.month}/${app.appliedDate.year}',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
          // Treasurer can approve
          if (app.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () async {
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.success)));
                  try {
                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:8000/api/loan-applications/${app.id}/approve/'),
                    );
                    Navigator.pop(context);
                    if (response.statusCode == 200) {
                      await dp.initData();
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Loan approved & disbursed!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to approve.'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error connecting to server.'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.success),
                    foregroundColor: AppTheme.success),
                child: const Text('Approve',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: OutlinedButton(
                onPressed: () async {
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.error)));
                  try {
                    final response = await http.patch(
                      Uri.parse('http://127.0.0.1:8000/api/loan-applications/${app.id}/'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({'status': 'rejected'}),
                    );
                    Navigator.pop(context);
                    if (response.statusCode == 200) {
                      await dp.initData();
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loan rejected.'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    foregroundColor: AppTheme.error),
                child: const Text('Reject',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ],
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final DataProvider dp;
  final VoidCallback onRefresh;
  const _LoanCard(
      {required this.loan, required this.dp, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final pct = loan.amountRepaid / loan.totalPayable;
    final statusColor = {
          'active': AppTheme.warning,
          'closed': AppTheme.success,
          'overdue': AppTheme.error
        }[loan.status] ??
        AppTheme.textMid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(loan.memberName.substring(0, 1),
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.memberName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textDark)),
                    Text(loan.purpose,
                        style: const TextStyle(
                            color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(loan.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _LoanStat('Principal', '₹${loan.principalAmount.toStringAsFixed(0)}'),
              ),
              Expanded(
                child: _LoanStat('Interest', '${loan.interestRate}%/mo'),
              ),
              Expanded(
                child: _LoanStat('EMI', '₹${loan.emiAmount.toStringAsFixed(0)}'),
              ),
              Expanded(
                child: _LoanStat('Outstanding', '₹${loan.outstanding.toStringAsFixed(0)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: AppTheme.success.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppTheme.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${loan.amountRepaid.toStringAsFixed(0)} repaid of ₹${loan.totalPayable.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
          if (loan.status == 'active') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _repayLoan(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Repay EMI',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _repayLoan(BuildContext ctx) {
    final ctrl = TextEditingController(text: loan.emiAmount.toStringAsFixed(0));
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Loan Repayment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Repayment Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee_rounded))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(ctrl.text);
                    if (amt == null) return;
                    
                    showDialog(context: ctx, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)));

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/members/${dp.currentUser.id}/scan_pay/'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'group_id': loan.groupId, 'amount': amt}),
                      );
                      
                      Navigator.pop(ctx);
                      if (response.statusCode == 200) {
                        await dp.initData();
                        onRefresh();
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('₹${amt.toStringAsFixed(0)} repaid!'), backgroundColor: AppTheme.success),
                        );
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Repayment failed.'), backgroundColor: AppTheme.error),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Error connecting to server.'), backgroundColor: AppTheme.error),
                      );
                    }
                  },
                  child: const Text('Confirm Repayment'),
                ),

              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanStat extends StatelessWidget {
  final String label, value;
  const _LoanStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.textDark)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
        ],
      );
}

// ─── MEETINGS TAB ─────────────────────────────────────────────────────────────

class _MeetingsTab extends StatelessWidget {
  final SHGGroup group;
  final DataProvider dp;
  const _MeetingsTab({required this.group, required this.dp});

  @override
  Widget build(BuildContext context) {
    final meetings = dp.meetingsForGroup(group.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (meetings.any((m) => !m.isCompleted)) ...[
          const Text('Upcoming Meetings',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 10),
          ...meetings
              .where((m) => !m.isCompleted)
              .map((m) => _MeetingCard(meeting: m, isUpcoming: true)),
          const SizedBox(height: 16),
        ],
        const Text('Past Meetings',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        ...meetings
            .where((m) => m.isCompleted)
            .map((m) => _MeetingCard(meeting: m, isUpcoming: false)),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final bool isUpcoming;
  const _MeetingCard({required this.meeting, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isUpcoming
                ? AppTheme.accent.withOpacity(0.4)
                : AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isUpcoming
                      ? Icons.upcoming_rounded
                      : Icons.event_available_rounded,
                  color: isUpcoming ? AppTheme.accent : AppTheme.success,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                '${meeting.date.day}/${meeting.date.month}/${meeting.date.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textDark),
              ),
              const Spacer(),
              if (!isUpcoming)
                Text('₹${meeting.totalCollected.toStringAsFixed(0)} collected',
                    style: const TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Agenda:',
              style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...meeting.agendaItems.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  const Icon(Icons.circle, size: 6, color: AppTheme.textLight),
                  const SizedBox(width: 6),
                  Text(a,
                      style: const TextStyle(
                          color: AppTheme.textMid, fontSize: 13)),
                ]),
              )),
          if (!isUpcoming && meeting.minutesSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F0),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(meeting.minutesSummary,
                  style: const TextStyle(
                      color: AppTheme.textMid, fontSize: 12, height: 1.5)),
            ),
          ],
          if (!isUpcoming) ...[
            const SizedBox(height: 8),
            Text('${meeting.attendees.length} members attended',
                style:
                    const TextStyle(color: AppTheme.textLight, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text('$label: ',
                style:
                    const TextStyle(color: AppTheme.textLight, fontSize: 13)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      );
}
