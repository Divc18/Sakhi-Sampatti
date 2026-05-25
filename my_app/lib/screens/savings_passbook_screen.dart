import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';

/// ─── SAVINGS PASSBOOK SCREEN ─────────────────────────────────────────────────
/// A real bank-style passbook showing all savings transactions with running balance

class SavingsPassbookScreen extends StatelessWidget {
  const SavingsPassbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = DataProvider();
    final user = dp.currentUser;
    final savingsTxns = dp.allTransactions
        .where((t) => t.memberId == user.id &&
            (t.type == 'savings_deposit' || t.type == 'savings_withdrawal'))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Oldest first for running balance

    // Calculate running balance
    double runningBalance = 0;
    final entries = savingsTxns.map((t) {
      if (t.type == 'savings_deposit') {
        runningBalance += t.amount;
      } else {
        runningBalance -= t.amount;
      }
      return _PassbookEntry(
        date: t.date,
        description: t.description,
        deposit: t.type == 'savings_deposit' ? t.amount : null,
        withdrawal: t.type == 'savings_withdrawal' ? t.amount : null,
        balance: runningBalance,
        receiptNo: t.receiptNo,
        approvedBy: t.approvedBy,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first for display

    // Stats
    final totalDeposits = savingsTxns
        .where((t) => t.type == 'savings_deposit')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalWithdrawals = savingsTxns
        .where((t) => t.type == 'savings_withdrawal')
        .fold(0.0, (sum, t) => sum + t.amount);
    final depositCount = savingsTxns.where((t) => t.type == 'savings_deposit').length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            title: const Text('Savings Passbook',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00897B)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Current Balance',
                            style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('₹${user.savingsBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _HeaderStat('Total Deposits', '₹${totalDeposits.toStringAsFixed(0)}', Icons.arrow_downward_rounded),
                            const SizedBox(width: 24),
                            _HeaderStat('Withdrawals', '₹${totalWithdrawals.toStringAsFixed(0)}', Icons.arrow_upward_rounded),
                            const SizedBox(width: 24),
                            _HeaderStat('Entries', '$depositCount', Icons.receipt_long_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Account Info Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A/C: ${user.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark)),
                        Text('Member ID: ${user.id} • ${user.phone}', style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),

          // Passbook header row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 70, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                  Expanded(child: Text('Particulars', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                  SizedBox(width: 65, child: Text('Deposit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.success))),
                  SizedBox(width: 65, child: Text('Withdraw', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.error))),
                  SizedBox(width: 75, child: Text('Balance', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary))),
                ],
              ),
            ),
          ),

          // Passbook entries
          if (entries.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.savings_outlined, size: 48, color: AppTheme.textHint),
                      SizedBox(height: 12),
                      Text('No savings transactions yet', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Make your first deposit to start your passbook', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final e = entries[i];
                  final isLast = i == entries.length - 1;
                  return Container(
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 16 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.white : const Color(0xFFFAFDFA),
                      border: Border(
                        left: BorderSide(color: AppTheme.divider),
                        right: BorderSide(color: AppTheme.divider),
                        bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(14)) : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year.toString().substring(2)}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMid, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.description.length > 25 ? '${e.description.substring(0, 25)}...' : e.description,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                                maxLines: 1,
                              ),
                              Text(e.receiptNo, style: const TextStyle(fontSize: 9, color: AppTheme.textHint)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          child: e.deposit != null
                              ? Text(
                                  '₹${e.deposit!.toStringAsFixed(0)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w800),
                                )
                              : const Text('—', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                        ),
                        SizedBox(
                          width: 65,
                          child: e.withdrawal != null
                              ? Text(
                                  '₹${e.withdrawal!.toStringAsFixed(0)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.w800),
                                )
                              : const Text('—', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                        ),
                        SizedBox(
                          width: 75,
                          child: Text(
                            '₹${e.balance.toStringAsFixed(0)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: entries.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _HeaderStat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 12),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      );
}

class _PassbookEntry {
  final DateTime date;
  final String description;
  final double? deposit;
  final double? withdrawal;
  final double balance;
  final String receiptNo;
  final String approvedBy;

  _PassbookEntry({
    required this.date,
    required this.description,
    this.deposit,
    this.withdrawal,
    required this.balance,
    required this.receiptNo,
    required this.approvedBy,
  });
}
