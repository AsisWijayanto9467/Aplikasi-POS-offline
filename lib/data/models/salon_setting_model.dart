class SalonSettingModel {
  final int? id;
  final String salonName;
  final String address;
  final String phone;
  final String email;
  final String logoPath;
  final String openingTime;
  final String closingTime;
  final double taxPercentage;
  final String currency;
  final String? updatedAt;

  SalonSettingModel({
    this.id,
    this.salonName = 'Salon Cantik',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.logoPath = '',
    this.openingTime = '09:00',
    this.closingTime = '21:00',
    this.taxPercentage = 0,
    this.currency = 'Rp',
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salon_name': salonName,
      'address': address,
      'phone': phone,
      'email': email,
      'logo_path': logoPath,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'tax_percentage': taxPercentage,
      'currency': currency,
      'updated_at': updatedAt,
    };
  }

  factory SalonSettingModel.fromMap(Map<String, dynamic> map) {
    return SalonSettingModel(
      id: map['id'] as int?,
      salonName: map['salon_name'] as String? ?? 'Salon Cantik',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      logoPath: map['logo_path'] as String? ?? '',
      openingTime: map['opening_time'] as String? ?? '09:00',
      closingTime: map['closing_time'] as String? ?? '21:00',
      taxPercentage: (map['tax_percentage'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'Rp',
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory SalonSettingModel.fromJson(Map<String, dynamic> json) => SalonSettingModel.fromMap(json);
}