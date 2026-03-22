/// FinBill — Sale / Invoice data model.
///
/// Represents a complete sale invoice with party info, line items,
/// tax, and total calculations. [SaleLineItem] holds individual
/// product lines within the invoice.
///
/// File location: lib/models/sale_model.dart
library;

class SaleLineItem {
  const SaleLineItem({
    this.itemId = '',
    required this.itemName,
    this.unit = 'pcs',
    this.quantity = 1,
    this.rate = 0,
    this.taxRate = 0,
    this.isFromInventory = false,
  });

  final String itemId;
  final String itemName;
  final String unit;
  final double quantity;
  final double rate;
  final double taxRate;
  final bool isFromInventory;

  /// Line total before tax.
  double get subtotal => quantity * rate;

  /// Tax amount for this line.
  double get taxAmount => subtotal * taxRate / 100;

  /// Line total including tax.
  double get total => subtotal + taxAmount;

  SaleLineItem copyWith({
    String? itemId,
    String? itemName,
    String? unit,
    double? quantity,
    double? rate,
    double? taxRate,
    bool? isFromInventory,
  }) {
    return SaleLineItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      taxRate: taxRate ?? this.taxRate,
      isFromInventory: isFromInventory ?? this.isFromInventory,
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemName': itemName,
        'unit': unit,
        'quantity': quantity,
        'rate': rate,
        'taxRate': taxRate,
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'total': total,
        'isFromInventory': isFromInventory,
      };

  factory SaleLineItem.fromMap(Map<String, dynamic> map) {
    return SaleLineItem(
      itemId: map['item_id'] as String? ?? map['itemId'] as String? ?? '',
      itemName: map['name'] as String? ?? map['itemName'] as String? ?? '',
      unit: map['unit'] as String? ?? 'pcs',
      quantity: (map['quantity'] ?? 0).toDouble(),
      rate: (map['rate'] ?? 0).toDouble(),
      taxRate: (map['taxRate'] ?? 0).toDouble(),
      isFromInventory: map['isFromInventory'] as bool? ?? false,
    );
  }
}

class SaleModel {
  const SaleModel({
    required this.id,
    required this.invoiceNumber,
    this.partyId = '',
    this.partyName = '',
    this.mobileNumber = '',
    required this.date,
    this.hasGst = false,
    this.lineItems = const [],
    this.paymentMode = 'cash',
    this.paidAmount = 0,
    this.dueAmount = 0,
  });

  final String id;
  final String invoiceNumber;
  final String partyId;
  final String partyName;
  final String mobileNumber;
  final DateTime date;
  final bool hasGst;
  final List<SaleLineItem> lineItems;
  final String paymentMode;
  final double paidAmount;
  final double dueAmount;

  /// Sum of all line subtotals (before tax).
  double get subtotal =>
      lineItems.fold(0, (sum, item) => sum + item.total);

  /// Sum of all line tax amounts.
  double get totalTax =>
      lineItems.fold(0, (sum, item) => sum + item.taxAmount);

  /// Grand total (subtotal + tax).
  double get grandTotal => subtotal + totalTax;

  /// Number of line items.
  int get itemCount => lineItems.length;

  SaleModel copyWith({
    String? id,
    String? invoiceNumber,
    String? partyId,
    String? partyName,
    String? mobileNumber,
    DateTime? date,
    bool? hasGst,
    List<SaleLineItem>? lineItems,
    String? paymentMode,
    double? paidAmount,
    double? dueAmount,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      date: date ?? this.date,
      hasGst: hasGst ?? this.hasGst,
      lineItems: lineItems ?? this.lineItems,
      paymentMode: paymentMode ?? this.paymentMode,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'partyId': partyId,
        'partyName': partyName,
        'mobileNumber': mobileNumber,
        'date': date.toIso8601String(),
        'hasGst': hasGst,
        'subtotal': subtotal,
        'totalTax': totalTax,
        'grandTotal': grandTotal,
        'itemCount': itemCount,
        'items': lineItems.map((e) => e.toMap()).toList(),
        'paymentMode': paymentMode,
        'paidAmount': paidAmount,
        'dueAmount': dueAmount,
      };

  /// Deserialise from a Firestore document.
  /// Note: lineItems are fetched separately from subcollection when needed.
  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] as String? ?? '',
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      partyId: map['partyId'] as String? ?? '',
      partyName: map['partyName'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      hasGst: map['hasGst'] as bool? ?? false,
      lineItems: (map['items'] as List<dynamic>?)
              ?.map((e) => SaleLineItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      paymentMode: map['paymentMode'] as String? ?? 'cash',
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? (map['grandTotal'] as num?)?.toDouble() ?? 0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
