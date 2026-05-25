import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';

/// ─── LOAN HISTORY SCREEN ─────────────────────────────────────────────────────
/// Complete loan tracker with EMI schedule, repayment progress, and history

class LoanHistoryScreen extends StatelessWidget {
  const LoanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = DataProvider();
    final user = dp.currentUser;
    final myLoans = dp.allLoans.where((l) => l.memberId == user.id).toList()
      ..sort((a, b) => b.disbursedDate.compareTo(a.disbursedDate));
    final loanTxns = dp.allTransactions
        .where((t) => t.memberId == user.id &&
            (t.type == 'loan_disbursal' || t.type == 'loan_repayment'))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Stats
    final totalBorrowed = myLoans.fold(0.0, (sum, l) => sum + l.principalAmount);
    final totalRepaid = myLoans.fold(0.0, (sum, l) => sum + l.amountRepaid);
    final activeLoans = myLoans.where((l) => l.status == 'active').toList();
    final closedLoans = myLoans.where((l) => l.status == 'closed').toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
            title: const Text('Loan History',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFBF360C), Color(0xFFE65100), Color(0xFFF57C00)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Outstanding Balance',
                            style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('₹${user.loanBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _LoanHeaderStat('Total Borrowed', '₹${totalBorrowed.toStringAsFixed(0)}'),
                            const SizedBox(width: 20),
                            _LoanHeaderStat('Total Repaid', '₹${totalRepaid.toStringAsFixed(0)}'),
                            const SizedBox(width: 20),
                            _LoanHeaderStat('Active', '${activeLoans.length}'),
                            const SizedBox(width: 20),
                            _LoanHeaderStat('Closed', '${closedLoans.length}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Active Loans Section
          if (activeLoans.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pending_actions_rounded, color: AppTheme.warning, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('Active Loans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ActiveLoanCard(loan: activeLoans[i]),
                childCount: activeLoans.length,
              ),
            ),
          ],

          // Closed Loans Section
          if (closedLoans.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('Closed Loans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ClosedLoanCard(loan: closedLoans[i]),
                childCount: closedLoans.length,
              ),
            ),
          ],

          // Repayment History
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_rounded, color: AppTheme.info, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Repayment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
            ),
          ),

          if (loanTxns.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No loan transactions yet', style: TextStyle(color: AppTheme.textLight)),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final t = loanTxns[i];
                  final isDisbursal = t.type == 'loan_disbursal';
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isDisbursal ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDisbursal ? Icons.account_balance_rounded : Icons.payments_rounded,
                            color: isDisbursal ? AppTheme.warning : AppTheme.success,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDisbursal ? 'Loan Disbursed' : 'EMI Payment',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark),
                              ),
                              Text(
                                '${t.date.day}/${t.date.month}/${t.date.year} • ${t.receiptNo}',
                                style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isDisbursal ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isDisbursal ? AppTheme.warning : AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: loanTxns.length,
              ),
            ),

          // No loans at all
          if (myLoans.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppTheme.textHint),
                      SizedBox(height: 12),
                      Text('No loan history', style: TextStyle(color: AppTheme.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('You haven\'t taken any loans yet. Apply for one from your group.', style: TextStyle(color: AppTheme.textHint, fontSize: 12), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _LoanHeaderStat extends StatelessWidget {
  final String label, value;
  const _LoanHeaderStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      );
}

class _ActiveLoanCard extends StatelessWidget {
  final Loan loan;
  const _ActiveLoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final pct = loan.totalPayable > 0 ? (loan.amountRepaid / loan.totalPayable).clamp(0.0, 1.0) : 0.0;
    final remaining = loan.outstanding;
    final monthsLeft = loan.emiAmount > 0 ? (remaining / loan.emiAmount).ceil() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppTheme.warning.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              Text('Disbursed: ${loan.disbursedDate.day}/${loan.disbursedDate.month}/${loan.disbursedDate.year}',
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Text(loan.purpose.isNotEmpty ? loan.purpose : 'General Loan',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          // EMI details grid
          Row(
            children: [
              _LoanDetailItem('Principal', '₹${loan.principalAmount.toStringAsFixed(0)}'),
              _LoanDetailItem('Interest', '${loan.interestRate}%/mo'),
              _LoanDetailItem('Tenure', '${loan.tenureMonths} months'),
              _LoanDetailItem('EMI', '₹${loan.emiAmount.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 16),
          // Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Repaid: ₹${loan.amountRepaid.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('Total: ₹${loan.totalPayable.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppTheme.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.success.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.success),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${(pct * 100).toStringAsFixed(1)}% complete • ~$monthsLeft EMIs remaining',
                        style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Outstanding
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Outstanding Amount', style: TextStyle(color: AppTheme.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('₹${remaining.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppTheme.warning, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedLoanCard extends StatelessWidget {
  final Loan loan;
  const _ClosedLoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan.purpose.isNotEmpty ? loan.purpose : 'General Loan',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(
                  'Principal: ₹${loan.principalAmount.toStringAsFixed(0)} • Rate: ${loan.interestRate}%/mo',
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
                ),
                Text(
                  'Closed: ${loan.closedDate != null ? '${loan.closedDate!.day}/${loan.closedDate!.month}/${loan.closedDate!.year}' : 'N/A'}',
                  style: const TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${loan.totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
              const Text('Total Paid', style: TextStyle(color: AppTheme.textLight, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanDetailItem extends StatelessWidget {
  final String label, value;
  const _LoanDetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 10)),
          ],
        ),
      );
}
