/// FinBill — Purchase / Bill data model.
///
/// Represents a complete purchase record with supplier info, line items,
/// tax, and total calculations. [PurchaseLineItem] holds individual
/// product lines within the purchase.
///
/// File location: lib/models/purchase_model.dart
library;

class PurchaseLineItem {
  const PurchaseLineItem({
    required this.itemId,
    required this.itemName,
    required this.unit,
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

  PurchaseLineItem copyWith({
    String? itemId,
    String? itemName,
    String? unit,
    double? quantity,
    double? rate,
    double? taxRate,
    bool? isFromInventory,
  }) {
    return PurchaseLineItem(
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

  factory PurchaseLineItem.fromMap(Map<String, dynamic> map) {
    return PurchaseLineItem(
      itemId: map['itemId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      unit: map['unit'] as String? ?? 'pcs',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      rate: (map['rate'] as num?)?.toDouble() ?? 0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0,
      isFromInventory: map['isFromInventory'] as bool? ?? false,
    );
  }
}

class PurchaseModel {
  const PurchaseModel({
    required this.id,
    required this.billNumber,
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
  final String billNumber;
  final String partyId;
  final String partyName;
  final String mobileNumber;
  final DateTime date;
  final bool hasGst;
  final List<PurchaseLineItem> lineItems;
  final String paymentMode;
  final double paidAmount;
  final double dueAmount;

  /// Sum of all line subtotals (before tax).
  double get subtotal =>
      lineItems.fold(0, (sum, item) => sum + item.subtotal);

  /// Sum of all line tax amounts.
  double get totalTax =>
      lineItems.fold(0, (sum, item) => sum + item.taxAmount);

  /// Grand total (subtotal + tax).
  double get grandTotal => subtotal + totalTax;

  /// Number of line items.
  int get itemCount => lineItems.length;

  PurchaseModel copyWith({
    String? id,
    String? billNumber,
    String? partyId,
    String? partyName,
    String? mobileNumber,
    DateTime? date,
    bool? hasGst,
    List<PurchaseLineItem>? lineItems,
    String? paymentMode,
    double? paidAmount,
    double? dueAmount,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
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
        'billNumber': billNumber,
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

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String? ?? '',
      billNumber: map['billNumber'] as String? ?? '',
      partyId: map['partyId'] as String? ?? '',
      partyName: map['partyName'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      hasGst: map['hasGst'] as bool? ?? false,
      lineItems: (map['items'] as List<dynamic>?)
              ?.map((e) => PurchaseLineItem.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      paymentMode: map['paymentMode'] as String? ?? 'cash',
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? (map['grandTotal'] as num?)?.toDouble() ?? 0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
