import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';

/// ─── FINANCIAL REPORT SCREEN ─────────────────────────────────────────────────
/// Comprehensive financial analytics dashboard with real computed data

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = DataProvider();
    final user = dp.currentUser;
    final myTxns = dp.allTransactions.where((t) => t.memberId == user.id).toList();
    final myLoans = dp.allLoans.where((l) => l.memberId == user.id).toList();
    final myGroups = dp.myGroups;

    // ─── Calculate all financial metrics from real data ───
    final totalDeposits = myTxns
        .where((t) => t.type == 'savings_deposit')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalWithdrawals = myTxns
        .where((t) => t.type == 'savings_withdrawal')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalLoanReceived = myTxns
        .where((t) => t.type == 'loan_disbursal')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalLoanRepaid = myTxns
        .where((t) => t.type == 'loan_repayment')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalInterestPaid = myLoans.fold(0.0, (sum, l) {
      final totalPayable = l.principalAmount + l.totalInterest;
      if (totalPayable > 0 && l.amountRepaid > 0) {
        return sum + (l.amountRepaid * l.totalInterest / totalPayable);
      }
      return sum;
    });

    // Monthly breakdown (last 6 months)
    final now = DateTime.now();
    final monthlyData = List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final monthTxns = myTxns.where((t) =>
          t.date.isAfter(month.subtract(const Duration(days: 1))) &&
          t.date.isBefore(monthEnd.add(const Duration(days: 1))));
      final deposits = monthTxns
          .where((t) => t.type == 'savings_deposit')
          .fold(0.0, (sum, t) => sum + t.amount);
      final repayments = monthTxns
          .where((t) => t.type == 'loan_repayment')
          .fold(0.0, (sum, t) => sum + t.amount);
      return _MonthData(
        month: month,
        deposits: deposits,
        repayments: repayments,
      );
    });

    // Credit Health Score components
    final debtRatio = user.savingsBalance > 0
        ? (user.loanBalance / user.savingsBalance * 100).clamp(0.0, 200.0)
        : 0.0;
    final onTimePayments = myTxns.where((t) => t.type == 'loan_repayment').length;
    final activeLoans = myLoans.where((l) => l.status == 'active').length;
    final closedLoans = myLoans.where((l) => l.status == 'closed').length;

    // Net worth
    final netWorth = user.savingsBalance - user.loanBalance;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            title: const Text('Financial Report',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D2B0D), Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Net Worth',
                            style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${netWorth.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: netWorth >= 0
                                    ? Colors.greenAccent.withValues(alpha: 0.2)
                                    : Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                netWorth >= 0 ? '↑ Positive' : '↓ Negative',
                                style: TextStyle(
                                  color: netWorth >= 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Assets: ₹${user.savingsBalance.toStringAsFixed(0)} | Liabilities: ₹${user.loanBalance.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Income vs Outflow Summary ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.swap_vert_rounded, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Cash Flow Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    ],
                  ),
                  const Divider(height: 20),
                  // Inflow
                  _FlowRow('Total Savings Deposited', totalDeposits, AppTheme.success, Icons.arrow_downward_rounded),
                  _FlowRow('Loan Received', totalLoanReceived, AppTheme.info, Icons.account_balance_rounded),
                  const Divider(height: 16),
                  // Outflow
                  _FlowRow('Savings Withdrawn', totalWithdrawals, AppTheme.error, Icons.arrow_upward_rounded),
                  _FlowRow('Loan Repaid (Principal)', totalLoanRepaid - totalInterestPaid, AppTheme.warning, Icons.payments_rounded),
                  _FlowRow('Interest Paid', totalInterestPaid, AppTheme.accent, Icons.percent_rounded),
                  const Divider(height: 16),
                  // Net
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Position', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                      Text(
                        '₹${netWorth.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: netWorth >= 0 ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Monthly Activity Chart ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Monthly Activity (Last 6 Months)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ChartLegend('Deposits', AppTheme.success),
                      const SizedBox(width: 16),
                      _ChartLegend('Repayments', AppTheme.info),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: _BarChart(data: monthlyData),
                  ),
                ],
              ),
            ),
          ),

          // ─── Credit Health ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Credit Health Analysis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      // Trust Score gauge
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: user.trustScore / 100,
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation(
                                  user.trustScore >= 80 ? Colors.greenAccent : (user.trustScore >= 60 ? Colors.amberAccent : Colors.redAccent),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${user.trustScore}',
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                                const Text('/ 100', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CreditMetric('Debt-to-Savings Ratio', '${debtRatio.toStringAsFixed(1)}%',
                                debtRatio < 50 ? Colors.greenAccent : (debtRatio < 100 ? Colors.amberAccent : Colors.redAccent)),
                            const SizedBox(height: 8),
                            _CreditMetric('On-time Payments', '$onTimePayments', Colors.greenAccent),
                            const SizedBox(height: 8),
                            _CreditMetric('Active / Closed Loans', '$activeLoans / $closedLoans', Colors.white70),
                            const SizedBox(height: 8),
                            _CreditMetric('Max Credit Eligible', '₹${(user.savingsBalance * 3).toStringAsFixed(0)}', Colors.amberAccent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Group-wise Contribution ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.groups_rounded, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Group-wise Contribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    ],
                  ),
                  const Divider(height: 20),
                  if (myGroups.isEmpty)
                    const Center(child: Text('No groups joined', style: TextStyle(color: AppTheme.textLight)))
                  else
                    ...myGroups.map((g) {
                      final groupTxns = myTxns.where((t) => t.groupId == g.id);
                      final groupDeposits = groupTxns
                          .where((t) => t.type == 'savings_deposit')
                          .fold(0.0, (sum, t) => sum + t.amount);
                      final groupRepayments = groupTxns
                          .where((t) => t.type == 'loan_repayment')
                          .fold(0.0, (sum, t) => sum + t.amount);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
                                ),
                                Text(g.category, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _GroupContrib('Deposited', '₹${groupDeposits.toStringAsFixed(0)}', AppTheme.success),
                                const SizedBox(width: 12),
                                _GroupContrib('Repaid', '₹${groupRepayments.toStringAsFixed(0)}', AppTheme.info),
                                const SizedBox(width: 12),
                                _GroupContrib('Transactions', '${groupTxns.length}', AppTheme.primary),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // ─── Transaction Summary ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_rounded, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Transaction Statistics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    ],
                  ),
                  const Divider(height: 20),
                  _StatRow('Total Transactions', '${myTxns.length}'),
                  _StatRow('Savings Deposits', '${myTxns.where((t) => t.type == 'savings_deposit').length}'),
                  _StatRow('Loan Repayments', '${myTxns.where((t) => t.type == 'loan_repayment').length}'),
                  _StatRow('Avg. Deposit Size', myTxns.where((t) => t.type == 'savings_deposit').isNotEmpty
                      ? '₹${(totalDeposits / myTxns.where((t) => t.type == 'savings_deposit').length).toStringAsFixed(0)}'
                      : '₹0'),
                  _StatRow('Groups Active In', '${myGroups.length}'),
                  _StatRow('Member Since', myTxns.isNotEmpty
                      ? '${myTxns.last.date.day}/${myTxns.last.date.month}/${myTxns.last.date.year}'
                      : 'N/A'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _FlowRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _FlowRow(this.label, this.amount, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textMid, fontSize: 13))),
            Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          ],
        ),
      );
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _ChartLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      );
}

class _CreditMetric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _CreditMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      );
}

class _GroupContrib extends StatelessWidget {
  final String label, value;
  final Color color;
  const _GroupContrib(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
            Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 10)),
          ],
        ),
      );
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
          ],
        ),
      );
}

class _MonthData {
  final DateTime month;
  final double deposits;
  final double repayments;
  const _MonthData({required this.month, required this.deposits, required this.repayments});
}

// ─── Custom Bar Chart (no dependency needed) ─────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<_MonthData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold(0.0, (m, d) => max(m, max(d.deposits, d.repayments)));
    final effectiveMax = maxVal == 0 ? 1.0 : maxVal;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final depHeight = (d.deposits / effectiveMax * 120).clamp(0.0, 120.0);
        final repHeight = (d.repayments / effectiveMax * 120).clamp(0.0, 120.0);

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 12,
                    height: max(depHeight, 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 12,
                    height: max(repHeight, 2),
                    decoration: BoxDecoration(
                      color: AppTheme.info,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(months[d.month.month - 1],
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
