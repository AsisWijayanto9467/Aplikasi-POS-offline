class PackageDetailModel {
  final int? id;
  final int packageId;
  final String itemType; // 'product' atau 'service'
  final int itemId;
  final int quantity;
  final String? createdAt;

  // Relasi
  String? itemName;
  double? itemPrice;

  PackageDetailModel({
    this.id,
    required this.packageId,
    required this.itemType,
    required this.itemId,
    this.quantity = 1,
    this.createdAt,
    this.itemName,
    this.itemPrice,
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
      itemName: map['item_name'] as String?,
      itemPrice: map['item_price'] != null ? (map['item_price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory PackageDetailModel.fromJson(Map<String, dynamic> json) => PackageDetailModel.fromMap(json);
}