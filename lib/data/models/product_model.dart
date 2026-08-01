// lib/data/models/product_model.dart
class ProductModel {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final double purchasePrice; // <-- HARGA BELI
  final double sellingPrice;  // <-- HARGA JUAL
  final int stock;
  final int minStock;
  final String imagePath;
  final String barcode;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  // Relasi (opsional, tidak disimpan di database)
  String? categoryName;

  ProductModel({
    this.id,
    required this.categoryId,
    required this.name,
    this.description = '',
    required this.purchasePrice, // <-- WAJIB
    required this.sellingPrice,  // <-- WAJIB
    this.stock = 0,
    this.minStock = 5,
    this.imagePath = '',
    this.barcode = '',
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'purchase_price': purchasePrice, // <-- TAMBAHKAN
      'selling_price': sellingPrice,   // <-- TAMBAHKAN
      'stock': stock,
      'min_stock': minStock,
      'image_path': imagePath,
      'barcode': barcode,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0, // <-- TAMBAHKAN
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,   // <-- TAMBAHKAN
      stock: map['stock'] as int? ?? 0,
      minStock: map['min_stock'] as int? ?? 5,
      imagePath: map['image_path'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel.fromMap(json);

  ProductModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? minStock,
    String? imagePath,
    String? barcode,
    int? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      imagePath: imagePath ?? this.imagePath,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categoryName: categoryName,
    );
  }

  // Getter untuk cek stok rendah
  bool get isLowStock => stock <= minStock;
  
  // Getter untuk keuntungan
  double get profit => sellingPrice - purchasePrice;
  double get profitPercentage => purchasePrice > 0 ? (profit / purchasePrice) * 100 : 0;
}