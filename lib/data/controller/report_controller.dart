// lib/data/controller/report_controller.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/transaction_model.dart';
import 'package:salon_desk/data/models/transaction_item_model.dart';

class ReportController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Report data
  double _totalSales = 0;
  int _totalOrders = 0;
  double _averageBasket = 0;
  double _salesChange = 0;
  double _ordersChange = 0;
  double _basketChange = 0;
  List<double> _chartData = [];
  List<Map<String, dynamic>> _topProducts = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'Week';

  // Getters
  double get totalSales => _totalSales;
  int get totalOrders => _totalOrders;
  double get averageBasket => _averageBasket;
  double get salesChange => _salesChange;
  double get ordersChange => _ordersChange;
  double get basketChange => _basketChange;
  List<double> get chartData => _chartData;
  List<Map<String, dynamic>> get topProducts => _topProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
  }

  // ========== LOAD REPORT DATA ==========
  Future<void> loadReportData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;

      // ✅ PERBAIKI data lama yang transaction_date / created_at NULL
      await db.execute('''
        UPDATE ${DatabaseHelper.TABLE_TRANSACTIONS}
        SET transaction_date = COALESCE(created_at, CURRENT_TIMESTAMP)
        WHERE transaction_date IS NULL
      ''');

      // ✅ AMBIL SEMUA DATA TRANSAKSI (sama seperti history)
      final result = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTIONS}
        WHERE status = 'completed'
        ORDER BY transaction_date DESC
      ''');

      final transactions = result.map((map) => TransactionModel.fromMap(map)).toList();
      
      // ✅ Ambil items untuk setiap transaksi
      for (var transaction in transactions) {
        final items = await db.rawQuery('''
          SELECT * FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS}
          WHERE transaction_id = ?
        ''', [transaction.id]);
        
        transaction.items = items.map((map) => TransactionItemModel.fromMap(map)).toList();
      }

      print('Total transactions: ${transactions.length}');

      // ========== HITUNG STATISTIK ==========
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

      // Filter transaksi bulan ini
      final thisMonthTransactions = transactions.where((t) {
        if (t.transactionDate == null) return false;
        final date = DateTime.parse(t.transactionDate!);
        return date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth);
      }).toList();

      // Filter transaksi bulan lalu
      final lastMonthTransactions = transactions.where((t) {
        if (t.transactionDate == null) return false;
        final date = DateTime.parse(t.transactionDate!);
        return date.isAfter(startOfLastMonth) && date.isBefore(startOfMonth);
      }).toList();

      // ✅ Hitung total penjualan bulan ini - gunakan 0.0
      _totalSales = thisMonthTransactions.fold(0.0, (sum, t) => sum + t.grandTotal);
      _totalOrders = thisMonthTransactions.length;
      _averageBasket = _totalOrders > 0 ? _totalSales / _totalOrders : 0;

      // ✅ Hitung total penjualan bulan lalu - gunakan 0.0
      final lastTotalSales = lastMonthTransactions.fold(0.0, (sum, t) => sum + t.grandTotal);
      final lastTotalOrders = lastMonthTransactions.length;
      
      // Hitung perubahan
      _salesChange = lastTotalSales > 0 
          ? ((_totalSales - lastTotalSales) / lastTotalSales) * 100 
          : 0;
      _ordersChange = lastTotalOrders > 0 
          ? ((_totalOrders - lastTotalOrders) / lastTotalOrders) * 100 
          : 0;
      
      final lastAverageBasket = lastTotalOrders > 0 ? lastTotalSales / lastTotalOrders : 0;
      _basketChange = lastAverageBasket > 0 
          ? ((_averageBasket - lastAverageBasket) / lastAverageBasket) * 100 
          : 0;

      print('This month - Sales: $_totalSales, Orders: $_totalOrders');
      print('Last month - Sales: $lastTotalSales, Orders: $lastTotalOrders');

      // ========== BUAT CHART DATA ==========
      await _buildChartData(transactions, now);

      // ========== LOAD TOP PRODUCTS ==========
      await _loadTopProducts(db);

      notifyListeners();

    } catch (e) {
      _error = e.toString();
      print('Error loading report data: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== BUILD CHART DATA ==========
  Future<void> _buildChartData(List<TransactionModel> transactions, DateTime now) async {
    try {
      if (_selectedPeriod == 'Week') {
        // 7 hari terakhir
        final List<double> dailySales = List.filled(7, 0.0);
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        
        for (var t in transactions) {
          if (t.transactionDate == null) continue;
          final date = DateTime.parse(t.transactionDate!);
          final difference = date.difference(startOfWeek).inDays;
          if (difference >= 0 && difference < 7) {
            dailySales[difference] += t.grandTotal;
          }
        }
        _chartData = dailySales;
        
      } else if (_selectedPeriod == 'Month') {
        // 30 hari dalam bulan ini
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final List<double> dailySales = List.filled(daysInMonth, 0.0);
        
        for (var t in transactions) {
          if (t.transactionDate == null) continue;
          final date = DateTime.parse(t.transactionDate!);
          if (date.month == now.month && date.year == now.year) {
            final day = date.day - 1;
            if (day >= 0 && day < daysInMonth) {
              dailySales[day] += t.grandTotal;
            }
          }
        }
        _chartData = dailySales;
        
      } else {
        // 12 bulan dalam setahun
        final List<double> monthlySales = List.filled(12, 0.0);
        
        for (var t in transactions) {
          if (t.transactionDate == null) continue;
          final date = DateTime.parse(t.transactionDate!);
          if (date.year == now.year) {
            final month = date.month - 1;
            if (month >= 0 && month < 12) {
              monthlySales[month] += t.grandTotal;
            }
          }
        }
        _chartData = monthlySales;
      }
      
      print('Chart data: $_chartData');
      notifyListeners();
    } catch (e) {
      print('Error building chart data: $e');
      _chartData = [];
      notifyListeners();
    }
  }

  // ========== LOAD TOP PRODUCTS ==========
  Future<void> _loadTopProducts(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          ti.item_name as name,
          ti.item_type as type,
          SUM(ti.quantity) as total_units,
          COALESCE(SUM(ti.subtotal), 0) as total_revenue
        FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS} ti
        JOIN ${DatabaseHelper.TABLE_TRANSACTIONS} t 
          ON ti.transaction_id = t.id
        WHERE t.status = 'completed'
        GROUP BY ti.item_name, ti.item_type
        ORDER BY total_revenue DESC
        LIMIT 10
      ''');

      print('Top products result: $result');
      
      if (result.isNotEmpty && result.first['name'] != null) {
        _topProducts = result.map((row) {
          final type = row['type'] as String? ?? 'product';
          return {
            'name': row['name'] as String? ?? 'Produk',
            'type': type,
            'units': row['total_units'] as int? ?? 0,
            'revenue': (row['total_revenue'] as num?)?.toDouble() ?? 0,
            'category': _getCategoryLabel(type),
          };
        }).toList();
      } else {
        _topProducts = [];
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading top products: $e');
      _topProducts = [];
      notifyListeners();
    }
  }

  String _getCategoryLabel(String type) {
    switch (type) {
      case 'product':
        return 'Produk';
      case 'service':
        return 'Jasa';
      case 'package':
        return 'Paket';
      default:
        return 'Lainnya';
    }
  }

  // ========== LOAD CHART DATA (untuk period toggle) ==========
  Future<void> loadChartData(String period) async {
    _selectedPeriod = period;
    await loadReportData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}