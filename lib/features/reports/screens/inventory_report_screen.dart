/// FinBill — Inventory Report screen.
///
/// Lists all items with stock levels, valuations, and low stock highlights.
///
/// File location: lib/features/reports/screens/inventory_report_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/item_model.dart';
import '../../../services/firebase_service.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<ItemModel> _items = [];
  List<ItemModel> _filtered = [];
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
    _items = await FirebaseService.instance.getItems();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    if (_search.isEmpty) {
      _filtered = List.of(_items);
    } else {
      _filtered = _items.where((i) => i.name.toLowerCase().contains(_search.toLowerCase())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _filtered.length;
    final totalStockValue = _filtered.fold<double>(0, (s, i) => s + (i.stock * i.buyPrice));
    final lowStockCount = _filtered.where((i) => i.isLowStock).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Inventory Report'), centerTitle: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Summary row
                  Row(
                    children: [
                      Expanded(child: _Chip(label: 'Total Items', value: '$totalItems', color: AppColors.primary)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: _Chip(label: 'Stock Value', value: _fmt.format(totalStockValue), color: AppColors.success)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: _Chip(label: 'Low Stock', value: '$lowStockCount', color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Search
                  TextField(
                    onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
                    decoration: InputDecoration(
                      hintText: 'Search item...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  if (_filtered.isEmpty)
                    _EmptyState(message: 'No items found')
                  else
                    ..._filtered.map((item) => _ItemRow(item: item, fmt: _fmt)),
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.fmt});
  final ItemModel item;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final stockValue = item.stock * item.buyPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: item.isLowStock ? AppColors.warning.withValues(alpha: 0.5) : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (item.isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Low Stock', style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              _Detail(label: 'Stock', value: '${item.stock.toStringAsFixed(item.stock == item.stock.roundToDouble() ? 0 : 1)} ${item.unit}'),
              _Detail(label: 'Buy', value: fmt.format(item.buyPrice)),
              _Detail(label: 'Sell', value: fmt.format(item.sellPrice)),
              _Detail(label: 'Value', value: fmt.format(stockValue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
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
