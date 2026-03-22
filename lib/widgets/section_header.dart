/// FinBill — Reusable section header.
///
/// Displays an uppercase label for grouped content (Menu sections, dashboard
/// groups). Supports an optional trailing action widget.
///
/// Usage:
///   SectionHeader(title: 'BUSINESS')
///   SectionHeader(title: 'REPORTS', trailing: TextButton(...))
///
/// File location: lib/widgets/section_header.dart
library;

import 'package:flutter/material.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.lg,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.overline),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
