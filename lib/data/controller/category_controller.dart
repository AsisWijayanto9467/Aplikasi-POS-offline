// lib/data/controllers/category_controller.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryController extends ChangeNotifier {
  // ========== STATE ==========
  List<CategoryModel> _categories = [];
  List<CategoryModel> _productCategories = [];
  List<CategoryModel> _serviceCategories = [];
  bool _isLoading = false;
  String? _error;
  String _currentType = 'product'; // 'product' atau 'service'

  // ========== GETTERS ==========
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get productCategories => _productCategories;
  List<CategoryModel> get serviceCategories => _serviceCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentType => _currentType;

  void setType(String type) {
    _currentType = type;
    notifyListeners();
  }

  // ========== INIT ==========
  Future<void> init() async {
    await loadAllCategories();
  }

  // ========== LOAD ALL CATEGORIES ==========
  Future<void> loadAllCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        orderBy: 'name ASC',
      );

      _categories = result.map((map) => CategoryModel.fromMap(map)).toList();
      
      _productCategories = _categories.where((c) => c.type == 'product').toList();
      _serviceCategories = _categories.where((c) => c.type == 'service').toList();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== LOAD CATEGORIES BY TYPE ==========
  Future<void> loadCategoriesByType(String type) async {
    _isLoading = true;
    _error = null;
    _currentType = type;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );

      _categories = result.map((map) => CategoryModel.fromMap(map)).toList();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== CREATE CATEGORY ==========
  Future<bool> createCategory(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        where: 'name = ? AND type = ?',
        whereArgs: [category.name, category.type],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Kategori dengan nama ini sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final id = await db.insert(
        DatabaseHelper.TABLE_CATEGORIES,
        category.toMap(),
      );
      
      if (id > 0) {
        await loadCategoriesByType(category.type);
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== UPDATE CATEGORY ==========
  Future<bool> updateCategory(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        where: 'name = ? AND type = ? AND id != ?',
        whereArgs: [category.name, category.type, category.id],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Kategori dengan nama ini sudah digunakan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = category.toMap();
      data.remove('id');
      data.remove('created_at');
      
      final count = await db.update(
        DatabaseHelper.TABLE_CATEGORIES,
        data,
        where: 'id = ?',
        whereArgs: [category.id],
      );
      
      if (count > 0) {
        await loadCategoriesByType(category.type);
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== DELETE CATEGORY ==========
  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final category = _categories.firstWhere((c) => c.id == id);
      
      // Cek apakah kategori sedang digunakan
      if (category.type == 'product') {
        final products = await db.query(
          DatabaseHelper.TABLE_PRODUCTS,
          where: 'category_id = ? AND is_active = 1',
          whereArgs: [id],
        );
        if (products.isNotEmpty) {
          _error = 'Kategori ini sedang digunakan oleh produk';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (category.type == 'service') {
        final services = await db.query(
          DatabaseHelper.TABLE_SERVICES,
          where: 'category_id = ? AND is_active = 1',
          whereArgs: [id],
        );
        if (services.isNotEmpty) {
          _error = 'Kategori ini sedang digunakan oleh jasa';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      final count = await db.delete(
        DatabaseHelper.TABLE_CATEGORIES,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadCategoriesByType(category.type);
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET CATEGORY BY ID ==========
  Future<CategoryModel?> getCategory(int id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (result.isNotEmpty) {
        return CategoryModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting category: $e');
      return null;
    }
  }

  // ========== RESET ==========
  void reset() {
    _categories = [];
    _productCategories = [];
    _serviceCategories = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}