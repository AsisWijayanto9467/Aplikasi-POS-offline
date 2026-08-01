// File: lib/data/models/printer_history_model.dart

class PrinterHistoryModel {
  final int? id;
  final int transactionId;
  final String? printedAt;
  final int isReprint;

  PrinterHistoryModel({
    this.id,
    required this.transactionId,
    this.printedAt,
    this.isReprint = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'printed_at': printedAt,
      'is_reprint': isReprint,
    };
  }

  factory PrinterHistoryModel.fromMap(Map<String, dynamic> map) {
    return PrinterHistoryModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      printedAt: map['printed_at'] as String?,
      isReprint: map['is_reprint'] as int? ?? 0,
    );
  }
}