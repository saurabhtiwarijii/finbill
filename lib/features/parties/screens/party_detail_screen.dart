/// FinBill — Party Detail Screen.
///
/// Full CRM + Ledger view for a customer or vendor.
/// Shows profile, due summary, date-filtered invoice history.
///
/// File location: lib/features/parties/screens/party_detail_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/party_model.dart';
import '../../../models/sale_model.dart';
import '../../../models/purchase_model.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/date_filter_bottom_sheet.dart';

class PartyDetailScreen extends StatefulWidget {
  const PartyDetailScreen({
    super.key,
    required this.partyId,
    this.party,
  });

  final String partyId;
  final PartyModel? party;

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  final _firebase = FirebaseService.instance;

  PartyModel? _party;
  bool _isLoading = true;

  // Invoice data
  List<SaleModel> _allSales = [];
  List<PurchaseModel> _allPurchases = [];

  // Filtered lists
  List<SaleModel> _filteredSales = [];
  List<PurchaseModel> _filteredPurchases = [];

  // Date filter
  DateFilter _dateFilter = DateFilter.lastMonth();

  @override
  void initState() {
    super.initState();
    _party = widget.party;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load party if not passed via extra
    if (_party == null) {
      _party = await _firebase.getPartyById(widget.partyId);
    }

    if (_party == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Load invoices based on party type
    if (_party!.type == PartyType.customer) {
      _allSales = await _firebase.getSalesByPartyId(widget.partyId);
    } else {
      _allPurchases = await _firebase.getPurchasesByPartyId(widget.partyId);
    }

    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    _filteredSales = _allSales
        .where((s) => _dateFilter.includes(s.date))
        .toList();
    _filteredPurchases = _allPurchases
        .where((p) => _dateFilter.includes(p.date))
        .toList();
  }

  void _setFilter(DateFilter filter) {
    setState(() {
      _dateFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showDateFilterBottomSheet(
      context,
      currentFilter: _dateFilter.type,
    );

    if (result != null) {
      _setFilter(result);
    } else {
      if (!mounted) return;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        _setFilter(DateFilter.custom(picked.start, picked.end));
      }
    }
  }

  // ── Computed values ──────────────────────────────────────────

  double get _totalDue {
    if (_party == null) return 0;
    if (_party!.type == PartyType.customer) {
      return _allSales.fold(0.0, (sum, s) => sum + s.dueAmount);
    } else {
      return _allPurchases.fold(0.0, (sum, p) => sum + p.dueAmount);
    }
  }

  int get _filteredCount =>
      _party?.type == PartyType.customer
          ? _filteredSales.length
          : _filteredPurchases.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_party?.name ?? 'Party Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _party == null
              ? const Center(child: Text('Party not found'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.md),
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: AppSizes.md),
                      _buildDueSummary(),
                      const SizedBox(height: AppSizes.md),
                      _buildFilterChip(),
                      const SizedBox(height: AppSizes.sm),
                      _buildInvoiceHistory(),
                    ],
                  ),
                ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  A. Profile Card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildProfileCard() {
    final party = _party!;
    final isCustomer = party.type == PartyType.customer;
    final typeColor = isCustomer ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Center(
              child: Text(
                party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                style: AppTextStyles.h2.copyWith(color: typeColor),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party.name, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                if (party.mobile.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(party.mobile, style: AppTextStyles.caption),
                    ],
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCustomer ? 'Customer' : 'Vendor',
                    style: AppTextStyles.caption.copyWith(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  B. Due Summary
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDueSummary() {
    final isCustomer = _party!.type == PartyType.customer;
    final dueColor = _totalDue > 0
        ? (isCustomer ? AppColors.success : AppColors.error)
        : AppColors.textHint;
    final dueLabel = _totalDue > 0
        ? (isCustomer ? 'You will receive' : 'You have to pay')
        : 'No dues';

    final totalInvoices = isCustomer ? _allSales.length : _allPurchases.length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dueColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: dueColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Due',
                  style: AppTextStyles.caption.copyWith(
                    color: dueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(_totalDue),
                  style: AppTextStyles.h2.copyWith(color: dueColor),
                ),
                const SizedBox(height: 2),
                Text(dueLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalInvoices',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'Total ${isCustomer ? 'Sales' : 'Purchases'}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  C. Filter Chip
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterChip() {
    return Row(
      children: [
        Icon(Icons.filter_alt_outlined,
            size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          'Showing: ${_dateFilter.label}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($_filteredCount)',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        if (_dateFilter.type != DateFilterType.lastMonth)
          GestureDetector(
            onTap: () => _setFilter(DateFilter.lastMonth()),
            child: Text(
              'Reset',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  D. Invoice History
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInvoiceHistory() {
    final isCustomer = _party!.type == PartyType.customer;

    if (isCustomer) {
      if (_filteredSales.isEmpty) {
        return _buildEmptyState();
      }
      return Column(
        children: _filteredSales
            .map((sale) => _buildSaleCard(sale))
            .toList(),
      );
    } else {
      if (_filteredPurchases.isEmpty) {
        return _buildEmptyState();
      }
      return Column(
        children: _filteredPurchases
            .map((purchase) => _buildPurchaseCard(purchase))
            .toList(),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSizes.sm),
          Text(
            'No transactions found',
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'for this period',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    final isPaid = sale.dueAmount <= 0;
    return GestureDetector(
      onTap: () => context.goNamed(
        RouteNameIds.invoiceDetail,
        pathParameters: {'invoiceId': sale.id},
        extra: sale,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.invoiceNumber, style: AppTextStyles.bodyMedium),
                  Text(
                    DateFormatter.format(sale.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(sale.grandTotal),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildStatusBadge(isPaid, sale.dueAmount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel purchase) {
    final isPaid = purchase.dueAmount <= 0;
    return GestureDetector(
      onTap: () => context.goNamed(
        RouteNameIds.purchaseDetail,
        pathParameters: {'purchaseId': purchase.id},
        extra: purchase,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(purchase.billNumber, style: AppTextStyles.bodyMedium),
                  Text(
                    DateFormatter.format(purchase.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(purchase.grandTotal),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildStatusBadge(isPaid, purchase.dueAmount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid, double dueAmount) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Due ${CurrencyFormatter.format(dueAmount)}',
        style: AppTextStyles.caption.copyWith(
          color: isPaid ? AppColors.success : AppColors.error,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
