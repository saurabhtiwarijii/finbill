/// FinBill — Subscription Plans screen.
///
/// Displays the three available plans (Lite, Standard, Elite) as
/// visually distinct cards. The active plan is highlighted with a
/// gradient border and "Current Plan" badge.
///
/// File location: lib/features/menu/subscription/screens/subscription_screen.dart
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/plan_config.dart';
import '../../../../core/config/feature_access.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final isActive = plan.name == activePlan;

          return _PlanCard(plan: plan, isActive: isActive);
        },
      ),
    );
  }
}

// ── Plan Card ────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isActive});

  final Plan plan;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    // Accent color per plan tier
    final Color accentColor = switch (plan.name) {
      'Lite' => AppColors.secondary,
      'Standard' => AppColors.primary,
      'Elite' => const Color(0xFF7C4DFF),
      _ => AppColors.primary,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isActive ? accentColor : AppColors.cardBorder,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLg - 1),
              ),
            ),
            child: Row(
              children: [
                // Plan icon
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    _planIcon(plan.name),
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.sm + 4),

                // Plan name & price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: AppTextStyles.h3.copyWith(color: accentColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPrice(plan.price),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active badge
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm + 4,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Active',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Feature List ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 4,
            ),
            child: Column(
              children: plan.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Action Button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md, 0, AppSizes.md, AppSizes.md,
            ),
            child: isActive
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accentColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.sm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Current Plan',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      // TODO: Handle plan upgrade flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upgrade to ${plan.name} coming soon!'),
                          backgroundColor: accentColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.sm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Upgrade',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  IconData _planIcon(String name) => switch (name) {
    'Lite' => Icons.rocket_launch_outlined,
    'Standard' => Icons.workspace_premium_outlined,
    'Elite' => Icons.diamond_outlined,
    _ => Icons.star_outline_rounded,
  };

  String _formatPrice(double price) {
    if (price == 0) return 'Free';
    return '₹${price.toInt()}/year';
  }
}
