/// FinBill — Purchases screen.
///
/// Displays purchase records with search, filter, and an Add Purchase FAB.
/// Uses [PurchasesController] for real-time Firestore data and GoRouter
/// for navigation.
///
/// File location: lib/features/purchases/screens/purchases_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_floating_button.dart';
import '../../../widgets/date_filter_bottom_sheet.dart';
import '../../../models/purchase_model.dart';
import '../controllers/purchases_controller.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _controller = PurchasesController();

  @override
  void initState() {
    super.initState();
    _controller.loadPurchases();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final result = await showDateFilterBottomSheet(
      context,
      currentFilter: _controller.dateFilter.type,
    );

    if (result != null) {
      _controller.setDateFilter(result);
    } else {
      // Custom range requested
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
        _controller.setDateFilter(
          DateFilter.custom(picked.start, picked.end),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.purchases),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              // ── Search bar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: CustomSearchBar(
                  hintText: AppStrings.searchPurchases,
                  onChanged: _controller.search,
                ),
              ),

              // ── Active filter chip ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Showing: ${_controller.dateFilter.label}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_controller.dateFilter.type != DateFilterType.today)
                      GestureDetector(
                        onTap: () => _controller.setDateFilter(DateFilter.today()),
                        child: Text(
                          'Reset',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // ── Content ──────────────────────────────────────
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.isEmpty
                        ? const EmptyStateWidget(
                            message: AppStrings.noPurchases,
                            subtitle: 'No purchases found for this period',
                            icon: Icons.shopping_bag_outlined,
                          )
                        : _buildPurchasesList(),
              ),
            ],
          );
        },
      ),

      // ── FAB: Add Purchase ─────────────────────────────────────
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        label: AppStrings.addPurchase,
        heroTag: 'purchases_fab',
        onPressed: () {
          context.goNamed(RouteNameIds.addPurchase);
        },
      ),
    );
  }

  /// Builds the list of purchases with real Firestore data.
  Widget _buildPurchasesList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.xxl + AppSizes.xl, // room for FAB
      ),
      itemCount: _controller.purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final purchase = _controller.purchases[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              RouteNameIds.purchaseDetail,
              pathParameters: {'purchaseId': purchase.id},
              extra: purchase,
            );
          },
          child: _PurchaseCard(purchase: purchase),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Purchase Card
// ═══════════════════════════════════════════════════════════════════

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase});

  final PurchaseModel purchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: bill number + date ──────────────────
          Row(
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
                    Text(
                      purchase.partyName.isNotEmpty
                          ? purchase.partyName
                          : 'Walk-in Vendor',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      '${purchase.billNumber} • ${DateFormatter.formatShort(purchase.date)}',
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
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormatter.formatRelative(purchase.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),

          // ── Bottom row: item count + GST badge ──────────
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Text(
                '${purchase.itemCount} item${purchase.itemCount != 1 ? 's' : ''}',
                style: AppTextStyles.caption,
              ),
              if (purchase.hasGst) ...[
                const SizedBox(width: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'GST',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: AppSizes.sm),
              _buildPaymentBadge(purchase.dueAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(double dueAmount) {
    final isPaid = dueAmount <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.success : AppColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Due ₹${dueAmount.toStringAsFixed(0)}',
        style: AppTextStyles.caption.copyWith(
          color: isPaid ? AppColors.success : AppColors.error,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
