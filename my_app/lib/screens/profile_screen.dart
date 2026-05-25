import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import 'auth_screen.dart';
import 'savings_passbook_screen.dart';
import 'loan_history_screen.dart';
import 'kyc_documents_screen.dart';
import 'financial_report_screen.dart';
import 'member_card_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final dp = DataProvider();

  Future<void> _refreshData() async {
    await dp.initData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = dp.currentUser;
    final myGroups = dp.myGroups;
    final myTxns = dp.allTransactions.where((t) => t.memberId == user.id).toList();
    final myLoans = dp.allLoans.where((l) => l.memberId == user.id).toList();
    final totalDeposited = myTxns.where((t) => t.type == 'savings_deposit').fold(0.0, (s, t) => s + t.amount);
    final totalRepaid = myTxns.where((t) => t.type == 'loan_repayment').fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            // ── Header ──
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.white,
              child: Column(children: [
                Stack(alignment: Alignment.bottomRight, children: [
                  CircleAvatar(radius: 50, backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    child: Text(user.avatar, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary))),
                  Container(padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16)),
                ]),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: AppTheme.accent, size: 16), const SizedBox(width: 4),
                    Text('Trust Score: ${user.trustScore}/100', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(user.phone, style: const TextStyle(color: AppTheme.textMid, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _ProfileStat('Groups', '${myGroups.length}')),
                  Container(width: 1, height: 40, color: AppTheme.divider),
                  Expanded(child: _ProfileStat('Savings', '₹${user.savingsBalance.toStringAsFixed(0)}')),
                  Container(width: 1, height: 40, color: AppTheme.divider),
                  Expanded(child: _ProfileStat('Transactions', '${myTxns.length}')),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
                  child: Row(children: [
                    Expanded(child: _ProfileStat('Deposited', '₹${totalDeposited.toStringAsFixed(0)}')),
                    Container(width: 1, height: 40, color: AppTheme.divider),
                    Expanded(child: _ProfileStat('Loan Repaid', '₹${totalRepaid.toStringAsFixed(0)}')),
                    Container(width: 1, height: 40, color: AppTheme.divider),
                    Expanded(child: _ProfileStat('Active Loans', '${myLoans.where((l) => l.status == "active").length}')),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Digital Member Card CTA ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberCardScreen())),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Digital Member Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('QR-based identity • Tap to view', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── My Account ──
            _MenuSection(title: 'MY ACCOUNT', items: [
              _MenuItem(icon: Icons.account_balance_wallet_rounded, label: 'Savings Passbook', color: AppTheme.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPassbookScreen()))),
              _MenuItem(icon: Icons.receipt_long_rounded, label: 'Loan History', color: AppTheme.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanHistoryScreen()))),
              _MenuItem(icon: Icons.verified_user_rounded, label: 'KYC Documents', color: AppTheme.info,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KYCDocumentsScreen()))),
              _MenuItem(icon: Icons.bar_chart_rounded, label: 'Financial Report', color: AppTheme.primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialReportScreen()))),
            ]),
            const SizedBox(height: 12),

            // ── Groups ──
            _MenuSection(title: 'GROUPS & MEETINGS', items: [
              _MenuItem(icon: Icons.history_rounded, label: 'Meeting Attendance', color: AppTheme.accent,
                onTap: () => _showAttendance(context)),
              _MenuItem(icon: Icons.how_to_vote_rounded, label: 'Votes & Approvals', color: AppTheme.info,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No pending committee votes.'), backgroundColor: AppTheme.primary))),
            ]),
            const SizedBox(height: 12),

            // ── Settings ──
            _MenuSection(title: 'SETTINGS & HELP', items: [
              _MenuItem(icon: Icons.language_rounded, label: 'Language', color: AppTheme.primary, trailing: 'English',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language: Hindi, Marathi, English coming soon'), backgroundColor: AppTheme.primary))),
              _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', color: AppTheme.info, onTap: () {}),
              _MenuItem(icon: Icons.logout_rounded, label: 'Logout', color: AppTheme.error, isDestructive: true,
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false);
                }),
            ]),
            const SizedBox(height: 32),
            Text('SHG Connect v1.0.0', style: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.6), fontSize: 12)),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }

  void _showAttendance(BuildContext ctx) {
    final meetings = dp.meetings;
    final attended = meetings.where((m) => m.isCompleted && m.attendees.contains(dp.currentUser.id)).length;
    final total = meetings.where((m) => m.isCompleted).length;
    final pct = total > 0 ? (attended / total * 100) : 100;
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('Meeting Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          const SizedBox(height: 20),
          SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 90, height: 90, child: CircularProgressIndicator(
              value: pct / 100, strokeWidth: 8,
              backgroundColor: AppTheme.divider, valueColor: const AlwaysStoppedAnimation(AppTheme.success))),
            Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          ])),
          const SizedBox(height: 16),
          Text('$attended of $total meetings attended', style: const TextStyle(color: AppTheme.textMid, fontSize: 14)),
          const SizedBox(height: 8),
          Text(pct >= 90 ? '🌟 Excellent attendance!' : pct >= 70 ? '👍 Good attendance' : '⚠️ Needs improvement',
              style: TextStyle(color: pct >= 70 ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
        ]),
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
  ]);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight, letterSpacing: 0.5))),
        const Divider(color: AppTheme.divider, height: 1),
        ...items.map((item) => _MenuTile(item: item)),
      ]),
    ),
  );
}

class _MenuItem {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  final String? trailing; final bool isDestructive;
  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap, this.trailing, this.isDestructive = false});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: item.onTap,
    leading: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(item.icon, color: item.color, size: 20)),
    title: Text(item.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: item.isDestructive ? AppTheme.error : AppTheme.textDark)),
    trailing: item.trailing != null
        ? Text(item.trailing!, style: const TextStyle(color: AppTheme.textLight, fontSize: 13))
        : const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight, size: 20),
    dense: true,
  );
}
