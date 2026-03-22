/// FinBill — Date formatting utilities.
///
/// Provides consistent date/time formatting across the app.
/// All date display patterns are centralised here.
///
/// File location: lib/core/utils/date_formatter.dart
library;

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dayMonthYear = DateFormat('dd MMM yyyy');
  static final _dayMonth = DateFormat('dd MMM');
  static final _dayMonthYearTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _timeOnly = DateFormat('hh:mm a');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _isoDate = DateFormat('yyyy-MM-dd');

  /// "12 Mar 2026"
  static String format(DateTime date) => _dayMonthYear.format(date);

  /// "12 Mar" — compact, no year
  static String formatShort(DateTime date) => _dayMonth.format(date);

  /// "12 Mar 2026, 03:45 PM"
  static String formatWithTime(DateTime date) =>
      _dayMonthYearTime.format(date);

  /// "03:45 PM"
  static String formatTime(DateTime date) => _timeOnly.format(date);

  /// "Mar 2026"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// "2026-03-12" — for Firestore/API queries
  static String formatIso(DateTime date) => _isoDate.format(date);

  /// Returns "Today", "Yesterday", or the formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return format(date);
  }
}
