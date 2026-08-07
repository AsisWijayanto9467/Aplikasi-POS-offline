// lib/data/controller/transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/cart_item_model.dart';
import 'package:salon_desk/data/models/package_detail_model.dart';
import 'package:salon_desk/data/models/product_model.dart';
import 'package:salon_desk/data/models/service_model.dart';
import 'package:salon_desk/data/models/package_model.dart';
import 'package:salon_desk/data/models/transaction_item_model.dart';
import 'package:salon_desk/data/models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Cart items
  List<CartItemModel> _cartItems = [];
  
  // Products, Services, Packages
  List<ProductModel> _products = [];
  List<ServiceModel> _services = [];
  List<PackageModel> _packages = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingServices = false;
  bool _isLoadingPackages = false;
  String? _error;
  
  // Payment
  String _selectedPaymentMethod = 'cash';
  double _cashAmount = 0;
  double _changeAmount = 0;
  
  // Customer
  String _customerName = '';
  String _notes = '';

  // ✅ Tambahkan untuk receipt data
  Map<String, dynamic>? _receiptData;
  String? _lastInvoiceNumber;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  List<ProductModel> get products => _products;
  List<ServiceModel> get services => _services;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingServices => _isLoadingServices;
  bool get isLoadingPackages => _isLoadingPackages;
  String? get error => _error;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  double get cashAmount => _cashAmount;
  double get changeAmount => _changeAmount;
  String get customerName => _customerName;
  String get notes => _notes;
  String? get lastInvoiceNumber => _lastInvoiceNumber;
  
  // ✅ Getter untuk receipt data
  Map<String, dynamic>? get receiptData => _receiptData;

  double get subtotal {
    double total = 0;
    for (var item in _cartItems) {
      total += item.itemPrice * item.quantity;
    }
    return total;
  }

  double get total => subtotal;
  bool get isCartEmpty => _cartItems.isEmpty;
  int get cartItemCount => _cartItems.length;

  // ✅ Method untuk menyimpan receipt data
  void setReceiptData(Map<String, dynamic> data) {
    _receiptData = data;
    notifyListeners();
  }

  // ========== LOAD PRODUCTS ==========
  Future<void> loadProducts() async {
    try {
      _isLoadingProducts = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PRODUCTS,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );

      _products = result.map((map) => ProductModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // ========== LOAD SERVICES ==========
  Future<void> loadServices() async {
    try {
      _isLoadingServices = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_SERVICES,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );

      _services = result.map((map) => ServiceModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  // ========== LOAD PACKAGES ==========
  Future<void> loadPackages() async {
    try {
      _isLoadingPackages = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );

      _packages = result.map((map) => PackageModel.fromMap(map)).toList();
      
      for (var package in _packages) {
        final details = await db.query(
          DatabaseHelper.TABLE_PACKAGE_DETAILS,
          where: 'package_id = ?',
          whereArgs: [package.id],
        );
        package.details = details.map((map) => PackageDetailModel.fromMap(map)).toList();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPackages = false;
      notifyListeners();
    }
  }

  // ========== CART OPERATIONS ==========
  void addToCart(CartItemModel item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.itemType == item.itemType && cartItem.itemId == item.itemId
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _customerName = '';
    _notes = '';
    _cashAmount = 0;
    _changeAmount = 0;
    _receiptData = null; // ✅ Reset receipt data
    notifyListeners();
  }

  // ========== SEARCH ==========
  List<dynamic> searchItems(String query) {
    if (query.isEmpty) {
      final List<dynamic> allItems = [];
      allItems.addAll(_products);
      allItems.addAll(_services);
      allItems.addAll(_packages);
      return allItems;
    }
    
    final results = <dynamic>[];
    final lowerQuery = query.toLowerCase();
    
    for (var product in _products) {
      if (product.name.toLowerCase().contains(lowerQuery)) {
        results.add(product);
      }
    }
    
    for (var service in _services) {
      if (service.name.toLowerCase().contains(lowerQuery)) {
        results.add(service);
      }
    }
    
    for (var package in _packages) {
      if (package.name.toLowerCase().contains(lowerQuery)) {
        results.add(package);
      }
    }
    
    return results;
  }

  // ========== PAYMENT ==========
  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setCashAmount(double amount) {
    _cashAmount = amount;
    _changeAmount = amount - total;
    if (_changeAmount < 0) _changeAmount = 0;
    notifyListeners();
  }

  void clearCashAmount() {
    _cashAmount = 0;
    _changeAmount = 0;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  
Future<bool> saveTransaction() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final invoiceNumber = await _generateUniqueInvoiceNumber(db);
      
      _lastInvoiceNumber = invoiceNumber;

      // ✅ SIMPAN DATA RECEIPT SEBELUM CLEAR CART
      // Pastikan data tersimpan dengan format yang benar
      _receiptData = {
        'header': 'SALON CANTIK',
        'invoice': invoiceNumber,
        'date': DateTime.now().toString(),
        'cashier': 'Kasir',
        'items': _cartItems.map((item) => {
          'name': item.itemName,
          'qty': item.quantity,
          'price': item.itemPrice,
          'subtotal': item.itemPrice * item.quantity,
        }).toList(),
        'total': total,
        'payment_method': _selectedPaymentMethod,
        'cash_amount': _selectedPaymentMethod == 'cash' ? _cashAmount : 0,
        'change_amount': _selectedPaymentMethod == 'cash' ? _changeAmount : 0,
        'footer': 'Terima kasih telah berkunjung\nSimpan struk ini sebagai bukti pembayaran',
      };

      final transaction = TransactionModel(
        invoiceNumber: invoiceNumber,
        totalAmount: subtotal,
        discount: 0,
        tax: 0,
        grandTotal: total,
        paymentMethod: _selectedPaymentMethod,
        cashAmount: _selectedPaymentMethod == 'cash' ? _cashAmount : 0,
        changeAmount: _selectedPaymentMethod == 'cash' ? _changeAmount : 0,
        cashierName: 'Kasir',
        customerName: _customerName,
        notes: _notes,
        status: 'completed',
        transactionDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      final transactionId = await db.insert(
        DatabaseHelper.TABLE_TRANSACTIONS,
        transaction.toMap(),
      );

      for (var cartItem in _cartItems) {
        final item = TransactionItemModel(
          transactionId: transactionId,
          itemType: cartItem.itemType,
          itemId: cartItem.itemId,
          itemName: cartItem.itemName,
          itemPrice: cartItem.itemPrice,
          quantity: cartItem.quantity,
          subtotal: cartItem.subtotal,
        );
        await db.insert(
          DatabaseHelper.TABLE_TRANSACTION_ITEMS,
          item.toMap(),
        );

        if (cartItem.itemType == 'product') {
          await db.rawQuery(
            'UPDATE ${DatabaseHelper.TABLE_PRODUCTS} SET stock = stock - ? WHERE id = ?',
            [cartItem.quantity, cartItem.itemId],
          );
        }
      }

      // ✅ JANGAN clear cart dulu, simpan data receipt
      // clearCart(); // <- HAPUS INI, pindahkan ke method terpisah
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearAfterSuccess() {
    _cartItems.clear();
    _customerName = '';
    _notes = '';
    _cashAmount = 0;
    _changeAmount = 0;
    // JANGAN hapus _receiptData di sini, biarkan sampai selesai print
    notifyListeners();
  }

  void clearReceiptData() {
    _receiptData = null;
    notifyListeners();
  }

  // ✅ Generate invoice number yang unik
  Future<String> _generateUniqueInvoiceNumber(Database db) async {
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timestamp = now.millisecondsSinceEpoch.toString();
    final random = timestamp.substring(timestamp.length - 6);
    
    String invoiceNumber = 'INV-$date-$random';
    
    var existing = await db.query(
      DatabaseHelper.TABLE_TRANSACTIONS,
      where: 'invoice_number = ?',
      whereArgs: [invoiceNumber],
    );
    
    int counter = 0;
    while (existing.isNotEmpty) {
      counter++;
      invoiceNumber = 'INV-$date-$random-$counter';
      existing = await db.query(
        DatabaseHelper.TABLE_TRANSACTIONS,
        where: 'invoice_number = ?',
        whereArgs: [invoiceNumber],
      );
    }
    
    return invoiceNumber;
  }

  @override
  void dispose() {
    super.dispose();
  }
}