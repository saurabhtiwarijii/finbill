/// FinBill — Generic dashboard card wrapper.
///
/// A styled container used across dashboard sections. Supports solid color,
/// gradient backgrounds, tap interactions, and optional border toggle.
/// All spacing comes from [AppSizes] — no hardcoded values.
///
/// Usage:
///   DashboardCard(child: Text('Hello'))
///   DashboardCard(gradient: AppColors.primaryGradient, child: ...)
///
/// File location: lib/widgets/dashboard_card.dart
library;

import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.onTap,
    this.showBorder = true,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool showBorder;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSizes.radiusLg;

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: (showBorder && gradient == null)
            ? Border.all(color: AppColors.cardBorder)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return content;
  }
}
