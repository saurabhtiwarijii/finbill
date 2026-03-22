/// FinBill — Sale Invoice Card.
///
/// Displays a quick summary of a single sale, including an action
/// button to print/download the invoice PDF.
///
/// File location: lib/features/sales/widgets/sale_invoice_card.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/sale_model.dart';
import '../services/invoice_pdf_service.dart';

class SaleInvoiceCard extends StatelessWidget {
  const SaleInvoiceCard({
    super.key,
    required this.sale,
    this.onTap,
  });

  final SaleModel sale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.partyName.isNotEmpty ? sale.partyName : 'Cash Sale',
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'INV-${sale.invoiceNumber}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '•',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        DateFormat('dd MMM yy').format(sale.date),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildPaymentBadge(sale.dueAmount),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),

            // Amount and Print
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currencyFormat.format(sale.grandTotal),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                InkWell(
                  onTap: () {
                    InvoicePdfService.printInvoice(sale);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.print, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Print',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(double dueAmount) {
    final isPaid = dueAmount <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
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
