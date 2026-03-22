/// FinBill — Custom styled Floating Action Button.
///
/// Wraps Flutter's FAB with FinBill design system styling. Supports:
///   • Extended mode (icon + label)
///   • Mini mode (smaller secondary actions)
///   • Custom colors for non-primary FABs (e.g. mic, camera)
///
/// Usage:
///   CustomFloatingButton(icon: Icons.add, onPressed: () {})
///   CustomFloatingButton(icon: Icons.add, label: 'Add Sale', onPressed: () {})
///   CustomFloatingButton(icon: Icons.mic, mini: true, color: Colors.teal)
///
/// File location: lib/widgets/custom_floating_button.dart
library;

import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.heroTag,
    this.mini = false,
    this.color,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final String? heroTag;
  final bool mini;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;
    final fgColor = foregroundColor ?? AppColors.textOnPrimary;

    // If label is provided, use extended FAB.
    if (label != null) {
      return FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        icon: Icon(icon),
        label: Text(
          label!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    // Standard or mini FAB.
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      mini: mini,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(mini ? AppSizes.radiusMd : AppSizes.radiusLg),
      ),
      child: Icon(icon, size: mini ? 20 : 24),
    );
  }
}
