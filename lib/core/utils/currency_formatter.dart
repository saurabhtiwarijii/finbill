/// FinBill — Indian Rupee currency formatter.
///
/// Formats numbers using the Indian numbering system (₹1,23,456.00).
library;

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _formatterWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format [amount] as ₹X,XX,XXX (no decimals).
  static String format(num amount) => _formatter.format(amount);

  /// Format [amount] as ₹X,XX,XXX.00 (with decimals).
  static String formatWithDecimals(num amount) =>
      _formatterWithDecimals.format(amount);
}
