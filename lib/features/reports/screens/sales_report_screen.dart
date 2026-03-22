/// FinBill — Daily Sales Report screen.
///
/// Shows today's (or filtered date's) sales with totals and invoice list.
///
/// File location: lib/features/reports/screens/sales_report_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/sale_model.dart';
import '../../../services/firebase_service.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime _selectedDate = DateTime.now();
  List<SaleModel> _allSales = [];
  List<SaleModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    _allSales = await FirebaseService.instance.getSales();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    final dayStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    _filtered = _allSales.where((s) {
      final inRange = s.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) && s.date.isBefore(dayEnd);
      if (_search.isEmpty) return inRange;
      return inRange &&
          (s.partyName.toLowerCase().contains(_search.toLowerCase()) ||
              s.invoiceNumber.toLowerCase().contains(_search.toLowerCase()));
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSales = _filtered.fold<double>(0, (s, e) => s + e.grandTotal);
    final totalPaid = _filtered.fold<double>(0, (s, e) => s + e.paidAmount);
    final totalDue = _filtered.fold<double>(0, (s, e) => s + e.dueAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daily Sales Report'), centerTitle: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadSales,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Date picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: AppSizes.sm),
                          Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: AppTextStyles.bodyLarge),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(child: _SummaryChip(label: 'Total Sales', value: _currencyFmt.format(totalSales), color: AppColors.success)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: _SummaryChip(label: 'Received', value: _currencyFmt.format(totalPaid), color: AppColors.primary)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: _SummaryChip(label: 'Due', value: _currencyFmt.format(totalDue), color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Search
                  TextField(
                    onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
                    decoration: InputDecoration(
                      hintText: 'Search by customer or invoice...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  Text('${_filtered.length} invoices', style: AppTextStyles.caption),
                  const SizedBox(height: AppSizes.sm),

                  if (_filtered.isEmpty)
                    _EmptyState(message: 'No sales on ${DateFormat('dd MMM').format(_selectedDate)}')
                  else
                    ..._filtered.map((sale) => _SaleRow(sale: sale, fmt: _currencyFmt)),
                ],
              ),
            ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4, horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.fmt});
  final SaleModel sale;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.partyName.isEmpty ? 'Walk-in Customer' : sale.partyName, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 2),
                Text('${sale.invoiceNumber}  •  ${sale.paymentMode.toUpperCase()}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(sale.grandTotal), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.success)),
              if (sale.dueAmount > 0)
                Text('Due: ${fmt.format(sale.dueAmount)}', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: AppSizes.md),
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
