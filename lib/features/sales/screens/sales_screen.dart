/// FinBill — Sales screen.
///
/// Displays the list of sales/invoices with a search bar, date filter,
/// and a FAB for creating new sales. Uses [SalesController] for state
/// management and GoRouter for navigation.
///
/// File location: lib/features/sales/screens/sales_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_floating_button.dart';
import '../../../widgets/date_filter_bottom_sheet.dart';
import '../controllers/sales_controller.dart';
import '../widgets/sale_invoice_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _controller = SalesController();

  @override
  void initState() {
    super.initState();
    _controller.loadSales();
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
      // Preset filter selected
      _controller.setDateFilter(result);
    } else {
      // Custom range requested — open date range picker
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
        title: const Text(AppStrings.sales),
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
                  hintText: AppStrings.searchSales,
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
                            message: AppStrings.noSales,
                            subtitle: 'No invoices found for this period',
                            icon: Icons.receipt_long_outlined,
                          )
                        : _buildSalesList(),
              ),
            ],
          );
        },
      ),

      // ── FAB: Add Sale ─────────────────────────────────────────
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        label: AppStrings.addSale,
        heroTag: 'sales_fab',
        onPressed: () {
          context.goNamed(RouteNameIds.createInvoice);
        },
      ),
    );
  }

  Widget _buildSalesList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      itemCount: _controller.sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final sale = _controller.sales[index];
        return SaleInvoiceCard(
          sale: sale,
          onTap: () {
            context.goNamed(
              RouteNameIds.invoiceDetail,
              pathParameters: {'invoiceId': sale.id},
              extra: sale,
            );
          },
        );
      },
    );
  }
}
