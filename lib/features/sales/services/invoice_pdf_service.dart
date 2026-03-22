/// FinBill — Invoice PDF Service.
///
/// Uses the `pdf` and `printing` packages to generate and print invoices.
///
/// File location: lib/features/sales/services/invoice_pdf_service.dart
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/business_model.dart';
import '../../../models/print_settings_model.dart';
import '../../../models/sale_model.dart';
import '../../../services/firebase_service.dart';

class InvoicePdfService {
  /// Entry point to generate and launch the print preview dialog for a sale.
  static Future<void> printInvoice(SaleModel sale) async {
    try {
      final firebase = FirebaseService.instance;
      
      // Fetch dynamic configuration
      final business = await firebase.getBusinessProfile();
      final settings = await firebase.getPrintSettings();

      final pdfBytes = await generateInvoicePdf(
        sale,
        business ?? BusinessModel(id: firebase.businessId, name: 'My Business'),
        settings ?? const PrintSettingsModel(),
      );

      await Printing.layoutPdf(
        name: '${sale.invoiceNumber}.pdf',
        onLayout: (PdfPageFormat format) => pdfBytes,
      );
    } catch (e) {
      debugPrint('InvoicePdfService.printInvoice error: $e');
    }
  }

  /// Builds the actual PDF document bytes.
  static Future<Uint8List> generateInvoicePdf(
    SaleModel sale,
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
                // Business Info
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        business.name.isEmpty ? 'INVOICE' : business.name.toUpperCase(),
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
                // Logo
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

            // ── INVOICE INFO & BILL TO ───────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 4),
                    pw.Text(sale.partyName.isNotEmpty ? sale.partyName : 'Cash Sale',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    if (sale.mobileNumber.isNotEmpty)
                      pw.Text('Phone: ${sale.mobileNumber}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    pw.SizedBox(height: 4),
                    pw.Text('${settings.invoicePrefix}${sale.invoiceNumber}', style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 2),
                    pw.Text('Date: ${DateFormat('dd MMM yyyy').format(sale.date)}', style: const pw.TextStyle(fontSize: 12)),
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
                for (final item in sale.lineItems)
                  [
                    item.itemName,
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit}',
                    currencyFormat.format(item.rate),
                    currencyFormat.format(sale.hasGst ? item.total : item.subtotal),
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
                          pw.Text(currencyFormat.format(sale.subtotal), style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      if (sale.hasGst) ...[
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Tax Amount', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(currencyFormat.format(sale.totalTax), style: const pw.TextStyle(fontSize: 10)),
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
                          pw.Text(currencyFormat.format(sale.grandTotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
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
