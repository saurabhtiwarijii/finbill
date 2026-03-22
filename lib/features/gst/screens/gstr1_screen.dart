/// FinBill — GSTR-1 Screen (Sales GST Report).
///
/// Shows filtered sales where GST is applied. Includes totals for
/// taxable value, GST collected, and total amount.
///
/// File location: lib/features/gst/screens/gstr1_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/sale_model.dart';
import '../../../services/firebase_service.dart';

class Gstr1Screen extends StatefulWidget {
  const Gstr1Screen({super.key});

  @override
  State<Gstr1Screen> createState() => _Gstr1ScreenState();
}

class _Gstr1ScreenState extends State<Gstr1Screen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  
  List<SaleModel> _allSales = [];
  List<SaleModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final sales = await FirebaseService.instance.getSales();
    
    // FILTER CONDITION: Only sales with GST applied
    _allSales = sales.where((s) => s.hasGst || s.totalTax > 0).toList();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day).add(const Duration(days: 1));

    _filtered = _allSales.where((s) {
      final inRange = s.date.isAfter(start.subtract(const Duration(seconds: 1))) && s.date.isBefore(end);
      if (_search.isEmpty) return inRange;
      
      return inRange &&
          (s.partyName.toLowerCase().contains(_search.toLowerCase()) ||
              s.invoiceNumber.toLowerCase().contains(_search.toLowerCase()));
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
    final totalTaxable = _filtered.fold<double>(0, (s, e) => s + e.subtotal);
    final totalGst = _filtered.fold<double>(0, (s, e) => s + e.totalTax);
    final totalAmount = _filtered.fold<double>(0, (s, e) => s + e.grandTotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('GSTR-1 (Sales)'), centerTitle: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Date Picker
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
                            '${DateFormat('dd MMM yyyy').format(_startDate)} – ${DateFormat('dd MMM yyyy').format(_endDate)}',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Top Summary
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Taxable Value', style: AppTextStyles.bodyMedium),
                            Text(_fmt.format(totalTaxable), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total GST Collected', style: AppTextStyles.bodyMedium),
                            Text(_fmt.format(totalGst), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.success)),
                          ],
                        ),
                        const Divider(height: AppSizes.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                            Text(_fmt.format(totalAmount), style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
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

                  Text('${_filtered.length} GST Invoices', style: AppTextStyles.caption),
                  const SizedBox(height: AppSizes.sm),

                  if (_filtered.isEmpty)
                    const _EmptyState(message: 'No GST sales found in selected range')
                  else
                    ..._filtered.map((sale) => _Gstr1Row(sale: sale, fmt: _fmt)),
                ],
              ),
            ),
    );
  }
}

class _Gstr1Row extends StatelessWidget {
  const _Gstr1Row({required this.sale, required this.fmt});
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sale.partyName.isEmpty ? 'Walk-in Customer' : sale.partyName,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('dd MMM yy').format(sale.date),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Inv: ${sale.invoiceNumber}', style: AppTextStyles.caption),
          const Divider(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ColumnData(label: 'Taxable', value: fmt.format(sale.subtotal)),
              _ColumnData(label: 'GST', value: fmt.format(sale.totalTax), isHighlight: true),
              _ColumnData(label: 'Total', value: fmt.format(sale.grandTotal), alignRight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColumnData extends StatelessWidget {
  const _ColumnData({required this.label, required this.value, this.isHighlight = false, this.alignRight = false});
  final String label;
  final String value;
  final bool isHighlight;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isHighlight ? AppColors.success : null,
          ),
        ),
      ],
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
            const Icon(Icons.article_outlined, size: 56, color: AppColors.textHint),
            const SizedBox(height: AppSizes.md),
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
