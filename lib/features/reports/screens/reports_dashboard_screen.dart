/// FinBill — Reports Dashboard screen.
///
/// Entry point for all reports. Shows cards linking to each report type.
///
/// File location: lib/features/reports/screens/reports_dashboard_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reports'), centerTitle: false),
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
                const Icon(Icons.analytics_rounded, size: 40, color: Colors.white),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Business Reports', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time insights into your sales, purchases, inventory & dues.',
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
            icon: Icons.point_of_sale_rounded,
            title: 'Daily Sales Report',
            subtitle: 'Today\'s invoices, totals & payment breakdown',
            color: AppColors.success,
            onTap: () => context.goNamed(RouteNameIds.salesReport),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          _ReportCard(
            icon: Icons.shopping_cart_rounded,
            title: 'Purchase Report',
            subtitle: 'Track purchase expenses and vendor spend',
            color: AppColors.error,
            onTap: () => context.goNamed(RouteNameIds.purchaseReport),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          _ReportCard(
            icon: Icons.inventory_2_rounded,
            title: 'Inventory Report',
            subtitle: 'Stock levels, valuations & low stock alerts',
            color: AppColors.primary,
            onTap: () => context.goNamed(RouteNameIds.inventoryReport),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          _ReportCard(
            icon: Icons.reorder_rounded,
            title: 'Smart Order Queue',
            subtitle: 'Items below alert level that need restocking',
            color: AppColors.warning,
            onTap: () => context.goNamed(RouteNameIds.smartOrderQueue),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          _ReportCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Due Report',
            subtitle: 'Customer receivables & vendor payables',
            color: const Color(0xFF7C4DFF),
            onTap: () => context.goNamed(RouteNameIds.dueReport),
          ),
          const SizedBox(height: AppSizes.xl),
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
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
