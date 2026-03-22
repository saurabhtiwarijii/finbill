/// FinBill — PrimaryButton widget.
///
/// The main CTA button used across the app. Supports three variants:
///   • [PrimaryButtonVariant.filled]   — solid primary background (default)
///   • [PrimaryButtonVariant.outlined] — primary border, transparent fill
///   • [PrimaryButtonVariant.text]     — no border, no fill
///
/// Also supports a loading state, leading icon, and full-width stretch.
///
/// Usage:
///   PrimaryButton(label: 'Save', onPressed: () {})
///   PrimaryButton(label: 'Cancel', variant: PrimaryButtonVariant.outlined)
///   PrimaryButton(label: 'Saving...', isLoading: true)
///   PrimaryButton(label: 'Add Sale', icon: Icons.add, isExpanded: true)
///
/// File location: lib/widgets/primary_button.dart
library;

import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';

enum PrimaryButtonVariant { filled, outlined, text }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PrimaryButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm),
                const SizedBox(width: AppSizes.sm),
              ],
              Text(label),
            ],
          );

    // Select widget type based on variant.
    Widget button;
    switch (variant) {
      case PrimaryButtonVariant.filled:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case PrimaryButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case PrimaryButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
