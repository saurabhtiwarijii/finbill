/// FinBill — Print Settings Model.
///
/// Stores user preferences for invoice and receipt printing/PDF generation.
/// Stored in Firestore at `businesses/{businessId}/settings/print`.
///
/// File location: lib/models/print_settings_model.dart
library;

class PrintSettingsModel {
  const PrintSettingsModel({
    this.showLogo = true,
    this.showGst = true,
    this.showAddress = true,
    this.invoicePrefix = 'INV-',
    this.footerNote = 'Thank you for your business!',
  });

  final bool showLogo;
  final bool showGst;
  final bool showAddress;
  final String invoicePrefix;
  final String footerNote;

  PrintSettingsModel copyWith({
    bool? showLogo,
    bool? showGst,
    bool? showAddress,
    String? invoicePrefix,
    String? footerNote,
  }) {
    return PrintSettingsModel(
      showLogo: showLogo ?? this.showLogo,
      showGst: showGst ?? this.showGst,
      showAddress: showAddress ?? this.showAddress,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      footerNote: footerNote ?? this.footerNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showLogo': showLogo,
      'showGst': showGst,
      'showAddress': showAddress,
      'invoicePrefix': invoicePrefix,
      'footerNote': footerNote,
    };
  }

  factory PrintSettingsModel.fromMap(Map<String, dynamic> map) {
    return PrintSettingsModel(
      showLogo: map['showLogo'] as bool? ?? true,
      showGst: map['showGst'] as bool? ?? true,
      showAddress: map['showAddress'] as bool? ?? true,
      invoicePrefix: map['invoicePrefix'] as String? ?? 'INV-',
      footerNote: map['footerNote'] as String? ?? 'Thank you for your business!',
    );
  }
}
