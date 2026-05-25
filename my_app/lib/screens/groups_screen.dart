import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../models/models.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  final dp = DataProvider();
  late TabController _tab;
  String _search = '';
  String _filter = 'All';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Groups'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
          tabs: [
            Tab(text: 'My Groups (${dp.myGroups.length})'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _MyGroupsTab(dp: dp),
          _DiscoverTab(dp: dp, onJoin: () => setState(() {})),
        ],
      ),
    );
  }
}

// ─── MY GROUPS TAB ────────────────────────────────────────────────────────────

class _MyGroupsTab extends StatelessWidget {
  final DataProvider dp;
  const _MyGroupsTab({required this.dp});

  @override
  Widget build(BuildContext context) {
    final groups = dp.myGroups;
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: AppTheme.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No groups joined yet',
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Discover and join a group to begin',
                style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _GroupCard(
        group: groups[i],
        onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => GroupDetailScreen(group: groups[i]),
        )),
      ),
    );
  }
}

// ─── DISCOVER TAB ─────────────────────────────────────────────────────────────

class _DiscoverTab extends StatefulWidget {
  final DataProvider dp;
  final VoidCallback onJoin;
  const _DiscoverTab({required this.dp, required this.onJoin});

  @override
  State<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<_DiscoverTab> {
  String _filter = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Women', 'Farmers', 'Youth', 'Mixed'];
    var groups = widget.dp.allGroups.where((g) => !g.isMember).toList();
    if (_filter != 'All')
      groups = groups.where((g) => g.category == _filter).toList();
    if (_search.isNotEmpty)
      groups = groups
          .where((g) =>
              g.name.toLowerCase().contains(_search.toLowerCase()) ||
              g.location.toLowerCase().contains(_search.toLowerCase()))
          .toList();

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Search groups...',
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textLight),
            ),
          ),
        ),
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: categories
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(c),
                        selected: _filter == c,
                        onSelected: (v) => setState(() => _filter = c),
                        selectedColor: AppTheme.primary.withOpacity(0.15),
                        checkmarkColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: _filter == c
                              ? AppTheme.primary
                              : AppTheme.textMid,
                          fontWeight:
                              _filter == c ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                            color: _filter == c
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
          child: groups.isEmpty
              ? const Center(
                  child: Text('No groups found',
                      style: TextStyle(color: AppTheme.textLight)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _DiscoverCard(
                    group: groups[i],
                    onJoin: () => _joinGroup(ctx, groups[i]),
                    onView: () => Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(group: groups[i]),
                    )),
                  ),
                ),
        ),
      ],
    );
  }

  void _joinGroup(BuildContext ctx, SHGGroup group) {
    bool isSubmitting = false;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Join Group',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to join ${group.name}?'),
            const SizedBox(height: 12),
            _InfoRow(
                label: 'Monthly Savings',
                value: '₹${group.monthlySavingsTarget.toStringAsFixed(0)}'),
            _InfoRow(
                label: 'Meeting',
                value: '${group.meetingFrequency} on ${group.meetingDay}'),
            _InfoRow(label: 'Members', value: '${group.memberCount}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: isSubmitting ? null : () async {
              setDialogState(() => isSubmitting = true);
              try {
                final response = await http.post(
                  Uri.parse('http://127.0.0.1:8000/api/groups/${group.id}/join/'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({'member_id': widget.dp.currentUser.id}),
                );
                if (response.statusCode == 200) {
                  await widget.dp.initData();
                  if (mounted) setState(() {});
                  widget.onJoin();
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Successfully joined ${group.name}!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  throw Exception('Failed');
                }
              } catch (e) {
                setDialogState(() => isSubmitting = false);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Error joining group'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Join Now'),
          ),
        ],
      ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text('$label: ',
                style:
                    const TextStyle(color: AppTheme.textLight, fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      );
}

// ─── GROUP CARDS ──────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final SHGGroup group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                _catIcon(group.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.textDark)),
                      Text('${group.location} • ${group.category}',
                          style: const TextStyle(
                              color: AppTheme.textLight, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textLight),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Stat('Members', '${group.memberCount}', Icons.people_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _Stat(
                    'Total Savings',
                    '₹${group.totalSavings.toStringAsFixed(0)}',
                    Icons.savings_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _Stat('Fund', '₹${group.fundBalance.toStringAsFixed(0)}',
                    Icons.account_balance_wallet_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final SHGGroup group;
  final VoidCallback onJoin;
  final VoidCallback onView;
  const _DiscoverCard(
      {required this.group, required this.onJoin, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              _catIcon(group.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.textDark)),
                    Text(group.location,
                        style: const TextStyle(
                            color: AppTheme.textLight, fontSize: 13)),
                  ],
                ),
              ),
              if (group.isPending)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Pending',
                      style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(group.description,
              style: const TextStyle(color: AppTheme.textMid, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Stat('Members', '${group.memberCount}', Icons.people_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(
                  'Monthly',
                  '₹${group.monthlySavingsTarget.toStringAsFixed(0)}',
                  Icons.savings_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _Stat('Meeting', group.meetingFrequency,
                  Icons.calendar_month_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              if (!group.isPending) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Join Group'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

Widget _catIcon(String cat) {
  final map = {
    'Women': (Icons.woman_rounded, AppTheme.accent),
    'Farmers': (Icons.agriculture_rounded, AppTheme.success),
    'Youth': (Icons.bolt_rounded, AppTheme.info),
    'Mixed': (Icons.groups_rounded, AppTheme.primary),
  };
  final (icon, color) = map[cat] ?? (Icons.people_rounded, AppTheme.primary);
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color, size: 22),
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textLight),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );
}
