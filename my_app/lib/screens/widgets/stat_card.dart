import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value, trend;
  final IconData icon;
  final Color color;
  final bool isTrendUp;
  final List<Color>? gradientColors;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isTrendUp,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradientColors != null && gradientColors!.length >= 2;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: hasGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: hasGradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasGradient
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: hasGradient ? Colors.white : color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: hasGradient
                      ? Colors.white.withOpacity(0.15)
                      : (isTrendUp
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.textLight.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isTrendUp
                      ? Icons.trending_up_rounded
                      : Icons.trending_flat_rounded,
                  color: hasGradient
                      ? Colors.white70
                      : (isTrendUp ? AppTheme.success : AppTheme.textLight),
                  size: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: hasGradient ? Colors.white : AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: hasGradient
                  ? Colors.white.withOpacity(0.8)
                  : AppTheme.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              color: hasGradient
                  ? Colors.white.withOpacity(0.65)
                  : (isTrendUp ? AppTheme.success : AppTheme.textLight),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
