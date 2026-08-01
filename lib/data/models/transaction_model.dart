import 'transaction_item_model.dart';

class TransactionModel {
  final int? id;
  final String invoiceNumber;
  final double totalAmount;
  final double discount;
  final double tax;
  final double grandTotal;
  final String paymentMethod;
  final double cashAmount;
  final double changeAmount;
  final String qrisImagePath;
  final String status;
  final String cashierName;
  final String customerName; // ← NEW
  final String notes;
  final String? transactionDate;
  final String? createdAt;

  List<TransactionItemModel>? items;

  TransactionModel({
    this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
    required this.grandTotal,
    required this.paymentMethod,
    this.cashAmount = 0,
    this.changeAmount = 0,
    this.qrisImagePath = '',
    this.status = 'pending',
    this.cashierName = 'Kasir',
    this.customerName = '', // ← NEW
    this.notes = '',
    this.transactionDate,
    this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'grand_total': grandTotal,
      'payment_method': paymentMethod,
      'cash_amount': cashAmount,
      'change_amount': changeAmount,
      'qris_image_path': qrisImagePath,
      'status': status,
      'cashier_name': cashierName,
      'customer_name': customerName, // ← NEW
      'notes': notes,
      'transaction_date': transactionDate,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0,
      grandTotal: (map['grand_total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      cashAmount: (map['cash_amount'] as num?)?.toDouble() ?? 0,
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0,
      qrisImagePath: map['qris_image_path'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      cashierName: map['cashier_name'] as String? ?? 'Kasir',
      customerName: map['customer_name'] as String? ?? '', // ← NEW
      notes: map['notes'] as String? ?? '',
      transactionDate: map['transaction_date'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel.fromMap(json);
}