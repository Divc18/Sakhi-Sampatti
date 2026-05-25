import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';
import 'group_detail_screen.dart';
import 'widgets/stat_card.dart';
import 'widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dp = DataProvider();

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = dp.currentUser;
    final myGroups = dp.myGroups;
    final recentTxns = dp.allTransactions.where((t) => t.memberId == user.id).take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await dp.initData();
          setState(() {});
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildAppBar(user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildAiInsightsWidget(user),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Financial Overview', 'Details', () {}),
                    _buildStatsGrid(user, myGroups),
                    const SizedBox(height: 32),
                    _buildNextMeeting(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('My SHG Groups', 'See All', () {}),
                    _buildGroupsList(myGroups),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                        'Recent Transactions', 'View All', () {}),
                    _buildTransactionsList(recentTxns),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(Member user) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primary,
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.headerGradient,
          ),
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.accent,
                          child: Text(
                            user.avatar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${getGreeting()},',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: const Text(
        'SHG Connect',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => _showNotifications(context),
              ),
              if (dp.notifications.any((n) => !n.isRead))
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _QuickActionBtn(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Deposit',
                color: AppTheme.primary,
                onTap: () => _showDepositModal()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionBtn(
                icon: Icons.real_estate_agent_rounded,
                label: 'Get Loan',
                color: AppTheme.info,
                onTap: () => _showSmartLoanModal()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionBtn(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan Pay',
                color: AppTheme.accent,
                onTap: () => _showScanPayModal()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionBtn(
                icon: Icons.history_rounded,
                label: 'History',
                color: AppTheme.success,
                onTap: () => _showHistoryModal()),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsWidget(Member user) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('http://127.0.0.1:8000/api/members/${user.id}/ai_insights/')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.statusCode != 200) {
          return const SizedBox.shrink(); // Hide if error
        }

        final data = json.decode(snapshot.data!.body);
        final pct = data['repayment_probability_pct'];
        final risk = data['risk_assessment'];
        final forecast = data['credit_limit_forecast'];
        final actions = List<String>.from(data['ai_recommendations'] ?? []);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.textDark, AppTheme.primary.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Financial Intelligence',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['model_version'] ?? 'ML v1',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AiStatBox(title: 'Repayment Probability', value: '$pct%', color: pct > 70 ? Colors.greenAccent : Colors.orangeAccent),
                    _AiStatBox(title: 'Risk Assesment', value: risk, color: risk == 'Low Risk' ? Colors.greenAccent : Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                const Text('AI Actionable Insights:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...actions.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.arrow_right_rounded, color: Colors.amberAccent, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pre-approved credit forecast: ₹$forecast',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSmartLoanModal() {
    final user = dp.currentUser;
    final trustScore = user.trustScore;
    final maxLoan = user.savingsBalance * 3;
    final amountController = TextEditingController();
    String selectedPurpose = 'Agriculture';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Instant Loan ⚡',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'With your exceptional Trust Score of ${trustScore.toInt()}, you are pre-approved for up to ₹${maxLoan.toStringAsFixed(0)}.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMid,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Loan Amount (₹)',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedPurpose,
                    decoration: InputDecoration(
                      labelText: 'Purpose',
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Agriculture', 'Education', 'Business', 'Emergency']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedPurpose = v!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final amt = double.tryParse(amountController.text) ?? 0;
                              if (amt <= 0 || dp.myGroups.isEmpty) return;

                              setModalState(() => isSubmitting = true);

                              try {
                                final response = await http.post(
                                  Uri.parse('http://127.0.0.1:8000/api/members/${user.id}/apply_smart_loan/'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode({
                                    'group_id': dp.myGroups.first.id,
                                    'amount': amt,
                                    'purpose': selectedPurpose,
                                    'tenure_months': 6,
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(data['message']),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                  await dp.initData();
                                  setState(() {});
                                }
                              } catch (e) {
                                debugPrint('Error: \$e');
                              } finally {
                                if (mounted) setModalState(() => isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppTheme.accent,
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirm & Disburse',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showScanPayModal() {
    final user = dp.currentUser;
    final amountController = TextEditingController();
    bool isScanning = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (isScanning) {
            // Simulate quick scanning
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && isScanning) {
                setModalState(() => isScanning = false);
              }
            });
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Scan & Pay',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isScanning) ...[
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accent, width: 3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, size: 80, color: AppTheme.textLight),
                          const CircularProgressIndicator(color: AppTheme.accent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Scanning for SHG Group QR...', style: TextStyle(color: AppTheme.textMid, fontWeight: FontWeight.bold)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                          const SizedBox(width: 8),
                          Text('Linked to: ${dp.myGroups.first.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Our AI will automatically route this to your EMI or Savings based on your dues.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final amt = double.tryParse(amountController.text) ?? 0;
                                if (amt <= 0 || dp.myGroups.isEmpty) return;

                                setModalState(() => isSubmitting = true);

                                try {
                                  final response = await http.post(
                                    Uri.parse('http://127.0.0.1:8000/api/members/${user.id}/scan_pay/'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode({
                                      'group_id': dp.myGroups.first.id,
                                      'amount': amt,
                                      'scanned_data': 'SHG-QR-XYZ',
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    final data = json.decode(response.body);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(data['message']),
                                        backgroundColor: AppTheme.success,
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                    await dp.initData();
                                    setState(() {});
                                  }
                                } catch (e) {
                                  debugPrint('Error: $e');
                                } finally {
                                  if (mounted) setModalState(() => isSubmitting = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppTheme.primary,
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDepositModal() {
    final user = dp.currentUser;
    final amountController = TextEditingController();
    String selectedGoal = 'Emergency Fund';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final amt = double.tryParse(amountController.text) ?? 0;
          final estimatedReturn = amt * 1.12; // 12% group ROI simulation

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Goal Deposit 🌱',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Invest your savings into your SHG group pool and earn up to 12% annual interest on your goal.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMid,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    value: selectedGoal,
                    decoration: InputDecoration(
                      labelText: 'Savings Goal',
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Emergency Fund', 'Child Education', 'Agriculture/Seeds', 'Festival Fund']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedGoal = v!),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setModalState(() {}),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Deposit Amount (₹)',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (amt > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Estimated future value: ₹${estimatedReturn.toStringAsFixed(0)} in 1 year.',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (amt <= 0 || dp.myGroups.isEmpty) return;

                              setModalState(() => isSubmitting = true);

                              try {
                                final response = await http.post(
                                  Uri.parse('http://127.0.0.1:8000/api/members/${user.id}/smart_deposit/'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode({
                                    'group_id': dp.myGroups.first.id,
                                    'amount': amt,
                                    'goal': selectedGoal,
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(data['message']),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                  await dp.initData();
                                  setState(() {});
                                }
                              } catch (e) {
                                debugPrint('Error: $e');
                              } finally {
                                if (mounted) setModalState(() => isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppTheme.primary,
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Invest & Deposit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHistoryModal() {
    final user = dp.currentUser;
    final myTxns = dp.allTransactions.where((t) => t.memberId == user.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Financial Timeline',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: AppTheme.primary),
                    tooltip: 'Download Official Statement',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating official PDF statement...'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: myTxns.isEmpty
                  ? const Center(child: Text("No transactions yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: myTxns.length,
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TransactionTile(transaction: myTxns[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Member user, List<SHGGroup> myGroups) {
    // Calculate real savings trend from recent transactions
    final myTxns = dp.allTransactions.where((t) => t.memberId == user.id).toList();
    final now = DateTime.now();
    final thisMonth = myTxns.where((t) =>
        t.date.month == now.month && t.date.year == now.year && t.type == 'savings_deposit');
    final monthSavings = thisMonth.fold(0.0, (sum, t) => sum + t.amount);

    // Count active loans for the user
    final activeLoans = dp.allLoans.where((l) => l.memberId == user.id && l.status == 'active').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          StatCard(
            label: 'Total Savings',
            value: '₹${user.savingsBalance.toStringAsFixed(0)}',
            icon: Icons.savings_rounded,
            color: AppTheme.success,
            trend: monthSavings > 0 ? '+₹${monthSavings.toStringAsFixed(0)} this month' : 'No deposits this month',
            isTrendUp: monthSavings > 0,
            gradientColors: const [Color(0xFF00695C), Color(0xFF00897B)],
          ),
          StatCard(
            label: 'Loan Balance',
            value: user.loanBalance > 0
                ? '₹${user.loanBalance.toStringAsFixed(0)}'
                : 'No Loan',
            icon: Icons.account_balance_rounded,
            color: user.loanBalance > 0 ? AppTheme.warning : AppTheme.primary,
            trend: activeLoans > 0 ? '$activeLoans active loan${activeLoans > 1 ? 's' : ''}' : 'Excellent standing',
            isTrendUp: activeLoans == 0,
          ),
          StatCard(
            label: 'Active Groups',
            value: '${myGroups.length}',
            icon: Icons.people_alt_rounded,
            color: AppTheme.info,
            trend: '${myGroups.length} group${myGroups.length != 1 ? 's' : ''} joined',
            isTrendUp: myGroups.isNotEmpty,
          ),
          StatCard(
            label: 'Trust Score',
            value: '${user.trustScore}/100',
            icon: Icons.verified_rounded,
            color: AppTheme.accent,
            trend: user.trustScore >= 80 ? 'Excellent standing' : (user.trustScore >= 60 ? 'Good standing' : 'Needs improvement'),
            isTrendUp: user.trustScore >= 60,
            gradientColors: const [Color(0xFFFF8F00), Color(0xFFFFB300)],
          ),
        ],
      ),
    );
  }

  Widget _buildNextMeeting() {
    final upcoming = dp.meetings
        .where((m) =>
            m.groupId == 'g1' &&
            !m.isCompleted &&
            m.date.isAfter(DateTime.now()))
        .toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final next = upcoming.first;
    final days = next.date.difference(DateTime.now()).inDays;
    final group = dp.myGroups.firstWhere((g) => g.id == next.groupId, orElse: () => dp.allGroups.first);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.floatingShadow,
          border:
              Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.event_available_rounded,
                  color: AppTheme.accent, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upcoming Meeting',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(group.name,
                      style: const TextStyle(
                          color: AppTheme.textMid,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('In $days days',
                          style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAgendaModal(next, group),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: Size.zero,
              ),
              child: const Text('Agenda',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgendaModal(Meeting meeting, SHGGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Meeting Agenda 📋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${group.name} - ${meeting.date.day}/${meeting.date.month}/${meeting.date.year}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Key Discussion Points:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _AgendaItem('1. Collection of Monthly Savings (₹${group.monthlySavingsTarget})'),
                  _AgendaItem('2. Reviewing New Loan Applications'),
                  _AgendaItem('3. Skill Development Workshop Planning'),
                  if (meeting.agendaItems.isNotEmpty)
                    ...meeting.agendaItems.map((a) => _AgendaItem('- \$a')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have RSVP\'d to attend!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppTheme.primary,
                ),
                child: const Text(
                  'RSVP - I will attend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList(List<SHGGroup> myGroups) {
    if (myGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Center(
              child: Text('You haven\'t joined any groups yet.',
                  style: TextStyle(color: AppTheme.textLight))),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: myGroups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _GroupCard(
            group: myGroups[i], onTap: () => _openGroup(context, myGroups[i])),
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> txns) {
    if (txns.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Center(
              child: Text('No transactions yet.',
                  style: TextStyle(color: AppTheme.textLight))),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: txns.asMap().entries.map((e) {
            return TransactionTile(
              transaction: e.value,
              showDivider: e.key != txns.length - 1,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              letterSpacing: -0.2,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openGroup(BuildContext ctx, SHGGroup group) {
    Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)));
  }

  void _showNotifications(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final SHGGroup group;
  final VoidCallback onTap;

  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      group.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        group.category,
                        style: const TextStyle(
                          color: AppTheme.textMid,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Active', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Savings', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('₹${group.totalSavings.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Members', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text('${group.members.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String cat) {
    final map = {
      'Women': (Icons.woman_2_rounded, AppTheme.accent, AppTheme.accentSoft),
      'Farmers': (
        Icons.agriculture_rounded,
        AppTheme.success,
        AppTheme.successLight
      ),
      'Youth': (Icons.bolt_rounded, AppTheme.info, AppTheme.infoLight),
      'Mixed': (Icons.groups_rounded, AppTheme.primary, AppTheme.shimmer1),
    };
    final (icon, color, bgColor) =
        map[cat] ?? (Icons.people_rounded, AppTheme.primary, AppTheme.shimmer1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final String text;
  const _AgendaItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: AppTheme.textDark))),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  final dp = DataProvider();

  @override
  Widget build(BuildContext context) {
    final notifs = dp.notifications;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (notifs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("No new notifications.", style: TextStyle(color: AppTheme.textMid)),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: notifs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return GestureDetector(
                    onTap: () async {
                      if (!n.isRead) {
                        try {
                          await http.post(Uri.parse('http://127.0.0.1:8000/api/notifications/${n.id}/mark_read/'));
                          setState(() { n.isRead = true; });
                        } catch(e) {}
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: n.isRead ? AppTheme.surface : AppTheme.accentSoft.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: n.isRead ? AppTheme.divider : AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: n.isRead ? Colors.grey[200] : AppTheme.success.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              n.type == 'success' ? Icons.check_circle_rounded : Icons.notifications_active_rounded,
                              color: n.isRead ? Colors.grey[500] : AppTheme.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                    color: n.isRead ? AppTheme.textMid : AppTheme.textDark,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.message,
                                  style: TextStyle(
                                    color: n.isRead ? AppTheme.textLight : AppTheme.textMid,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AiStatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  
  const _AiStatBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
