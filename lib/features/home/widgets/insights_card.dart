/// FinBill — Today's Insights card.
///
/// Displays a single metric (e.g. "Sales ₹0") inside a compact card.
/// Two of these sit side-by-side on the Home dashboard.
///
/// File location: lib/features/home/widgets/insights_card.dart
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final num amount;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: AppSizes.sm + 4),

              // Title
              Text(title, style: AppTextStyles.label),
              const SizedBox(height: AppSizes.xs),

              // Amount
              Text(
                CurrencyFormatter.format(amount),
                style: AppTextStyles.amount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
