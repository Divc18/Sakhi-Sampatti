import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool showDivider;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final (icon, color) = _iconAndColor(t.type);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.typeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.memberName,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${t.isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: t.isCredit ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(t.date),
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: AppTheme.divider,
          ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  (IconData, Color) _iconAndColor(String type) {
    switch (type) {
      case 'savings_deposit':
        return (Icons.arrow_downward_rounded, AppTheme.success);
      case 'savings_withdrawal':
        return (Icons.arrow_upward_rounded, AppTheme.error);
      case 'loan_disbursal':
        return (Icons.account_balance_rounded, AppTheme.warning);
      case 'loan_repayment':
        return (Icons.payments_rounded, AppTheme.info);
      case 'fine':
        return (Icons.gavel_rounded, AppTheme.error);
      case 'interest':
        return (Icons.percent_rounded, AppTheme.accent);
      default:
        return (Icons.swap_horiz_rounded, AppTheme.textLight);
    }
  }
}
