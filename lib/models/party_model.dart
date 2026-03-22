/// FinBill — Party data model.
///
/// Represents a customer or supplier with contact info and running balance.
/// Positive balance = party owes you. Negative = you owe party.
///
/// File location: lib/models/party_model.dart
library;

enum PartyType { customer, supplier }

class PartyModel {
  const PartyModel({
    required this.id,
    required this.name,
    this.mobile = '',
    this.type = PartyType.customer,
    this.balance = 0,
  });

  final String id;
  final String name;
  final String mobile;
  final PartyType type;
  final double balance;

  /// True if the party owes you money.
  bool get hasReceivable => balance > 0;

  /// True if you owe the party money.
  bool get hasPayable => balance < 0;

  PartyModel copyWith({
    String? id,
    String? name,
    String? mobile,
    PartyType? type,
    double? balance,
  }) {
    return PartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      type: type ?? this.type,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'type': type.name,
        'balance': balance,
      };

  factory PartyModel.fromMap(Map<String, dynamic> map) {
    return PartyModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      type: (map['type'] as String?) == 'supplier'
          ? PartyType.supplier
          : PartyType.customer,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
