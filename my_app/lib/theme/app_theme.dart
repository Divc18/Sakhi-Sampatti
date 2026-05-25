import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Palette ────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primarySoft  = Color(0xFF43A047);
  static const Color primaryGlow  = Color(0xFF66BB6A);

  static const Color accent       = Color(0xFFFF8F00);
  static const Color accentLight  = Color(0xFFFFB300);
  static const Color accentSoft   = Color(0xFFFFF3E0);

  // ─── Surfaces ─────────────────────────────────────────────────────────────
  static const Color surface      = Color(0xFFF4F7F4);
  static const Color surfaceAlt   = Color(0xFFEEF4EE);
  static const Color card         = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFAFDFA);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textDark     = Color(0xFF0D1F0D);
  static const Color textMid      = Color(0xFF3A5C3A);
  static const Color textLight    = Color(0xFF7E9C7A);
  static const Color textHint     = Color(0xFFABC3A5);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF00897B);
  static const Color successLight = Color(0xFFE0F2F1);
  static const Color error        = Color(0xFFD32F2F);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color warning      = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info         = Color(0xFF1565C0);
  static const Color infoLight    = Color(0xFFE3F2FD);

  // ─── UI ───────────────────────────────────────────────────────────────────
  static const Color divider      = Color(0xFFE2EDE2);
  static const Color shimmer1     = Color(0xFFEAF0EA);
  static const Color shimmer2     = Color(0xFFF5F8F5);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A1A), Color(0xFF1B5E20), Color(0xFF256025)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8F00), Color(0xFFFFB300)],
  );

  static const LinearGradient savingsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00695C), Color(0xFF00897B)],
  );

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1B5E20).withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF1B5E20).withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  // ─── Theme ────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F5F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textLight, fontFamily: 'Nunito'),
        hintStyle: const TextStyle(color: textLight, fontFamily: 'Nunito'),
      ),
    );
  }
}
