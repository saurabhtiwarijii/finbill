/// FinBill — Pending Actions card.
///
/// Shown on the Home dashboard. Displays a status icon, title, subtitle,
/// and a "View More" button that will navigate to a detailed list.
///
/// File location: lib/features/home/widgets/pending_actions_card.dart
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PendingActionsCard extends StatelessWidget {
  const PendingActionsCard({
    super.key,
    this.subtitle,
    this.count = 0,
    this.onViewMore,
  });

  /// Descriptive subtitle. Falls back to a default message when null.
  final String? subtitle;

  /// Badge count for pending items.
  final int count;

  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md + 4),
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
      child: Row(
        children: [
          // Icon with warning accent
          Container(
            padding: const EdgeInsets.all(AppSizes.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppStrings.pendingActions, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? AppStrings.pendingSubtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // View More
          TextButton(
            onPressed: onViewMore,
            child: const Text(AppStrings.viewMore),
          ),
        ],
      ),
    );
  }
}
