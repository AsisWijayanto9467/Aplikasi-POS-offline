// lib/data/controllers/dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class DashboardController extends ChangeNotifier {
  // ========== UI STATE ==========
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;
  
  // ========== DATA ==========
  String _salonName = 'Salon Cantik';
  double _todayRevenue = 0.0;
  int _todayTransactions = 0;
  double _yesterdayRevenue = 0.0;
  List<Map<String, dynamic>> _lowStockProducts = [];
  List<Map<String, dynamic>> _popularServices = [];
  List<Map<String, dynamic>> _dailyRevenue = [];
  List<Map<String, dynamic>> _recentTransactions = []; // NEW
  Map<String, dynamic>? _topService;
  int _lowStockCount = 0;

  // ========== GETTERS ==========
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get salonName => _salonName;
  double get todayRevenue => _todayRevenue;
  int get todayTransactions => _todayTransactions;
  double get yesterdayRevenue => _yesterdayRevenue;
  List<Map<String, dynamic>> get lowStockProducts => _lowStockProducts;
  List<Map<String, dynamic>> get popularServices => _popularServices;
  List<Map<String, dynamic>> get dailyRevenue => _dailyRevenue;
  List<Map<String, dynamic>> get recentTransactions => _recentTransactions; // NEW
  Map<String, dynamic>? get topService => _topService;
  int get lowStockCount => _lowStockCount;
  DateTime? get lastUpdated => _lastUpdated;

  // ========== COMPUTED PROPERTIES ==========
  String get formattedTodayRevenue => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(_todayRevenue);

  String get revenueChangeText {
    if (_yesterdayRevenue == 0 && _todayRevenue == 0) {
      return 'Tidak ada transaksi';
    }
    if (_yesterdayRevenue == 0) {
      return '+100%';
    }
    if (_todayRevenue == 0) {
      return '-100%';
    }
    final change = ((_todayRevenue - _yesterdayRevenue) / _yesterdayRevenue * 100).round();
    final prefix = change >= 0 ? '+' : '';
    return '$prefix$change%';
  }

  Color get revenueChangeColor {
    if (_yesterdayRevenue == 0 && _todayRevenue == 0) return Colors.white70;
    if (_yesterdayRevenue == 0) return Colors.green;
    return _todayRevenue >= _yesterdayRevenue ? Colors.green : Colors.red;
  }

  String get lastUpdatedText {
    if (_lastUpdated == null) return 'Belum diperbarui';
    final now = DateTime.now();
    final diff = now.difference(_lastUpdated!);
    
    if (diff.inSeconds < 60) {
      return 'Baru saja diperbarui';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return DateFormat('HH:mm').format(_lastUpdated!);
    }
  }

  // ========== HELPER CASTING METHODS ==========
  
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ========== DATABASE METHODS ==========
  
  Future<Map<String, dynamic>> _getTodaySummary() async {
    try {
      final db = await DatabaseHelper.database;
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await db.rawQuery('''
        SELECT 
          COALESCE(SUM(grand_total), 0) as total_revenue,
          COUNT(*) as total_transactions
        FROM ${DatabaseHelper.TABLE_TRANSACTIONS}
        WHERE date(transaction_date) = '$todayStr'
          AND status = 'completed'
      ''');

      return {
        'totalRevenue': _toDouble(result.first['total_revenue']),
        'totalTransactions': _toInt(result.first['total_transactions']),
      };
    } catch (e) {
      debugPrint('Error getting today summary: $e');
      return {'totalRevenue': 0.0, 'totalTransactions': 0};
    }
  }

  Future<double> _getYesterdayRevenue() async {
    try {
      final db = await DatabaseHelper.database;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(grand_total), 0) as total_revenue
        FROM ${DatabaseHelper.TABLE_TRANSACTIONS}
        WHERE date(transaction_date) = '$yesterdayStr'
          AND status = 'completed'
      ''');

      return _toDouble(result.first['total_revenue']);
    } catch (e) {
      debugPrint('Error getting yesterday revenue: $e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> _getLowStockProducts() async {
    try {
      final db = await DatabaseHelper.database;
      return await db.rawQuery('''
        SELECT id, name, stock, min_stock
        FROM ${DatabaseHelper.TABLE_PRODUCTS}
        WHERE stock <= min_stock
          AND is_active = 1
        ORDER BY stock ASC
        LIMIT 10
      ''');
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getPopularServices() async {
    try {
      final db = await DatabaseHelper.database;
      return await db.rawQuery('''
        SELECT 
          ti.item_id,
          ti.item_name,
          COUNT(*) as count,
          SUM(ti.subtotal) as total_revenue
        FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS} ti
        INNER JOIN ${DatabaseHelper.TABLE_TRANSACTIONS} t 
          ON ti.transaction_id = t.id
        WHERE ti.item_type = 'service'
          AND t.status = 'completed'
          AND date(t.transaction_date) >= date('now', '-30 days')
        GROUP BY ti.item_id, ti.item_name
        ORDER BY count DESC
        LIMIT 5
      ''');
    } catch (e) {
      debugPrint('Error getting popular services: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getDailyRevenue() async {
    try {
      final db = await DatabaseHelper.database;
      return await db.rawQuery('''
        WITH RECURSIVE dates(date) AS (
          SELECT date('now', '-6 days')
          UNION ALL
          SELECT date(date, '+1 day')
          FROM dates
          WHERE date < date('now')
        )
        SELECT 
          dates.date as day,
          COALESCE(SUM(t.grand_total), 0) as revenue
        FROM dates
        LEFT JOIN ${DatabaseHelper.TABLE_TRANSACTIONS} t 
          ON date(t.transaction_date) = dates.date
          AND t.status = 'completed'
        GROUP BY dates.date
        ORDER BY dates.date
      ''');
    } catch (e) {
      debugPrint('Error getting daily revenue: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentTransactions() async {
    try {
      final db = await DatabaseHelper.database;
      return await db.rawQuery('''
        SELECT 
          t.id,
          t.invoice_number,
          t.grand_total,
          t.payment_method,
          t.status,
          t.transaction_date,
          (SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_TRANSACTION_ITEMS} ti 
           WHERE ti.transaction_id = t.id) as item_count
        FROM ${DatabaseHelper.TABLE_TRANSACTIONS} t
        ORDER BY t.transaction_date DESC, t.id DESC
        LIMIT 5
      ''');
    } catch (e) {
      debugPrint('Error getting recent transactions: $e');
      return [];
    }
  }

  Future<String> _getSalonName() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_SALON_SETTINGS,
        limit: 1,
      );
      if (result.isNotEmpty) {
        return result.first['salon_name'] as String? ?? 'Salon Cantik';
      }
      return 'Salon Cantik';
    } catch (e) {
      debugPrint('Error getting salon name: $e');
      return 'Salon Cantik';
    }
  }

  Future<int> _getLowStockCount() async {
    final products = await _getLowStockProducts();
    return products.length;
  }

  // ========== MAIN LOAD METHOD ==========
  
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // ✅ PERBAIKI DATA LAMA
      await db.execute('''
        UPDATE ${DatabaseHelper.TABLE_TRANSACTIONS}
        SET transaction_date = COALESCE(created_at, CURRENT_TIMESTAMP)
        WHERE transaction_date IS NULL
      ''');

      // Load all data in parallel for better performance
      final results = await Future.wait([
        _getTodaySummary(),
        _getYesterdayRevenue(),
        _getSalonName(),
        _getLowStockProducts(),
        _getPopularServices(),
        _getDailyRevenue(),
        _getRecentTransactions(), // NEW
      ]);

      // Assign with safe casting
      final todaySummary = results[0] as Map<String, dynamic>;
      _todayRevenue = _toDouble(todaySummary['totalRevenue']);
      _todayTransactions = _toInt(todaySummary['totalTransactions']);
      _yesterdayRevenue = _toDouble(results[1]);
      _salonName = results[2] as String;
      _lowStockProducts = results[3] as List<Map<String, dynamic>>;
      _popularServices = results[4] as List<Map<String, dynamic>>;
      _dailyRevenue = results[5] as List<Map<String, dynamic>>;
      _recentTransactions = results[6] as List<Map<String, dynamic>>; // NEW
      _lowStockCount = _lowStockProducts.length;
      _topService = _popularServices.isNotEmpty ? _popularServices.first : null;
      _lastUpdated = DateTime.now();

      debugPrint('Dashboard loaded successfully');
      debugPrint('Today Revenue: $_todayRevenue');
      debugPrint('Today Transactions: $_todayTransactions');
      debugPrint('Low Stock Products: $_lowStockCount');
      debugPrint('Popular Services: ${_popularServices.length}');
      debugPrint('Recent Transactions: ${_recentTransactions.length}');

    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  // ========== HELPER METHODS ==========
  
  String getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return days[date.weekday - 1];
    } catch (e) {
      return dateStr;
    }
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void dispose() {
    super.dispose();
  }
}