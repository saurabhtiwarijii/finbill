/// FinBill — Reusable date filter bottom sheet.
///
/// Provides Today / Last 7 Days / Last 30 Days / Custom Range options.
/// Used by both Sales and Purchase list screens.
///
/// File location: lib/widgets/date_filter_bottom_sheet.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum DateFilterType { today, lastWeek, lastMonth, custom }

/// Holds the selected date filter configuration.
class DateFilter {
  const DateFilter({
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  final DateFilterType type;
  final DateTime startDate;
  final DateTime endDate;

  factory DateFilter.today() {
    final now = DateTime.now();
    return DateFilter(
      type: DateFilterType.today,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  factory DateFilter.lastWeek() {
    final now = DateTime.now();
    return DateFilter(
      type: DateFilterType.lastWeek,
      startDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  factory DateFilter.lastMonth() {
    final now = DateTime.now();
    return DateFilter(
      type: DateFilterType.lastMonth,
      startDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29)),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  factory DateFilter.custom(DateTime start, DateTime end) {
    return DateFilter(
      type: DateFilterType.custom,
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
    );
  }

  /// Human-readable label for display.
  String get label {
    switch (type) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.lastWeek:
        return 'Last 7 Days';
      case DateFilterType.lastMonth:
        return 'Last 30 Days';
      case DateFilterType.custom:
        final fmt = DateFormat('dd MMM');
        return '${fmt.format(startDate)} – ${fmt.format(endDate)}';
    }
  }

  /// Check whether a date falls within this filter range.
  bool includes(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

/// Shows filter bottom sheet. Returns a [DateFilter], or `null` if
/// the user selected "Custom Range" (caller must then open date picker
/// and call the callback).
///
/// If [onCustomRequested] is provided, "Custom Range" tap will invoke
/// it instead of returning null.
Future<DateFilter?> showDateFilterBottomSheet(
  BuildContext context, {
  DateFilterType currentFilter = DateFilterType.today,
}) {
  return showModalBottomSheet<DateFilter>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              const Text('Filter by Date', style: AppTextStyles.h3),
              const SizedBox(height: AppSizes.md),
              const Divider(height: 1),

              _FilterOption(
                icon: Icons.today_rounded,
                label: 'Today',
                isSelected: currentFilter == DateFilterType.today,
                onTap: () => Navigator.pop(ctx, DateFilter.today()),
              ),
              _FilterOption(
                icon: Icons.date_range_rounded,
                label: 'Last 7 Days',
                isSelected: currentFilter == DateFilterType.lastWeek,
                onTap: () => Navigator.pop(ctx, DateFilter.lastWeek()),
              ),
              _FilterOption(
                icon: Icons.calendar_month_rounded,
                label: 'Last 30 Days',
                isSelected: currentFilter == DateFilterType.lastMonth,
                onTap: () => Navigator.pop(ctx, DateFilter.lastMonth()),
              ),
              _FilterOption(
                icon: Icons.edit_calendar_rounded,
                label: 'Custom Range',
                isSelected: currentFilter == DateFilterType.custom,
                onTap: () {
                  // Return null — caller will open date range picker
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      );
    },
  );
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.iconDefault,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
