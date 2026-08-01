// lib/data/models/printer_setting_model.dart
class PrinterSettingModel {
  final int? id;
  final String printerName;
  final String paperSize;
  final int isConnected;
  final String bluetoothAddress;
  final String printHeader;
  final String printFooter;
  final int showLogo;
  final String? updatedAt;

  PrinterSettingModel({
    this.id,
    this.printerName = 'Thermal Printer',
    this.paperSize = '58mm',
    this.isConnected = 0,
    this.bluetoothAddress = '',
    this.printHeader = '',
    this.printFooter = 'Terima kasih telah berkunjung',
    this.showLogo = 1,
    this.updatedAt,
  });

  // ========== COPYWITH METHOD ==========
  PrinterSettingModel copyWith({
    int? id,
    String? printerName,
    String? paperSize,
    int? isConnected,
    String? bluetoothAddress,
    String? printHeader,
    String? printFooter,
    int? showLogo,
    String? updatedAt,
  }) {
    return PrinterSettingModel(
      id: id ?? this.id,
      printerName: printerName ?? this.printerName,
      paperSize: paperSize ?? this.paperSize,
      isConnected: isConnected ?? this.isConnected,
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      printHeader: printHeader ?? this.printHeader,
      printFooter: printFooter ?? this.printFooter,
      showLogo: showLogo ?? this.showLogo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'printer_name': printerName,
      'paper_size': paperSize,
      'is_connected': isConnected,
      'bluetooth_address': bluetoothAddress,
      'print_header': printHeader,
      'print_footer': printFooter,
      'show_logo': showLogo,
      'updated_at': updatedAt,
    };
  }

  factory PrinterSettingModel.fromMap(Map<String, dynamic> map) {
    return PrinterSettingModel(
      id: map['id'] as int?,
      printerName: map['printer_name'] as String? ?? 'Thermal Printer',
      paperSize: map['paper_size'] as String? ?? '58mm',
      isConnected: map['is_connected'] as int? ?? 0,
      bluetoothAddress: map['bluetooth_address'] as String? ?? '',
      printHeader: map['print_header'] as String? ?? '',
      printFooter: map['print_footer'] as String? ?? 'Terima kasih telah berkunjung',
      showLogo: map['show_logo'] as int? ?? 1,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory PrinterSettingModel.fromJson(Map<String, dynamic> json) => PrinterSettingModel.fromMap(json);
}