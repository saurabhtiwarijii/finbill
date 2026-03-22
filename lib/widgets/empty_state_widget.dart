/// FinBill — Empty state placeholder widget.
///
/// Shown when a list screen has no data (Sales, Purchases, Parties, Inventory).
/// Displays an icon, primary message, optional subtitle, and optional action
/// button — all styled via the design system.
///
/// Usage:
///   EmptyStateWidget(message: 'No sales found')
///   EmptyStateWidget(
///     message: 'No parties yet',
///     subtitle: 'Add your first customer or supplier',
///     actionLabel: 'Add Party',
///     onAction: () => context.goNamed(RouteNameIds.addParty),
///   )
///
/// File location: lib/widgets/empty_state_widget.dart
library;

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_sizes.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Primary message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],

            // Action button
            if (actionLabel != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
