import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';
import 'widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final dp = DataProvider();
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    var txns = dp.allTransactions
        .where((t) => dp.myGroups.any((g) => g.id == t.groupId))
        .toList();
    if (_filter != 'All') {
      final map = {
        'Savings': ['savings_deposit', 'savings_withdrawal'],
        'Loans': ['loan_disbursal', 'loan_repayment'],
        'Other': ['fine', 'interest'],
      };
      txns = txns.where((t) => (map[_filter] ?? []).contains(t.type)).toList();
    }

    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final t in txns) {
      final key = '${t.date.day}/${t.date.month}/${t.date.year}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilter(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primarySoft]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total Deposits',
                    value:
                        '₹${txns.where((t) => t.type == 'savings_deposit').fold(0.0, (a, b) => a + b.amount).toStringAsFixed(0)}',
                    icon: Icons.arrow_downward_rounded,
                    color: Colors.greenAccent,
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.white24),
                Expanded(
                  child: _SummaryItem(
                    label: 'Loan Given',
                    value:
                        '₹${txns.where((t) => t.type == 'loan_disbursal').fold(0.0, (a, b) => a + b.amount).toStringAsFixed(0)}',
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.orangeAccent,
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.white24),
                Expanded(
                  child: _SummaryItem(
                    label: 'Repaid',
                    value:
                        '₹${txns.where((t) => t.type == 'loan_repayment').fold(0.0, (a, b) => a + b.amount).toStringAsFixed(0)}',
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['All', 'Savings', 'Loans', 'Other']
                  .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppTheme.primary.withOpacity(0.15),
                          checkmarkColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: _filter == f
                                ? AppTheme.primary
                                : AppTheme.textMid,
                            fontWeight: _filter == f
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          side: BorderSide(
                              color: _filter == f
                                  ? AppTheme.primary
                                  : AppTheme.divider),
                          backgroundColor: Colors.white,
                        ),
                      ))
                  .toList(),
            ),
          ),

          // List
          Expanded(
            child: txns.isEmpty
                ? const Center(
                    child: Text('No transactions',
                        style: TextStyle(color: AppTheme.textLight)))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: grouped.entries
                        .map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(e.key,
                                    style: const TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: Column(
                                  children: e.value
                                      .map<Widget>((t) =>
                                          TransactionTile(transaction: t))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilter(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All', 'Savings', 'Loans', 'Other']
                  .map((f) => ChoiceChip(
                        label: Text(f),
                        selected: _filter == f,
                        onSelected: (_) {
                          setState(() => _filter = f);
                          Navigator.pop(sheetCtx);
                        },
                        selectedColor: AppTheme.primary.withOpacity(0.15),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      );
}
