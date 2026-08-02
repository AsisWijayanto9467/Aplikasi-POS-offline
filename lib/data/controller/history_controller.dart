// lib/data/controller/history_controller.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/transaction_model.dart';
import 'package:salon_desk/data/models/transaction_item_model.dart';

class HistoryController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get filteredTransactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== LOAD TRANSACTIONS ==========
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;
      
      // Get transactions
      final result = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTIONS}
        ORDER BY transaction_date DESC
      ''');

      _transactions = result.map((map) => TransactionModel.fromMap(map)).toList();
      
      // Get items for each transaction
      for (var transaction in _transactions) {
        final items = await db.rawQuery('''
          SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS}
          WHERE transaction_id = ?
        ''', [transaction.id]);
        
        transaction.items = items.map((map) => TransactionItemModel.fromMap(map)).toList();
      }
      
      _filteredTransactions = List.from(_transactions);
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== FILTER TRANSACTIONS ==========
  void filterTransactions(String filter) {
    final now = DateTime.now();
    
    _filteredTransactions = _transactions.where((transaction) {
      if (filter == 'All Time') return true;
      
      if (filter == 'Today') {
        final date = DateTime.parse(transaction.transactionDate!);
        return date.day == now.day && date.month == now.month && date.year == now.year;
      }
      
      if (filter == 'This Week') {
        final date = DateTime.parse(transaction.transactionDate!);
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(startOfWeek) && date.isBefore(now.add(const Duration(days: 1)));
      }
      
      if (filter == 'Completed') {
        return transaction.status == 'completed';
      }
      
      if (filter == 'Refunded') {
        return transaction.status == 'refunded';
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  // ========== SEARCH TRANSACTIONS ==========
  void searchTransactions(String query) {
    if (query.isEmpty) {
      _filteredTransactions = List.from(_transactions);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredTransactions = _transactions.where((transaction) {
        return transaction.invoiceNumber.toLowerCase().contains(lowerQuery) ||
               (transaction.customerName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  // ========== GET TRANSACTION DETAIL ==========
  Future<TransactionModel?> getTransactionDetail(int id) async {
    try {
      final db = await DatabaseHelper.database;
      
      final result = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTIONS}
        WHERE id = ?
      ''', [id]);
      
      if (result.isEmpty) return null;
      
      final transaction = TransactionModel.fromMap(result.first);
      
      final items = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS}
        WHERE transaction_id = ?
      ''', [id]);
      
      transaction.items = items.map((map) => TransactionItemModel.fromMap(map)).toList();
      
      return transaction;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}