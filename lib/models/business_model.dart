/// FinBill — Business Profile Model.
///
/// Represents the business details stored at `businesses/{businessId}`.
///
/// File location: lib/models/business_model.dart
library;

class BusinessModel {
  const BusinessModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.gstNumber = '',
    this.address = '',
    this.description = '',
    this.logoBase64,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String gstNumber;
  final String address;
  final String description;
  final String? logoBase64;

  BusinessModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gstNumber,
    String? address,
    String? description,
    String? logoBase64,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      logoBase64: logoBase64 ?? this.logoBase64,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gstNumber': gstNumber,
      'address': address,
      'description': description,
      'logoBase64': logoBase64,
    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> map, String docId) {
    return BusinessModel(
      id: docId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      gstNumber: map['gstNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      description: map['description'] as String? ?? '',
      logoBase64: map['logoBase64'] as String?,
    );
  }
}
