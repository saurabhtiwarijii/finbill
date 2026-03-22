/// FinBill — Due Report screen.
///
/// Two-tab view: Customers (Receivable) and Vendors (Payable),
/// grouped by party with total due amounts.
///
/// File location: lib/features/reports/screens/due_report_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/party_model.dart';
import '../../../services/firebase_service.dart';

class DueReportScreen extends StatefulWidget {
  const DueReportScreen({super.key});

  @override
  State<DueReportScreen> createState() => _DueReportScreenState();
}

class _DueReportScreenState extends State<DueReportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  List<PartyModel> _customers = [];
  List<PartyModel> _vendors = [];
  bool _loading = true;
  String _search = '';

  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final parties = await FirebaseService.instance.getParties();
    _customers = parties.where((p) => p.type == PartyType.customer && p.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    _vendors = parties.where((p) => p.type == PartyType.supplier && p.balance < 0).toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));
    setState(() => _loading = false);
  }

  List<PartyModel> _searchFilter(List<PartyModel> list) {
    if (_search.isEmpty) return list;
    return list.where((p) =>
        p.name.toLowerCase().contains(_search.toLowerCase()) ||
        p.mobile.contains(_search)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalReceivable = _customers.fold<double>(0, (s, p) => s + p.balance);
    final totalPayable = _vendors.fold<double>(0, (s, p) => s + p.balance.abs());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Due Report'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Receivable (${_customers.length})'),
            Tab(text: 'Payable (${_vendors.length})'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Summary
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Expanded(child: _Chip(label: 'To Receive', value: _fmt.format(totalReceivable), color: AppColors.success)),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: _Chip(label: 'To Pay', value: _fmt.format(totalPayable), color: AppColors.error)),
                    ],
                  ),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.cardBorder)),
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),

                // Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _PartyList(parties: _searchFilter(_customers), fmt: _fmt, isReceivable: true, onRefresh: _load),
                      _PartyList(parties: _searchFilter(_vendors), fmt: _fmt, isReceivable: false, onRefresh: _load),
                    ],
                  ),
                ),
              ],
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

class _PartyList extends StatelessWidget {
  const _PartyList({required this.parties, required this.fmt, required this.isReceivable, required this.onRefresh});
  final List<PartyModel> parties;
  final NumberFormat fmt;
  final bool isReceivable;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (parties.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: AppSizes.md),
            Text(
              isReceivable ? 'No pending receivables' : 'No pending payables',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: parties.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
        itemBuilder: (context, index) {
          final party = parties[index];
          final amount = party.balance.abs();

          return Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (isReceivable ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  child: Text(
                    party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                    style: TextStyle(color: isReceivable ? AppColors.success : AppColors.error, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(party.name, style: AppTextStyles.bodyLarge),
                      if (party.mobile.isNotEmpty)
                        Text(party.mobile, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Text(
                  fmt.format(amount),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isReceivable ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
