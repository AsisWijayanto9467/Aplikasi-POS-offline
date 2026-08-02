// lib/data/models/package_detail_model.dart
class PackageDetailModel {
  final int? id;
  final int packageId;
  final String itemType;
  final int itemId;
  final int quantity;
  final String? createdAt;

  PackageDetailModel({
    this.id,
    required this.packageId,
    required this.itemType,
    required this.itemId,
    this.quantity = 1,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package_id': packageId,
      'item_type': itemType,
      'item_id': itemId,
      'quantity': quantity,
      'created_at': createdAt,
    };
  }

  factory PackageDetailModel.fromMap(Map<String, dynamic> map) {
    return PackageDetailModel(
      id: map['id'] as int?,
      packageId: map['package_id'] as int,
      itemType: map['item_type'] as String,
      itemId: map['item_id'] as int,
      quantity: map['quantity'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
    );
  }
}