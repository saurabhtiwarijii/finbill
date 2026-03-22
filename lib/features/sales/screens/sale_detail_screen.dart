/// FinBill — Read-only detail view for a specific Sale.
///
/// Displays invoice number, dates, party info, list of items,
/// and total calculations. Includes Print and Share actions.
///
/// File location: lib/features/sales/screens/sale_detail_screen.dart
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/sale_model.dart';
import '../../../models/business_model.dart';
import '../../../models/print_settings_model.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/firebase_service.dart';
import '../services/invoice_pdf_service.dart';
import 'add_sale_screen.dart';

class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({
    super.key,
    required this.sale,
  });

  final SaleModel sale;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  bool _isPrinting = false;
  bool _isSharing = false;
  bool _isDeleting = false;

  SaleModel get sale => widget.sale;

  // ── Actions ──────────────────────────────────────────────────

  Future<void> _handlePrint() async {
    setState(() => _isPrinting = true);
    try {
      await InvoicePdfService.printInvoice(sale);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);
    try {
      final firebase = FirebaseService.instance;
      final business = await firebase.getBusinessProfile();
      final settings = await firebase.getPrintSettings();

      final pdfBytes = await InvoicePdfService.generateInvoicePdf(
        sale,
        business ?? BusinessModel(id: firebase.businessId, name: 'My Business'),
        settings ?? const PrintSettingsModel(),
      );

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${sale.invoiceNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      // Share via system share sheet (WhatsApp, etc.)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice ${sale.invoiceNumber} - ${CurrencyFormatter.format(sale.grandTotal)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _handleEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddSaleScreen(existingSale: sale),
      ),
    ).then((_) {
      // Pop back to sales list after edit to avoid stale data
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _handleDelete() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: const Text(
          'This action cannot be undone. All related records '
          '(dues, stock adjustments) will be reverted.\n\n'
          'Are you sure you want to delete this invoice?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await FirebaseService.instance.deleteSale(sale);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(); // Go back to sales list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          // Edit button
          IconButton(
            onPressed: _handleEdit,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Invoice',
          ),
          // Print button
          IconButton(
            onPressed: _isPrinting ? null : _handlePrint,
            icon: _isPrinting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_rounded),
            tooltip: 'Print Invoice',
          ),
          // Share button
          IconButton(
            onPressed: _isSharing ? null : _handleShare,
            icon: _isSharing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_rounded),
            tooltip: 'Share Invoice',
          ),
          // More menu with Delete
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _handleDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Invoice', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            _buildHeaderCard(),
            const SizedBox(height: AppSizes.lg),
            
            // Items List
            const Text('Items', style: AppTextStyles.h3),
            const SizedBox(height: AppSizes.sm),
            _buildItemsList(),
            const SizedBox(height: AppSizes.lg),
            
            // Totals
            _buildTotalsCard(),
            const SizedBox(height: AppSizes.lg),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
          _infoRow('Invoice Number', sale.invoiceNumber, isBold: true),
          const SizedBox(height: AppSizes.sm),
          _infoRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(sale.date)),
          const Divider(height: AppSizes.lg),
          _infoRow('Party Name', sale.partyName.isNotEmpty ? sale.partyName : 'Cash Sale'),
          if (sale.mobileNumber.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            _infoRow('Mobile', sale.mobileNumber),
          ],
          const Divider(height: AppSizes.lg),
          _infoRow('Payment Mode', sale.paymentMode.toUpperCase()),
          const SizedBox(height: AppSizes.sm),
          _infoRow(
            'Payment Status',
            sale.dueAmount <= 0 ? 'Paid' : 'Due ₹${sale.dueAmount.toStringAsFixed(2)}',
            valueColor: sale.dueAmount <= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: (isBold ? AppTextStyles.h3 : AppTextStyles.bodyMedium).copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    if (sale.lineItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Text('No items in this invoice.', style: AppTextStyles.bodyMedium),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sale.lineItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = sale.lineItems[index];
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '${item.quantity.toStringAsFixed(1)} ${item.unit} x ${CurrencyFormatter.format(item.rate)}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.total),
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _infoRow('Subtotal', CurrencyFormatter.format(sale.subtotal)),
          const SizedBox(height: AppSizes.sm),
          _infoRow('GST', CurrencyFormatter.format(sale.totalTax)),
          const Divider(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: AppTextStyles.h2),
              Text(
                CurrencyFormatter.format(sale.grandTotal),
                style: AppTextStyles.amount.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            // Edit
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // Print
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPrinting ? null : _handlePrint,
                icon: _isPrinting
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print_rounded),
                label: const Text('Print'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm + 4),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSharing ? null : _handleShare,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.share_rounded),
                label: const Text('Share'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        // Delete Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isDeleting ? null : _handleDelete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                  )
                : const Icon(Icons.delete_outline, color: AppColors.error),
            label: Text(
              _isDeleting ? 'Deleting...' : 'Delete Invoice',
              style: const TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
