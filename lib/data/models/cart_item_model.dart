class CartItemModel {
  final String itemType; // 'product', 'service', 'package'
  final int itemId;
  final String itemName;
  final double itemPrice;
  final String? imagePath;
  int quantity;
  String notes;
  
  // Untuk package
  double? normalPrice;

  CartItemModel({
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    this.imagePath,
    this.quantity = 1,
    this.notes = '',
    this.normalPrice,
  });

  double get subtotal => itemPrice * quantity;
  
  double? get savings => normalPrice != null ? (normalPrice! - itemPrice) * quantity : null;

  Map<String, dynamic> toMap() {
    return {
      'itemType': itemType,
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'imagePath': imagePath,
      'quantity': quantity,
      'notes': notes,
      'normalPrice': normalPrice,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      itemType: map['itemType'] as String,
      itemId: map['itemId'] as int,
      itemName: map['itemName'] as String,
      itemPrice: (map['itemPrice'] as num).toDouble(),
      imagePath: map['imagePath'] as String?,
      quantity: map['quantity'] as int? ?? 1,
      notes: map['notes'] as String? ?? '',
      normalPrice: map['normalPrice'] != null ? (map['normalPrice'] as num).toDouble() : null,
    );
  }

  CartItemModel copyWith({
    int? quantity,
    String? notes,
  }) {
    return CartItemModel(
      itemType: itemType,
      itemId: itemId,
      itemName: itemName,
      itemPrice: itemPrice,
      imagePath: imagePath,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      normalPrice: normalPrice,
    );
  }
}