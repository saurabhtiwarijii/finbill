/// FinBill — Spacing, padding, and sizing constants.
///
/// A single source of truth for all dimensional values prevents
/// inconsistencies across the UI.
library;

class AppSizes {
  AppSizes._();

  // ── Padding / Margin ───────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ── Border Radius ──────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ── Icon Sizes ─────────────────────────────────────────────────
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // ── Card ───────────────────────────────────────────────────────
  static const double cardElevation = 0;
  static const double dashboardCardHeight = 100;
}
