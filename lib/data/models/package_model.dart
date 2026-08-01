import 'package_detail_model.dart';

class PackageModel {
  final int? id;
  final String name;
  final String description;
  final double normalPrice;
  final double packagePrice;
  final String imagePath;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  // Relasi
  List<PackageDetailModel>? details;

  PackageModel({
    this.id,
    required this.name,
    this.description = '',
    required this.normalPrice,
    required this.packagePrice,
    this.imagePath = '',
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'normal_price': normalPrice,
      'package_price': packagePrice,
      'image_path': imagePath,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      normalPrice: (map['normal_price'] as num).toDouble(),
      packagePrice: (map['package_price'] as num).toDouble(),
      imagePath: map['image_path'] as String? ?? '',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel.fromMap(json);

  PackageModel copyWith({
    int? id,
    String? name,
    String? description,
    double? normalPrice,
    double? packagePrice,
    String? imagePath,
    int? isActive,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      normalPrice: normalPrice ?? this.normalPrice,
      packagePrice: packagePrice ?? this.packagePrice,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      details: details,
    );
  }

  double get savings => normalPrice - packagePrice;
  double get savingsPercentage => (savings / normalPrice) * 100;
}