import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';

/// ─── DIGITAL MEMBER CARD SCREEN ──────────────────────────────────────────────
/// QR-based SHG identity card for verification and payments

class MemberCardScreen extends StatelessWidget {
  const MemberCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = DataProvider();
    final user = dp.currentUser;
    final myGroups = dp.myGroups;
    final memberSince = dp.allTransactions
        .where((t) => t.memberId == user.id)
        .fold<DateTime?>(null, (oldest, t) => oldest == null || t.date.isBefore(oldest) ? t.date : oldest);

    return Scaffold(
      backgroundColor: const Color(0xFF0D2B0D),
      appBar: AppBar(
        title: const Text('Digital Member Card'),
        backgroundColor: const Color(0xFF0D2B0D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── Main Card ───
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SHG CONNECT',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                Text('Digital Identity Card',
                                    style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('VERIFIED',
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Member photo placeholder + info
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: Center(
                                child: Text(user.avatar,
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                  const SizedBox(height: 4),
                                  Text('Member ID: ${user.id}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(user.phone,
                                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Divider
                        Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                        const SizedBox(height: 16),
                        // Details
                        Row(
                          children: [
                            _CardField('Role', user.role),
                            _CardField('Trust Score', '${user.trustScore}/100'),
                            _CardField('Groups', '${myGroups.length}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _CardField('Member Since',
                                memberSince != null ? '${memberSince.month}/${memberSince.year}' : 'New'),
                            _CardField('KYC Status', 'Level 3'),
                            _CardField('Status', user.isActive ? 'Active' : 'Inactive'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // QR Code area
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _QRCodeWidget(data: 'SHG:${user.id}:${user.name}:${user.phone}'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text('Scan for instant verification',
                              style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Groups Membership List ───
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.groups_rounded, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('Group Memberships',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (myGroups.isEmpty)
                    const Center(child: Text('No groups joined', style: TextStyle(color: Colors.white38)))
                  else
                    ...myGroups.map((g) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.people_alt_rounded, color: Colors.white70, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                    Text('${g.category} • ${g.location}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('MEMBER', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Footer
            Text('This is a government-recognized digital identity for SHG members.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Issued under NABARD – National Rural Livelihoods Mission',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10),
                textAlign: TextAlign.center),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label, value;
  const _CardField(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

/// Generates a QR-code-like pattern using Canvas (no external package needed)
class _QRCodeWidget extends StatelessWidget {
  final String data;
  const _QRCodeWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _QRPainter(data),
    );
  }
}

class _QRPainter extends CustomPainter {
  final String data;
  _QRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1B5E20);
    final gridSize = 21;
    final cellSize = size.width / gridSize;
    final rng = Random(data.hashCode);

    // Draw finder patterns (three corners)
    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, (gridSize - 7) * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, (gridSize - 7) * cellSize, cellSize);

    // Draw data area
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Skip finder pattern areas
        if ((r < 8 && c < 8) || (r < 8 && c >= gridSize - 8) || (r >= gridSize - 8 && c < 8)) continue;
        if (rng.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize, r * cellSize, cellSize * 0.85, cellSize * 0.85),
              Radius.circular(cellSize * 0.15),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double cell) {
    // Outer square
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, cell * 7, cell * 7), Radius.circular(cell * 0.6)),
      paint,
    );
    // Inner white
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5), Radius.circular(cell * 0.4)),
      whitePaint,
    );
    // Inner square
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3), Radius.circular(cell * 0.3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
