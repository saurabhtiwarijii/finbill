import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/firebase_service.dart';
import '../models/party_due_group.dart';
import '../../sales/screens/sale_detail_screen.dart';
import '../../purchases/screens/purchase_detail_screen.dart';

class PartyDueDetailScreen extends StatelessWidget {
  const PartyDueDetailScreen({
    super.key,
    required this.group,
    required this.isSale,
  });

  final PartyDueGroup group;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    final amountColor = isSale ? AppColors.success : AppColors.error;
    final typeLabel = isSale ? 'Customer' : 'Vendor';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(group.partyName),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Header Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppSizes.md),
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: amountColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  typeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  CurrencyFormatter.format(group.totalAmount),
                  style: AppTextStyles.h1.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Total Due',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (group.phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        group.phoneNumber,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Section Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Individual Dues (${group.dues.length})',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Individual dues list ──────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: group.dues.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                final due = group.dues[index];
                final amount =
                    (due['amount'] as num?)?.toDouble() ?? 0.0;
                final referenceId = due['referenceId'] as String? ?? '';

                // Parse date
                DateTime date;
                final rawDate = due['date'];
                if (rawDate is Timestamp) {
                  date = rawDate.toDate();
                } else if (rawDate is String) {
                  date = DateTime.tryParse(rawDate) ?? DateTime.now();
                } else {
                  date = DateTime.now();
                }

                return InkWell(
                  onTap: () => _navigateToInvoice(
                      context, referenceId, isSale),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border:
                          Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        // Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(date),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('hh:mm a').format(date),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        Text(
                          CurrencyFormatter.format(amount),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Bottom Total Bar ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Due',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(group.totalAmount),
                  style: AppTextStyles.h3.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the Sale or Purchase detail screen.
  Future<void> _navigateToInvoice(
    BuildContext context,
    String referenceId,
    bool isSale,
  ) async {
    if (referenceId.isEmpty) {
      debugPrint('referenceId is empty — cannot navigate');
      return;
    }

    debugPrint('Navigating to invoice: $referenceId (isSale: $isSale)');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (isSale) {
        final sale =
            await FirebaseService.instance.getSaleById(referenceId);
        if (context.mounted) Navigator.of(context).pop();

        if (sale != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaleDetailScreen(sale: sale),
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not found')),
          );
        }
      } else {
        final purchase =
            await FirebaseService.instance.getPurchaseById(referenceId);
        if (context.mounted) Navigator.of(context).pop();

        if (purchase != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PurchaseDetailScreen(purchase: purchase),
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not found')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching invoice: $e');
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
