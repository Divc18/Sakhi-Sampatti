import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';

/// ─── KYC DOCUMENTS SCREEN ───────────────────────────────────────────────────
/// Full KYC verification center with document status, eKYC, and identity info

class KYCDocumentsScreen extends StatefulWidget {
  const KYCDocumentsScreen({super.key});

  @override
  State<KYCDocumentsScreen> createState() => _KYCDocumentsScreenState();
}

class _KYCDocumentsScreenState extends State<KYCDocumentsScreen> {
  final dp = DataProvider();

  // Simulated KYC documents
  late final List<_KYCDocument> documents;

  @override
  void initState() {
    super.initState();
    final user = dp.currentUser;

    // Realistic KYC documents for SHG members
    documents = [
      _KYCDocument(
        name: 'Aadhaar Card',
        number: 'XXXX-XXXX-4592',
        icon: Icons.fingerprint_rounded,
        color: const Color(0xFF1565C0),
        status: 'verified',
        verifiedDate: DateTime(2024, 3, 15),
        authority: 'UIDAI (Unique Identification Authority of India)',
        linkedName: user.name,
      ),
      _KYCDocument(
        name: 'PAN Card',
        number: 'ABCPD1234F',
        icon: Icons.credit_card_rounded,
        color: const Color(0xFF00695C),
        status: 'verified',
        verifiedDate: DateTime(2024, 3, 15),
        authority: 'Income Tax Department, GoI',
        linkedName: user.name,
      ),
      _KYCDocument(
        name: 'Bank Account',
        number: 'SBI A/C XXXXXXX3210',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF283593),
        status: 'verified',
        verifiedDate: DateTime(2024, 4, 2),
        authority: 'State Bank of India – Jaipur Branch',
        linkedName: user.name,
        extra: 'IFSC: SBIN0001234',
      ),
      _KYCDocument(
        name: 'Voter ID',
        number: 'RJ/06/XXX/XXXXXX',
        icon: Icons.how_to_vote_rounded,
        color: const Color(0xFF6A1B9A),
        status: 'verified',
        verifiedDate: DateTime(2024, 5, 10),
        authority: 'Election Commission of India',
        linkedName: user.name,
      ),
      _KYCDocument(
        name: 'Ration Card (BPL)',
        number: 'RC-RJ-2021-XXXXX',
        icon: Icons.card_membership_rounded,
        color: const Color(0xFFE65100),
        status: 'verified',
        verifiedDate: DateTime(2024, 3, 20),
        authority: 'Department of Food & Civil Supplies, Rajasthan',
        linkedName: '${user.name} (Head of Household)',
        extra: 'Category: BPL • Family Size: 4',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = dp.currentUser;
    final verifiedCount = documents.where((d) => d.status == 'verified').length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            title: const Text('KYC Documents',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('eKYC Status',
                                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  const Text('FULLY VERIFIED',
                                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                                  Text('$verifiedCount / ${documents.length} documents verified',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: verifiedCount / documents.length,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Identity Summary Card
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
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('Identity Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                    ],
                  ),
                  const Divider(height: 20),
                  _IdentityRow('Full Name', user.name),
                  _IdentityRow('Phone Number', user.phone),
                  _IdentityRow('Member ID', user.id),
                  _IdentityRow('Role', user.role),
                  _IdentityRow('KYC Level', 'Level 3 (Full KYC)'),
                  _IdentityRow('Last Verified', '15/03/2024'),
                ],
              ),
            ),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_rounded, color: AppTheme.info, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Verified Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
            ),
          ),

          // Document cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _DocumentCard(document: documents[i]),
              childCount: documents.length,
            ),
          ),

          // Compliance notice
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.info, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RBI Compliance Notice',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.info)),
                        SizedBox(height: 4),
                        Text(
                          'All documents are verified as per RBI KYC Master Direction, 2016 and NABARD SHG guidelines. Your data is encrypted and stored securely.',
                          style: TextStyle(color: AppTheme.textMid, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
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

class _IdentityRow extends StatelessWidget {
  final String label, value;
  const _IdentityRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      );
}

class _DocumentCard extends StatelessWidget {
  final _KYCDocument document;
  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final isVerified = document.status == 'verified';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: document.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(document.icon, color: document.color, size: 24),
          ),
          title: Text(document.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
          subtitle: Row(
            children: [
              Text(document.number,
                  style: const TextStyle(color: AppTheme.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isVerified ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: isVerified ? AppTheme.success : AppTheme.warning,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: isVerified ? AppTheme.success : AppTheme.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 8),
            _DocDetailRow('Registered Name', document.linkedName),
            _DocDetailRow('Issuing Authority', document.authority),
            if (document.verifiedDate != null)
              _DocDetailRow('Verified On',
                  '${document.verifiedDate!.day}/${document.verifiedDate!.month}/${document.verifiedDate!.year}'),
            if (document.extra != null) _DocDetailRow('Additional Info', document.extra!),
            _DocDetailRow('Verification Mode', 'DigiLocker eKYC'),
          ],
        ),
      ),
    );
  }
}

class _DocDetailRow extends StatelessWidget {
  final String label, value;
  const _DocDetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      );
}

class _KYCDocument {
  final String name;
  final String number;
  final IconData icon;
  final Color color;
  final String status; // 'verified', 'pending', 'rejected'
  final DateTime? verifiedDate;
  final String authority;
  final String linkedName;
  final String? extra;

  _KYCDocument({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
    required this.status,
    this.verifiedDate,
    required this.authority,
    required this.linkedName,
    this.extra,
  });
}
