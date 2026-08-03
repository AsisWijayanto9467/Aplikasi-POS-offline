// lib/data/models/qris_model.dart
class QrisModel {
  final int? id;
  final String merchantName;
  final String merchantId;
  final String qrisImagePath;
  final String qrisDescription;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  QrisModel({
    this.id,
    this.merchantName = 'Salon Cantik',
    this.merchantId = '',
    this.qrisImagePath = '',
    this.qrisDescription = 'Pembayaran QRIS',
    this.isActive = 1,
    this.createdAt,
    this.updatedAt,
  });

  // ========== BOOLEAN GETTERS ==========
  bool get hasQRISImage => qrisImagePath.isNotEmpty;
  bool get isComplete => merchantName.isNotEmpty && hasQRISImage;

  // ========== TO MAP ==========
  Map<String, dynamic> toMap() {
    // ✅ Gunakan variabel lokal untuk menghindari null-safety issue
    final currentId = id;
    final currentCreatedAt = createdAt;
    
    final map = <String, dynamic>{
      'merchant_name': merchantName,
      'merchant_id': merchantId,
      'qris_image_path': qrisImagePath,
      'qris_description': qrisDescription,
      'is_active': isActive,
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
    
    // ✅ Hanya tambahkan jika tidak null
    if (currentId != null) {
      map['id'] = currentId;
    }
    if (currentCreatedAt != null) {
      map['created_at'] = currentCreatedAt;
    }
    
    return map;
  }

  // ========== FROM MAP ==========
  factory QrisModel.fromMap(Map<String, dynamic> map) {
    return QrisModel(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String? ?? 'Salon Cantik',
      merchantId: map['merchant_id'] as String? ?? '',
      qrisImagePath: map['qris_image_path'] as String? ?? '',
      qrisDescription: map['qris_description'] as String? ?? 'Pembayaran QRIS',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  // ========== TO JSON ==========
  Map<String, dynamic> toJson() => toMap();
  
  // ========== FROM JSON ==========
  factory QrisModel.fromJson(Map<String, dynamic> json) => QrisModel.fromMap(json);

  // ========== COPY WITH ==========
  QrisModel copyWith({
    int? id,
    String? merchantName,
    String? merchantId,
    String? qrisImagePath,
    String? qrisDescription,
    int? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return QrisModel(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      merchantId: merchantId ?? this.merchantId,
      qrisImagePath: qrisImagePath ?? this.qrisImagePath,
      qrisDescription: qrisDescription ?? this.qrisDescription,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========== DEFAULT ==========
  factory QrisModel.defaultQRIS() {
    return QrisModel(
      merchantName: 'Salon Cantik',
      merchantId: '',
      qrisImagePath: '',
      qrisDescription: 'Pembayaran QRIS',
      isActive: 1,
    );
  }

  @override
  String toString() {
    return 'QrisModel(id: $id, merchantName: $merchantName, merchantId: $merchantId, hasImage: $hasQRISImage, isComplete: $isComplete)';
  }
}