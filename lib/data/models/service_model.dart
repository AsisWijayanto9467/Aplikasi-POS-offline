class ServiceModel {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final int duration; // dalam menit
  final String imagePath;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  // Relasi
  String? categoryName;

  ServiceModel({
    this.id,
    required this.categoryId,
    required this.name,
    this.description = '',
    required this.price,
    this.duration = 30,
    this.imagePath = '',
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
      'price': price,
      'duration': duration,
      'image_path': imagePath,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      duration: map['duration'] as int? ?? 30,
      imagePath: map['image_path'] as String? ?? '',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel.fromMap(json);

  ServiceModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? imagePath,
    int? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categoryName: categoryName,
    );
  }

  String get durationFormatted {
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '$hours jam $minutes mnt' : '$hours jam';
    }
    return '$duration mnt';
  }
}