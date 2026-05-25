import 'package:flutter/material.dart';
import 'data_bridge.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'login_choice.dart';

// ─────────────────────────────────────────────────────────────────
//  GLOBAL STATE
// ─────────────────────────────────────────────────────────────────
List<BusinessRequest> pendingBusinessRequests = [];
List<BusinessRequest> businessRequests = [];

void main() => runApp(const AdminApp());

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sakhi Sampatti Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B00),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const AdminLoginPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────────────────────────
const String _kAdminId = 'admin123';
const String _kAdminPassword = 'Admin@Secure123';
const String _kAdminMobile = '+91 98765 43210';
const String _kAdminEmail = 'admin@sakhisampatti.com';
const Color _kOrange = Color(0xFFFF6B00);
const Color _kOrangeLight = Color(0xFFFFF3E8);

// ═════════════════════════════════════════════════════════════════
//  ADMIN LOGIN PAGE
// ═════════════════════════════════════════════════════════════════
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  bool _validPassword(String p) =>
      p.length >= 12 &&
          p.contains(RegExp(r'[A-Z]')) &&
          p.contains(RegExp(r'[0-9]')) &&
          p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (_userCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'User ID is required';
        _loading = false;
      });
      return;
    }
    if (!_validPassword(_passCtrl.text)) {
      setState(() {
        _error = 'Password: 12+ chars, 1 uppercase, 1 number, 1 special char';
        _loading = false;
      });
      return;
    }
    if (_userCtrl.text.trim() != _kAdminId || _passCtrl.text != _kAdminPassword) {
      setState(() {
        _error = 'Invalid User ID or Password';
        _loading = false;
      });
      return;
    }
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomePage()),
    );
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kOrangeLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_reset, color: _kOrange),
            ),
            const SizedBox(width: 12),
            const Flexible(child: Text('Reset Password')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A password reset link will be sent to:'),
            const SizedBox(height: 12),
            _infoChip(Icons.phone, _kAdminMobile, Colors.green),
            const SizedBox(height: 8),
            _infoChip(Icons.email, _kAdminEmail, Colors.blue),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reset link sent! Expires in 15 minutes.',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E8), Color(0xFFFFE0C2), Color(0xFFFFF8F0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 12,
                  shadowColor: _kOrange.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 60,
                            minHeight: 60,
                          ),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: _kOrange.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sakhi Sampatti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kOrangeLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ADMINISTRATOR PORTAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: _kOrange,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // User ID
                        TextField(
                          controller: _userCtrl,
                          decoration: _inputDecoration(
                            'Admin User ID',
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration(
                            'Password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: _kOrange),
                            ),
                          ),
                        ),
                        // Error box
                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: _loading
                              ? const Center(
                            child: CircularProgressIndicator(color: _kOrange),
                          )
                              : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kOrange,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: _kOrange.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'LOGIN AS ADMIN',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'For authorized personnel only. All activities are logged.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _kOrange, size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kOrange, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  ADMIN HOME (shell with bottom nav)
// ═════════════════════════════════════════════════════════════════
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _idx = 0;

  static const _labels = ['Dashboard', 'Approvals', 'Reports', 'Settings'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.assignment_outlined,
    Icons.bar_chart_outlined,
    Icons.settings_outlined,
  ];
  static const _activeIcons = [
    Icons.dashboard,
    Icons.assignment,
    Icons.bar_chart,
    Icons.settings,
  ];

  void goToTab(int i) => setState(() => _idx = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardPage(onGoToApprovals: () => goToTab(1)),
      const AdminApprovalsPage(),
      const AdminReportsPage(),
      AdminSettingsPage(onLogout: _logout),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakhi Sampatti Admin'),
        actions: [
          GestureDetector(
            onTap: () => goToTab(2),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
              ),
              child: const Icon(Icons.person, color: _kOrange, size: 22),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: List.generate(4, (i) {
              final selected = _idx == i;
              return Expanded(
                child: InkWell(
                  onTap: () => goToTab(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected ? _kOrange.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? _activeIcons[i] : _icons[i],
                            color: selected ? _kOrange : Colors.grey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? _kOrange : Colors.grey,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  ADMIN DASHBOARD PAGE
// ═════════════════════════════════════════════════════════════════
class AdminDashboardPage extends StatefulWidget {
  final VoidCallback onGoToApprovals;
  const AdminDashboardPage({super.key, required this.onGoToApprovals});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<BusinessRequest> _all = [];
  List<BusinessRequest> _pending = [];
  List<BusinessRequest> _approved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await DataBridge.readAllRequests();
      final pending = await DataBridge.getPendingRequests();
      final approved = await DataBridge.getApprovedRequests();
      setState(() {
        _all = all;
        _pending = pending;
        _approved = approved;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int get _todayCount {
    final now = DateTime.now();
    return _all
        .where((r) =>
    r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _kOrange,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back, Admin!',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _loading
                              ? 'Loading...'
                              : _pending.isEmpty
                              ? '🎉 All caught up! No pending requests'
                              : '⚠️ ${_pending.length} pending request${_pending.length == 1 ? '' : 's'}',
                          style: const TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: _kOrange),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.4,
                ),
                itemCount: 4,
                itemBuilder: (_, index) {
                  final items = [
                    _statCard('Pending', _pending.length, Icons.pending_actions, const Color(0xFFFF6B00)),
                    _statCard('Approved', _approved.length, Icons.verified, const Color(0xFF2ECC71)),
                    _statCard('Total', _all.length, Icons.request_page, const Color(0xFF3498DB)),
                    _statCard('Today', _todayCount, Icons.today, const Color(0xFF9B59B6)),
                  ];
                  return items[index];
                },
              ),
            const SizedBox(height: 28),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.approval,
                    title: 'Review Requests',
                    subtitle: 'Check pending approvals',
                    color: _kOrange,
                    onTap: widget.onGoToApprovals,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.bar_chart,
                    title: 'Analytics',
                    subtitle: 'View summary report',
                    color: const Color(0xFF3498DB),
                    onTap: () => _showAnalyticsSheet(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.people,
                    title: 'All Users',
                    subtitle: 'Browse submissions',
                    color: const Color(0xFF9B59B6),
                    onTap: () => _showAllUsersSheet(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$count',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _analyticRow('Total Submissions', '${_all.length}', Icons.inbox, Colors.blue),
            _analyticRow('Pending Review', '${_pending.length}', Icons.pending_actions, Colors.orange),
            _analyticRow('Approved', '${_approved.length}', Icons.check_circle, Colors.green),
            _analyticRow(
              'Rejected',
              '${_all.length - _approved.length - _pending.length}',
              Icons.cancel,
              Colors.red,
            ),
            _analyticRow('Today\'s Submissions', '$_todayCount', Icons.today, Colors.purple),
            const SizedBox(height: 12),
            const Text(
              'Full analytics dashboard coming in next release.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showAllUsersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('All Submissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _all.isEmpty
                  ? const Center(child: Text('No submissions yet'))
                  : ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.all(16),
                itemCount: _all.length,
                itemBuilder: (_, i) {
                  final r = _all[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: r.approved ? Colors.green : Colors.orange,
                        child: Text(
                          r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        r.businessName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${r.userName} • ${r.category}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.approved ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.approved ? 'Approved' : 'Pending',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  ADMIN APPROVALS PAGE
// ═════════════════════════════════════════════════════════════════
class AdminApprovalsPage extends StatefulWidget {
  const AdminApprovalsPage({super.key});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<BusinessRequest> _pending = [];
  List<BusinessRequest> _approved = [];
  bool _loading = true;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await DataBridge.getPendingRequests();
      final a = await DataBridge.getApprovedRequests();
      setState(() {
        _pending = p;
        _approved = a;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  List<BusinessRequest> _filter(List<BusinessRequest> list) {
    if (_search.isEmpty) return list;
    final q = _search.toLowerCase();
    return list
        .where((r) =>
    r.businessName.toLowerCase().contains(q) ||
        r.userName.toLowerCase().contains(q) ||
        r.category.toLowerCase().contains(q))
        .toList();
  }

  // ── Document viewer ──────────────────────────────────────────
  void _openDocViewer(BusinessRequest request, {bool showActions = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, __) => _DocumentViewerSheet(
          request: request,
          showActionButtons: showActions,
          onApprove: showActions ? () => _approveRequest(request) : null,
          onReject: showActions ? () => _showRejectDialog(request) : null,
        ),
      ),
    );
  }

  // ── Approve ──────────────────────────────────────────────────
  Future<void> _approveRequest(BusinessRequest request) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Flexible(child: Text('Confirm Approval')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to approve:'),
            const SizedBox(height: 12),
            _summaryBox(request, Colors.green),
            const SizedBox(height: 10),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Yes, Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final idx = _pending.indexOf(request);
    if (idx == -1) {
      _snack('Request already processed', Colors.orange);
      return;
    }
    try {
      await DataBridge.approveRequest(idx);
      setState(() {
        _pending.removeAt(idx);
        request.approved = true;
        _approved.add(request);
      });
      _snack('✅ Approved: ${request.businessName}', Colors.green);
      _tab.animateTo(1);
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
  }

  // ── Reject ───────────────────────────────────────────────────
  void _showRejectDialog(BusinessRequest request) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 8),
            Flexible(child: Text('Reject Request')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryBox(request, Colors.red),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for rejection (optional)',
                hintText: 'e.g. Incomplete documents...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kOrange, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              final idx = _pending.indexOf(request);
              Navigator.pop(ctx);
              if (idx != -1) setState(() => _pending.removeAt(idx));
              _snack('❌ Rejected: ${request.businessName}', Colors.red);
            },
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(BusinessRequest r, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.businessName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text('Owner: ${r.userName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('Mobile: ${r.userMobile}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('Category: ${r.category}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Approvals'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pending_actions, size: 18),
                  const SizedBox(width: 6),
                  const Flexible(child: Text('Pending', overflow: TextOverflow.ellipsis)),
                  if (_pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pending.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 6),
                  const Flexible(child: Text('Approved', overflow: TextOverflow.ellipsis)),
                  if (_approved.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_approved.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kOrange))
          : Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name, business, category...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // ── Pending tab ──
                _buildList(
                  _filter(_pending),
                  emptyIcon: Icons.check_circle_outline,
                  emptyColor: Colors.green,
                  emptyTitle: 'No Pending Requests',
                  emptySubtitle: 'All requests have been processed',
                  itemBuilder: (r) => _buildPendingCard(r),
                ),
                // ── Approved tab ──
                _buildList(
                  _filter(_approved),
                  emptyIcon: Icons.hourglass_empty,
                  emptyColor: Colors.grey,
                  emptyTitle: 'No Approved Requests',
                  emptySubtitle: 'Approved businesses will appear here',
                  itemBuilder: (r) => _buildApprovedCard(r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<BusinessRequest> list, {
        required IconData emptyIcon,
        required Color emptyColor,
        required String emptyTitle,
        required String emptySubtitle,
        required Widget Function(BusinessRequest) itemBuilder,
      }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 64, color: emptyColor.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: _kOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: list.length,
        itemBuilder: (_, i) => itemBuilder(list[i]),
      ),
    );
  }

  Widget _buildPendingCard(BusinessRequest r) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 18,
                  child: Text(
                    r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        r.userMobile,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _fmt(r.timestamp),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store, color: _kOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.businessName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.category,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _openDocViewer(r, showActions: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_open, color: Colors.blue.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${r.documents.length} document${r.documents.length == 1 ? '' : 's'} uploaded',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'View All →',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width > 420
                      ? (MediaQuery.of(context).size.width - 56) * 0.4
                      : double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDocViewer(r, showActions: true),
                    icon: const Icon(Icons.find_in_page, size: 15),
                    label: const Text('Review Docs', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 420
                      ? (MediaQuery.of(context).size.width - 56) * 0.25
                      : double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _approveRequest(r),
                    icon: const Icon(Icons.check, size: 15),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 420
                      ? (MediaQuery.of(context).size.width - 56) * 0.25
                      : double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(r),
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text('Reject', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedCard(BusinessRequest r) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: () => _openDocViewer(r),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 18,
                    child: Text(
                      r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          r.userMobile,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'APPROVED',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: _kOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.businessName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            r.category,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.folder_open, color: Colors.green.shade600, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${r.documents.length} doc${r.documents.length == 1 ? '' : 's'} on file  •  Tap to view',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Submitted: ${_fmt(r.timestamp)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  DOCUMENT VIEWER BOTTOM SHEET
// ═════════════════════════════════════════════════════════════════
class _DocumentViewerSheet extends StatelessWidget {
  final BusinessRequest request;
  final bool showActionButtons;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _DocumentViewerSheet({
    required this.request,
    this.showActionButtons = false,
    this.onApprove,
    this.onReject,
  });

  // ── Open document ─────────────────────────────────────────────
  Future<void> _openDocument(BuildContext context, UploadedDocument doc) async {
    if (doc.base64Data == null || doc.base64Data!.isEmpty) {
      _snack(context, 'No file data for this document', Colors.orange);
      return;
    }

    Uint8List bytes;
    try {
      bytes = base64Decode(doc.base64Data!);
    } catch (_) {
      _snack(context, 'Failed to decode document data', Colors.red);
      return;
    }

    final lower = doc.fileName.toLowerCase();
    final isImage = lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg');

    // ── Images: show fullscreen dialog ─────────────────────────
    if (isImage) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // Scrollable image (fixes overflow)
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Unable to render image', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Close + label bar at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.documentType,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              doc.fileName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
              ),
              // Hint at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                    color: Colors.black38,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    'Pinch to zoom  •  Drag to pan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // ── Mobile: write to temp file and open ────────────────────
    if (!kIsWeb) {
      try {
        final dir = await getTemporaryDirectory();
        final safe = doc.fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
        final file = File('${dir.path}/$safe');
        await file.writeAsBytes(bytes, flush: true);
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done && context.mounted) {
          _snack(
            context,
            'Could not open: ${result.message}. Install a PDF viewer.',
            Colors.red,
          );
        }
      } catch (e) {
        if (context.mounted) _snack(context, 'Error: $e', Colors.red);
      }
      return;
    }

    // ── Web fallback ───────────────────────────────────────────
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.insert_drive_file, color: _kOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.documentType,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: ${doc.fileName}', overflow: TextOverflow.ellipsis),
              Text('Size: ${(bytes.length / 1024).toStringAsFixed(1)} KB'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'PDF preview requires a native app on this device. The document is stored and ready for review.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _snack(BuildContext ctx, String msg, Color bg) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, duration: const Duration(seconds: 3)),
    );
  }

  IconData _docIcon(String name) {
    final l = name.toLowerCase();
    if (l.contains('aadhaar') || l.contains('aadhar')) return Icons.credit_card;
    if (l.contains('pan')) return Icons.badge;
    if (l.contains('gst')) return Icons.receipt_long;
    if (l.contains('bank') || l.contains('passbook')) return Icons.account_balance;
    if (l.contains('license') || l.contains('licence')) return Icons.drive_eta;
    if (l.contains('certificate') || l.contains('cert')) return Icons.workspace_premium;
    if (l.contains('photo') || l.contains('image')) return Icons.photo;
    if (l.contains('address') || l.contains('proof')) return Icons.home;
    if (l.contains('collateral')) return Icons.account_balance_wallet;
    return Icons.insert_drive_file;
  }

  Color _docColor(String name) {
    final l = name.toLowerCase();
    if (l.contains('aadhaar') || l.contains('aadhar')) return Colors.blue;
    if (l.contains('pan')) return Colors.indigo;
    if (l.contains('gst')) return Colors.teal;
    if (l.contains('bank') || l.contains('passbook')) return Colors.green;
    if (l.contains('license') || l.contains('licence')) return Colors.purple;
    if (l.contains('certificate') || l.contains('cert')) return Colors.amber.shade700;
    if (l.contains('photo') || l.contains('image')) return Colors.pink;
    if (l.contains('address') || l.contains('proof')) return Colors.orange;
    if (l.contains('collateral')) return Colors.deepOrange;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kOrangeLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open, color: _kOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uploaded Documents',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${request.documents.length} file${request.documents.length == 1 ? '' : 's'} • ${request.businessName}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Business info chip
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kOrangeLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kOrange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: _kOrange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.businessName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${request.category}  ·  ${request.userName}  ·  ${request.userMobile}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Document list
          Expanded(
            child: request.documents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 52, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('No documents uploaded', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: request.documents.length,
              itemBuilder: (_, i) {
                final doc = request.documents[i];
                final color = _docColor(doc.documentType);
                final hasData = doc.base64Data != null && doc.base64Data!.isNotEmpty;
                final ext =
                doc.fileName.contains('.') ? doc.fileName.split('.').last.toUpperCase() : 'FILE';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasData ? Colors.grey.shade200 : Colors.red.shade100,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Container(
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(_docIcon(doc.documentType), color: color, size: 22),
                        ],
                      ),
                    ),
                    title: Text(
                      doc.documentType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ext,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!hasData)
                              const Text(
                                'No data',
                                style: TextStyle(fontSize: 10, color: Colors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: hasData
                        ? ElevatedButton(
                      onPressed: () => _openDocument(context, doc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 12)),
                    )
                        : const Icon(Icons.warning_amber, color: Colors.red),
                    isThreeLine: true,
                    onTap: hasData ? () => _openDocument(context, doc) : null,
                  ),
                );
              },
            ),
          ),
          // Approve / Reject buttons
          if (showActionButtons && onApprove != null && onReject != null) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 420
                        ? (MediaQuery.of(context).size.width - 44) / 2
                        : double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onApprove!();
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 420
                        ? (MediaQuery.of(context).size.width - 44) / 2
                        : double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onReject!();
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  ADMIN REPORTS PAGE
// ═════════════════════════════════════════════════════════════════
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ── Mock user data (mirrors data from app_main_page / DataBridge) ──
  final List<Map<String, dynamic>> _users = [
    {'name': 'Ramesh Saini',    'mobile': '+91 98100 11111', 'business': 'Ramesh Textiles',   'category': 'Textiles',     'status': 'Approved',  'joined': '12 Jan 2025'},
    {'name': 'Priya Sharma',    'mobile': '+91 98100 22222', 'business': 'Priya Foods',        'category': 'Food',         'status': 'Pending',   'joined': '20 Feb 2025'},
    {'name': 'Anita Verma',     'mobile': '+91 98100 33333', 'business': 'Anita Boutique',     'category': 'Fashion',      'status': 'Approved',  'joined': '5 Mar 2025'},
    {'name': 'Sunita Yadav',    'mobile': '+91 98100 44444', 'business': 'Sunita Dairy',       'category': 'Dairy',        'status': 'Approved',  'joined': '18 Mar 2025'},
    {'name': 'Kavita Patel',    'mobile': '+91 98100 55555', 'business': 'Kavita Handicrafts', 'category': 'Handicrafts',  'status': 'Pending',   'joined': '2 Apr 2025'},
    {'name': 'Meena Singh',     'mobile': '+91 98100 66666', 'business': 'Meena Agro',         'category': 'Agriculture',  'status': 'Approved',  'joined': '14 Apr 2025'},
    {'name': 'Lakshmi Reddy',   'mobile': '+91 98100 77777', 'business': 'Lakshmi Tailors',   'category': 'Tailoring',    'status': 'Rejected',  'joined': '29 Apr 2025'},
    {'name': 'Geeta Joshi',     'mobile': '+91 98100 88888', 'business': 'Geeta Bakery',      'category': 'Food',         'status': 'Pending',   'joined': '10 May 2025'},
  ];

  // ── Mock mentor data (mirrors data from mentor_main_page) ──
  final List<Map<String, dynamic>> _mentors = [
    {'name': 'Dr. Anjali Mehta',  'field': 'Agriculture',  'mentees': 72,  'sessions': 48, 'rating': '4.8', 'status': 'Active',   'joined': '5 Jan 2025'},
    {'name': 'Rohit Kumar',       'field': 'Dairy',         'mentees': 45,  'sessions': 30, 'rating': '4.6', 'status': 'Active',   'joined': '20 Jan 2025'},
    {'name': 'Sunita Pillai',     'field': 'Textiles',      'mentees': 38,  'sessions': 22, 'rating': '4.7', 'status': 'Active',   'joined': '8 Feb 2025'},
    {'name': 'Vikram Nair',       'field': 'Handicrafts',   'mentees': 29,  'sessions': 18, 'rating': '4.5', 'status': 'Active',   'joined': '25 Feb 2025'},
    {'name': 'Preethi Iyer',      'field': 'Food',          'mentees': 61,  'sessions': 40, 'rating': '4.9', 'status': 'Active',   'joined': '3 Mar 2025'},
    {'name': 'Ramesh Tiwari',     'field': 'Tailoring',     'mentees': 14,  'sessions': 8,  'rating': '4.3', 'status': 'Inactive', 'joined': '17 Apr 2025'},
  ];

  String _userSearch = '';
  String _mentorSearch = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_userSearch.isEmpty) return _users;
    final q = _userSearch.toLowerCase();
    return _users.where((u) =>
    u['name'].toString().toLowerCase().contains(q) ||
        u['business'].toString().toLowerCase().contains(q) ||
        u['category'].toString().toLowerCase().contains(q)).toList();
  }

  List<Map<String, dynamic>> get _filteredMentors {
    if (_mentorSearch.isEmpty) return _mentors;
    final q = _mentorSearch.toLowerCase();
    return _mentors.where((m) =>
    m['name'].toString().toLowerCase().contains(q) ||
        m['field'].toString().toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final approvedCount = _users.where((u) => u['status'] == 'Approved').length;
    final pendingCount  = _users.where((u) => u['status'] == 'Pending').length;
    final activeMentors = _mentors.where((m) => m['status'] == 'Active').length;
    final totalSessions = _mentors.fold<int>(0, (sum, m) => sum + (m['sessions'] as int));

    return Column(
      children: [
        // Summary strip
        Container(
          color: _kOrangeLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _miniStat('Users',    '${_users.length}',   Icons.people,   const Color(0xFF9B59B6)),
              _miniStat('Approved', '$approvedCount',     Icons.verified, const Color(0xFF2ECC71)),
              _miniStat('Mentors',  '$activeMentors',     Icons.school,   const Color(0xFF3498DB)),
              _miniStat('Sessions', '$totalSessions',     Icons.event,    _kOrange),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tab,
          labelColor: _kOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kOrange,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 6),
                  const Text('User Report'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(10)),
                    child: Text('${_users.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 16),
                  const SizedBox(width: 6),
                  const Text('Mentor Report'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF3498DB), borderRadius: BorderRadius.circular(10)),
                    child: Text('${_mentors.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              // ── USER REPORT TAB ──
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      onChanged: (v) => setState(() => _userSearch = v),
                      decoration: InputDecoration(
                        hintText: 'Search users by name, business, category…',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        _legendChip('Approved', Colors.green),
                        const SizedBox(width: 8),
                        _legendChip('Pending', Colors.orange),
                        const SizedBox(width: 8),
                        _legendChip('Rejected', Colors.red),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredUsers.isEmpty
                        ? const Center(child: Text('No users found'))
                        : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (_, i) => _userCard(_filteredUsers[i]),
                    ),
                  ),
                ],
              ),

              // ── MENTOR REPORT TAB ──
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      onChanged: (v) => setState(() => _mentorSearch = v),
                      decoration: InputDecoration(
                        hintText: 'Search mentors by name or field…',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredMentors.isEmpty
                        ? const Center(child: Text('No mentors found'))
                        : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: _filteredMentors.length,
                      itemBuilder: (_, i) => _mentorCard(_filteredMentors[i]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _legendChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final status = u['status'] as String;
    final statusColor = status == 'Approved'
        ? Colors.green
        : status == 'Pending'
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Text(
                    (u['name'] as String).isNotEmpty ? (u['name'] as String)[0].toUpperCase() : '?',
                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'], overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(u['mobile'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.store, size: 14, color: _kOrange),
                const SizedBox(width: 6),
                Expanded(child: Text(u['business'], overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(u['category'], style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Joined: ${u['joined']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mentorCard(Map<String, dynamic> m) {
    final isActive = m['status'] == 'Active';
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF3498DB).withOpacity(0.15),
                  child: Text(
                    (m['name'] as String).isNotEmpty ? (m['name'] as String)[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3498DB)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'], overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Field: ${m['field']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(m['status'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _mentorStat(Icons.group,   '${m['mentees']}',  'Mentees',  const Color(0xFF9B59B6))),
                Expanded(child: _mentorStat(Icons.event,   '${m['sessions']}', 'Sessions', _kOrange)),
                Expanded(child: _mentorStat(Icons.star,    m['rating'],        'Rating',   Colors.amber)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Joined: ${m['joined']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mentorStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  ADMIN SETTINGS PAGE  (replaces old profile page)
// ═════════════════════════════════════════════════════════════════
class AdminSettingsPage extends StatefulWidget {
  final VoidCallback onLogout;
  const AdminSettingsPage({super.key, required this.onLogout});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailAlerts = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 70,
                    minHeight: 70,
                  ),
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 3),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Administrator',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  _kAdminEmail,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Text(
                    '⭐ SUPER ADMIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Admin info
          _section(
            'Admin Information',
            Icons.info_outline,
            [
              _infoRow(Icons.person_outline, 'User ID', _kAdminId),
              _infoRow(Icons.email_outlined, 'Email', _kAdminEmail),
              _infoRow(Icons.phone_outlined, 'Mobile', _kAdminMobile),
              _infoRow(Icons.badge_outlined, 'Role', 'System Administrator'),
              _infoRow(Icons.schedule, 'Last Login', _lastLoginStr()),
            ],
          ),
          const SizedBox(height: 16),

          // Notifications
          _section(
            'Notifications',
            Icons.notifications_outlined,
            [
              _switchRow(
                'Push Notifications',
                'Receive alerts for new requests',
                Icons.notifications_active_outlined,
                _notificationsEnabled,
                    (v) => setState(() => _notificationsEnabled = v),
              ),
              _switchRow(
                'Email Alerts',
                'Get approval emails',
                Icons.mark_email_unread_outlined,
                _emailAlerts,
                    (v) => setState(() => _emailAlerts = v),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preferences
          _section(
            'Preferences',
            Icons.tune,
            [
              _tappableRow(
                Icons.language,
                'Language',
                _selectedLanguage,
                    () => _showLanguagePicker(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Security
          _section(
            'Security',
            Icons.security,
            [
              _tappableRow(
                Icons.lock_reset,
                'Change Password',
                'Send reset link',
                _changePassword,
              ),
              _tappableRow(
                Icons.history,
                'Activity Log',
                'View admin actions',
                _showActivityLog,
              ),
              _tappableRow(
                Icons.devices,
                'Active Sessions',
                '1 active session',
                _showSessions,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 24),

          // Version info
          Text(
            'Sakhi Sampatti Admin v2.0.0\nBuild 2025.06',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _kOrangeLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _kOrange, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: _kOrange, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _kOrange, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _kOrange,
          ),
        ],
      ),
    );
  }

  Widget _tappableRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: _kOrange, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  String _lastLoginStr() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, duration: const Duration(seconds: 2)),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: _kOrange),
            SizedBox(width: 8),
            Flexible(child: Text('Change Password')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A reset link will be sent to:'),
            const SizedBox(height: 12),
            _chip(Icons.phone, _kAdminMobile, Colors.green),
            const SizedBox(height: 8),
            _chip(Icons.email, _kAdminEmail, Colors.blue),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('✅ Reset link sent!', Colors.green);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kOrange),
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityLog() {
    final actions = [
      ('Approved', 'Ramesh Textiles', '2 hours ago', Colors.green),
      ('Rejected', 'Priya Foods', '5 hours ago', Colors.red),
      ('Approved', 'Anita Boutique', 'Yesterday', Colors.green),
      ('Login', 'Admin session started', '2 days ago', _kOrange),
      ('Approved', 'Singh Hardware', '3 days ago', Colors.green),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...actions.map(
                  (a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: a.$4.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        a.$1 == 'Approved'
                            ? Icons.check
                            : a.$1 == 'Rejected'
                            ? Icons.close
                            : Icons.login,
                        color: a.$4,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.$1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: a.$4,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            a.$2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        a.$3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.devices, color: _kOrange),
            SizedBox(width: 8),
            Flexible(child: Text('Active Sessions')),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_android, color: Colors.green),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'This Device',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Logged in: ${_lastLoginStr()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                'Status: Active',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('All other sessions terminated', Colors.red);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke Others', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final langs = ['English', 'Hindi', 'Kannada', 'Tamil', 'Telugu'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs
              .map(
                (lang) => RadioListTile<String>(
              value: lang,
              groupValue: _selectedLanguage,
              title: Text(lang),
              activeColor: _kOrange,
              onChanged: (v) {
                setState(() => _selectedLanguage = v!);
                Navigator.pop(ctx);
                if (v != 'English') {
                  _snack('$v translation coming soon!', _kOrange);
                }
              },
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
