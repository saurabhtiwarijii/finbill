/// FinBill — Parties screen.
///
/// Customer and supplier management. Shows party list with name, mobile,
/// balance, and receivable/payable indicators. Uses real-time Firestore
/// data via [PartiesController].
///
/// File location: lib/features/parties/screens/parties_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/party_model.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_floating_button.dart';
import '../controllers/parties_controller.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final _controller = PartiesController();

  @override
  void initState() {
    super.initState();
    _controller.loadParties();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.navParties),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              onPressed: () {
                // TODO: Open sort/filter bottom sheet
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = _controller.getCustomers();
          final vendors = _controller.getVendors();

          return Column(
            children: [
              // ── Search bar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: CustomSearchBar(
                  hintText: AppStrings.searchParties,
                  onChanged: _controller.search,
                ),
              ),

              // ── Summary bar ───────────────────────────────────
              if (!_controller.isEmpty) _buildSummaryBar(),

              // ── Tab Views ──────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    // Customers Tab
                    customers.isEmpty
                        ? const EmptyStateWidget(
                            message: 'No customers found',
                            subtitle: AppStrings.noPartiesSubtitle,
                            icon: Icons.people_outline_rounded,
                          )
                        : _buildPartiesList(customers),
                    // Vendors Tab
                    vendors.isEmpty
                        ? const EmptyStateWidget(
                            message: 'No vendors found',
                            subtitle: AppStrings.noPartiesSubtitle,
                            icon: Icons.store_outlined,
                          )
                        : _buildPartiesList(vendors),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // ── FAB: Add Party ────────────────────────────────────────
      floatingActionButton: CustomFloatingButton(
        icon: Icons.person_add_alt_1_rounded,
        label: AppStrings.addParty,
        heroTag: 'parties_fab',
        onPressed: () {
          context.goNamed(RouteNameIds.addParty);
        },
      ), // End CustomFloatingButton
    ), // End Scaffold
    ); // End DefaultTabController
  }

  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Column(
                children: [
                  Text(
                    CurrencyFormatter.format(_controller.totalReceivable),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text('You will receive',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Column(
                children: [
                  Text(
                    CurrencyFormatter.format(_controller.totalPayable),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text('You have to pay',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesList(List<PartyModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.xxl + AppSizes.xl,
      ),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final party = list[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              RouteNameIds.partyDetail,
              pathParameters: {'partyId': party.id},
              extra: party,
            );
          },
          child: _PartyCard(party: party),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Party Card
// ═══════════════════════════════════════════════════════════════════

class _PartyCard extends StatelessWidget {
  const _PartyCard({required this.party});

  final PartyModel party;

  @override
  Widget build(BuildContext context) {
    final isCustomer = party.type == PartyType.customer;
    final typeColor = isCustomer ? AppColors.primary : AppColors.secondary;

    // Balance display
    final balanceAbs = party.balance.abs();
    final Color balanceColor;
    final String balanceLabel;

    if (party.balance > 0) {
      balanceColor = AppColors.success;
      balanceLabel = 'You will receive';
    } else if (party.balance < 0) {
      balanceColor = AppColors.error;
      balanceLabel = 'You have to pay';
    } else {
      balanceColor = AppColors.textHint;
      balanceLabel = 'Settled';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
            ),
            child: Center(
              child: Text(
                party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                style: AppTextStyles.h3.copyWith(color: typeColor),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // ── Info ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party.name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCustomer ? 'Customer' : 'Vendor',
                        style: AppTextStyles.caption.copyWith(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (party.mobile.isNotEmpty) ...[
                      const SizedBox(width: AppSizes.sm),
                      Text(party.mobile, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Balance ────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(balanceAbs),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                balanceLabel,
                style: AppTextStyles.caption.copyWith(
                  color: balanceColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
