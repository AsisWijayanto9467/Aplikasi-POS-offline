// lib/data/models/category_model.dart
class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'product' atau 'service'
  final String icon;
  final String color;
  final String? createdAt;
  final String? updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.icon = 'category',
    this.color = '#F68B1F',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String? ?? 'category',
      color: map['color'] as String? ?? '#F68B1F',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    String? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}