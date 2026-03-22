/// FinBill — Item data model.
///
/// Represents a single inventory item with pricing, stock, tax,
/// and alert-level data. Includes [copyWith] for immutable updates
/// and [toMap]/[fromMap] for future Firestore serialisation.
///
/// File location: lib/models/item_model.dart
library;

class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.unit,
    this.stock = 0,
    this.sellPrice = 0,
    this.buyPrice = 0,
    this.taxRate = 0,
    this.alertLevel = 0,
  });

  final String id;
  final String name;
  final String unit;
  final double stock;
  final double sellPrice;
  final double buyPrice;
  final double taxRate;
  final int alertLevel;

  /// Whether stock is at or below the alert threshold.
  bool get isLowStock => alertLevel > 0 && stock <= alertLevel;

  /// Profit margin per unit.
  double get margin => sellPrice - buyPrice;

  /// Creates a copy with optional field overrides.
  ItemModel copyWith({
    String? id,
    String? name,
    String? unit,
    double? stock,
    double? sellPrice,
    double? buyPrice,
    double? taxRate,
    int? alertLevel,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      sellPrice: sellPrice ?? this.sellPrice,
      buyPrice: buyPrice ?? this.buyPrice,
      taxRate: taxRate ?? this.taxRate,
      alertLevel: alertLevel ?? this.alertLevel,
    );
  }

  /// Serialise to a Firestore-ready map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_lowercase': name.toLowerCase().trim(),
      'unit': unit,
      'stock': stock,
      'sellPrice': sellPrice,
      'buyPrice': buyPrice,
      'taxRate': taxRate,
      'alertLevel': alertLevel,
    };
  }

  /// Deserialise from a Firestore document.
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String? ?? 'pcs',
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      sellPrice: (map['sellPrice'] as num?)?.toDouble() ?? 0,
      buyPrice: (map['buyPrice'] as num?)?.toDouble() ?? 0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0,
      alertLevel: (map['alertLevel'] as num?)?.toInt() ?? 0,
    );
  }
}
