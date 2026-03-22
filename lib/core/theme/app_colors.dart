/// FinBill — Centralized color palette.
///
/// Single source of truth for every color in the app. Screens and widgets
/// reference these constants instead of hardcoding hex values.
///
/// File location: lib/core/theme/app_colors.dart
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand (fintech blue) ───────────────────────────────
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF26A69A);      // Teal accent

  // ── Gradients (AI card, premium accents) ───────────────────────
  static const Color gradientStart = Color(0xFF1E88E5);
  static const Color gradientEnd = Color(0xFF7C4DFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Surface / Background ───────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color cardBorder = Color(0xFFE0E0E0);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // ── Status ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF29B6F6);

  // ── Misc ───────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEEEEEE);
  static const Color iconDefault = Color(0xFF616161);
  static const Color shimmer = Color(0xFFE0E0E0);
}
