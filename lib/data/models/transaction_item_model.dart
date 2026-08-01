class TransactionItemModel {
  final int? id;
  final int transactionId;
  final String itemType; // 'product', 'service', 'package'
  final int itemId;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final double subtotal;
  final String notes;
  final String? createdAt;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.subtotal,
    this.notes = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_type': itemType,
      'item_id': itemId,
      'item_name': itemName,
      'item_price': itemPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      itemType: map['item_type'] as String,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      itemPrice: (map['item_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory TransactionItemModel.fromJson(Map<String, dynamic> json) => TransactionItemModel.fromMap(json);
}