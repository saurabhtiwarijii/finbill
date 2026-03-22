/// FinBill — Purchase Report screen.
///
/// Shows purchase history with date filter, search, and totals.
///
/// File location: lib/features/reports/screens/purchase_report_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/purchase_model.dart';
import '../../../services/firebase_service.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<PurchaseModel> _allPurchases = [];
  List<PurchaseModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _allPurchases = await FirebaseService.instance.getPurchases();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day).add(const Duration(days: 1));

    _filtered = _allPurchases.where((p) {
      final inRange = p.date.isAfter(start.subtract(const Duration(seconds: 1))) && p.date.isBefore(end);
      if (_search.isEmpty) return inRange;
      return inRange && p.partyName.toLowerCase().contains(_search.toLowerCase());
    }).toList();
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _filtered.fold<double>(0, (s, e) => s + e.grandTotal);
    final totalDue = _filtered.fold<double>(0, (s, e) => s + e.dueAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Purchase Report'), centerTitle: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Date range picker
                  InkWell(
                    onTap: _pickRange,
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
                          const Icon(Icons.date_range_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '${DateFormat('dd MMM').format(_startDate)} – ${DateFormat('dd MMM yyyy').format(_endDate)}',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Summary
                  Row(
                    children: [
                      Expanded(
                        child: _Chip(label: 'Total Purchases', value: _fmt.format(totalAmount), color: AppColors.error),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _Chip(label: 'Pending Due', value: _fmt.format(totalDue), color: AppColors.warning),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Search
                  TextField(
                    onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
                    decoration: InputDecoration(
                      hintText: 'Search vendor...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  Text('${_filtered.length} purchases', style: AppTextStyles.caption),
                  const SizedBox(height: AppSizes.sm),

                  if (_filtered.isEmpty)
                    _Empty(message: 'No purchases in selected range')
                  else
                    ..._filtered.map((p) => _PurchaseRow(purchase: p, fmt: _fmt)),
                ],
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});
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

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.purchase, required this.fmt});
  final PurchaseModel purchase;
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
                Text(purchase.partyName.isEmpty ? 'Unknown Vendor' : purchase.partyName, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 2),
                Text('${DateFormat('dd MMM').format(purchase.date)}  •  ${purchase.itemCount} items', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(fmt.format(purchase.grandTotal), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.error)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
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
