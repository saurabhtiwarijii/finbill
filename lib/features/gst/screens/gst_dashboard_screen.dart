/// FinBill — GST Dashboard screen.
///
/// Entry point for GST reports. Shows cards linking to GSTR-1 and GSTR-2.
///
/// File location: lib/features/gst/screens/gst_dashboard_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';

class GstDashboardScreen extends StatelessWidget {
  const GstDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('GST Dashboard'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 40, color: Colors.white),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GST Reports', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your GST filing reports for sales and purchases seamlessly.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          _ReportCard(
            icon: Icons.receipt_long_rounded,
            title: 'GSTR-1 (Sales)',
            subtitle: 'Record of all outward supplies of goods and services.',
            color: AppColors.success,
            onTap: () => context.goNamed(RouteNameIds.gstr1),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          _ReportCard(
            icon: Icons.shopping_cart_checkout_rounded,
            title: 'GSTR-2 (Purchases)',
            subtitle: 'Record of all inward supplies of goods and services.',
            color: AppColors.error,
            onTap: () => context.goNamed(RouteNameIds.gstr2),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
