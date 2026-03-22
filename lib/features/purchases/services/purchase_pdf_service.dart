/// FinBill — Purchase PDF Service.
///
/// Generates and prints PDF documents for purchase invoices.
/// Mirrors InvoicePdfService but uses PurchaseModel.
///
/// File location: lib/features/purchases/services/purchase_pdf_service.dart
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/business_model.dart';
import '../../../models/print_settings_model.dart';
import '../../../models/purchase_model.dart';
import '../../../services/firebase_service.dart';

class PurchasePdfService {
  /// Entry point to generate and launch the print preview dialog.
  static Future<void> printPurchase(PurchaseModel purchase) async {
    try {
      final firebase = FirebaseService.instance;
      final business = await firebase.getBusinessProfile();
      final settings = await firebase.getPrintSettings();

      final pdfBytes = await generatePurchasePdf(
        purchase,
        business ?? BusinessModel(id: firebase.businessId, name: 'My Business'),
        settings ?? const PrintSettingsModel(),
      );

      await Printing.layoutPdf(
        name: '${purchase.billNumber}.pdf',
        onLayout: (PdfPageFormat format) => pdfBytes,
      );
    } catch (e) {
      debugPrint('PurchasePdfService.printPurchase error: $e');
    }
  }

  /// Builds the PDF document bytes for a purchase.
  static Future<Uint8List> generatePurchasePdf(
    PurchaseModel purchase,
    BusinessModel business,
    PrintSettingsModel settings,
  ) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    pw.MemoryImage? logoImage;
    if (settings.showLogo && business.logoBase64 != null && business.logoBase64!.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(business.logoBase64!);
        logoImage = pw.MemoryImage(decodedBytes);
      } catch (e) {
        debugPrint('Failed to decode base64 logo: $e');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // ── HEADER ───────────────────────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        business.name.isEmpty ? 'PURCHASE INVOICE' : business.name.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (settings.showAddress && business.address.isNotEmpty)
                        pw.Text(
                          business.address,
                          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                        ),
                      pw.SizedBox(height: 2),
                      if (business.phone.isNotEmpty)
                        pw.Text('Phone: ${business.phone}', style: const pw.TextStyle(fontSize: 10)),
                      if (business.email.isNotEmpty)
                        pw.Text('Email: ${business.email}', style: const pw.TextStyle(fontSize: 10)),
                      if (settings.showGst && business.gstNumber.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text('GSTIN: ${business.gstNumber}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ],
                  ),
                ),
                if (logoImage != null)
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.Image(logoImage),
                  ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 24),

            // ── PURCHASE INFO & SUPPLIER ─────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SUPPLIER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 4),
                    pw.Text(purchase.partyName.isNotEmpty ? purchase.partyName : 'Walk-in',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    if (purchase.mobileNumber.isNotEmpty)
                      pw.Text('Phone: ${purchase.mobileNumber}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('PURCHASE INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    pw.SizedBox(height: 4),
                    pw.Text(purchase.billNumber, style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 2),
                    pw.Text('Date: ${DateFormat('dd MMM yyyy').format(purchase.date)}', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // ── ITEM TABLE ───────────────────────────────────────
            pw.TableHelper.fromTextArray(
              border: null,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: ['Item Description', 'Qty', 'Rate', 'Total'],
              data: [
                for (final item in purchase.lineItems)
                  [
                    item.itemName,
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit}',
                    currencyFormat.format(item.rate),
                    currencyFormat.format(purchase.hasGst ? item.total : item.subtotal),
                  ],
              ],
            ),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // ── TOTALS ───────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(currencyFormat.format(purchase.subtotal), style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      if (purchase.hasGst) ...[
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Tax Amount', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(currencyFormat.format(purchase.totalTax), style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                      pw.SizedBox(height: 8),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.Text(currencyFormat.format(purchase.grandTotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
        footer: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              if (settings.footerNote.isNotEmpty)
                pw.Text(
                  settings.footerNote,
                  style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
