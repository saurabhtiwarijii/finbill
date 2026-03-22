import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/firebase_service.dart';
import '../models/party_due_group.dart';
import 'party_due_detail_screen.dart';

class DueTrackerScreen extends StatelessWidget {
  const DueTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService.instance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Due Tracker'),
          centerTitle: false,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: firebaseService.streamPendingDues(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading dues.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              );
            }

            final dues = snapshot.data ?? [];

            // Filter by type
            final customerDues = dues.where((d) => d['type'] == 'sale').toList();
            final vendorDues = dues.where((d) => d['type'] == 'purchase').toList();

            // Group by partyName
            final customerGroups = _groupByParty(customerDues);
            final vendorGroups = _groupByParty(vendorDues);

            return TabBarView(
              children: [
                _buildGroupedList(context, customerGroups, isSale: true),
                _buildGroupedList(context, vendorGroups, isSale: false),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Groups a list of due maps by partyName into PartyDueGroup objects.
  List<PartyDueGroup> _groupByParty(List<Map<String, dynamic>> dues) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final due in dues) {
      final name = due['partyName'] as String? ?? 'Unknown Party';
      grouped.putIfAbsent(name, () => []).add(due);
    }

    return grouped.entries.map((entry) {
      final partyDues = entry.value;
      final total = partyDues.fold<double>(
        0,
        (sum, d) => sum + ((d['amount'] as num?)?.toDouble() ?? 0),
      );
      // Use phoneNumber from the first due that has it
      final phone = partyDues
              .map((d) => d['phoneNumber'] as String? ?? '')
              .firstWhere((p) => p.isNotEmpty, orElse: () => '');

      return PartyDueGroup(
        partyName: entry.key,
        phoneNumber: phone,
        totalAmount: total,
        dues: partyDues,
      );
    }).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<PartyDueGroup> groups, {
    required bool isSale,
  }) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('No pending dues', style: AppTextStyles.bodyLarge),
      );
    }

    final amountColor = isSale ? AppColors.success : AppColors.error;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final group = groups[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PartyDueDetailScreen(
                  group: group,
                  isSale: isSale,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: amountColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSale
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: amountColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // Party Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.partyName,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.phoneNumber.isNotEmpty
                            ? group.phoneNumber
                            : '${group.dues.length} due${group.dues.length > 1 ? 's' : ''}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // Total Amount
                Text(
                  CurrencyFormatter.format(group.totalAmount),
                  style: AppTextStyles.h3.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
