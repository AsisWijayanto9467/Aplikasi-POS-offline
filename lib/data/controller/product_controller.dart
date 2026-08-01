// lib/data/controllers/product_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:salon_desk/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class ProductController extends ChangeNotifier {
  // ========== STATE ==========
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  
  // Image state
  String? _selectedImagePath;
  File? _selectedImageFile;

  // ========== GETTERS ==========
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get categories => _categories;
  String? get selectedImagePath => _selectedImagePath;
  File? get selectedImageFile => _selectedImageFile;

  // ========== INIT ==========
  Future<void> init() async {
    await loadProducts();
  }

  // ========== IMAGE PICKER ==========
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        _selectedImageFile = File(pickedFile.path);
        _selectedImagePath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> saveImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/product_images');
      
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final savedPath = '${imageDir.path}/$fileName';
      
      await imageFile.copy(savedPath);
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      if (imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  void clearSelectedImage() {
    _selectedImageFile = null;
    _selectedImagePath = null;
    notifyListeners();
  }

  // ========== LOAD PRODUCTS ==========
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_PRODUCTS} p
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON p.category_id = c.id
        WHERE p.is_active = 1
        ORDER BY p.name ASC
      ''');

      _products = result.map((map) => ProductModel.fromMap(map)).toList();
      await _loadCategories();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_CATEGORIES,
        where: "type = 'product'",
        orderBy: 'name ASC',
      );
      _categories = result;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_PRODUCTS,
        where: 'name = ?',
        whereArgs: [product.name],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama produk sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save image jika ada
      String? savedImagePath;
      if (_selectedImageFile != null) {
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final productWithImage = product.copyWith(
        imagePath: savedImagePath ?? product.imagePath,
      );

      final id = await db.insert(
        DatabaseHelper.TABLE_PRODUCTS,
        productWithImage.toMap(),
      );
      
      if (id > 0) {
        clearSelectedImage();
        await loadProducts();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== UPDATE PRODUCT ==========
  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_PRODUCTS,
        where: 'name = ? AND id != ?',
        whereArgs: [product.name, product.id],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama produk sudah digunakan oleh produk lain';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Handle image update
      String? savedImagePath = product.imagePath;
      
      if (_selectedImageFile != null) {
        if (product.imagePath.isNotEmpty) {
          await deleteImage(product.imagePath);
        }
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final productWithImage = product.copyWith(
        imagePath: savedImagePath ?? product.imagePath,
      );

      final data = productWithImage.toMap();
      data.remove('id');
      data.remove('created_at');
      
      final count = await db.update(
        DatabaseHelper.TABLE_PRODUCTS,
        data,
        where: 'id = ?',
        whereArgs: [product.id],
      );
      
      if (count > 0) {
        clearSelectedImage();
        await loadProducts();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== DELETE PRODUCT (Soft Delete) ==========
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // Get product to delete image
      final product = await getProduct(id);
      if (product != null && product.imagePath.isNotEmpty) {
        await deleteImage(product.imagePath);
      }
      
      final count = await db.update(
        DatabaseHelper.TABLE_PRODUCTS,
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadProducts();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== HARD DELETE PRODUCT (Permanent) ==========
  Future<bool> hardDeleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // Get product to delete image
      final product = await getProduct(id);
      if (product != null && product.imagePath.isNotEmpty) {
        await deleteImage(product.imagePath);
      }
      
      final count = await db.delete(
        DatabaseHelper.TABLE_PRODUCTS,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadProducts();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error hard deleting product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET SINGLE PRODUCT ==========
  Future<ProductModel?> getProduct(int id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_PRODUCTS} p
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON p.category_id = c.id
        WHERE p.id = ?
      ''', [id]);
      
      if (result.isNotEmpty) {
        return ProductModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  // ========== UPDATE STOCK ==========
  Future<bool> updateStock(int id, int newStock) async {
    try {
      final db = await DatabaseHelper.database;
      
      final count = await db.update(
        DatabaseHelper.TABLE_PRODUCTS,
        {'stock': newStock},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadProducts();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  // ========== SEARCH PRODUCTS ==========
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_PRODUCTS} p
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON p.category_id = c.id
        WHERE p.is_active = 1
          AND (p.name LIKE ? OR p.description LIKE ? OR p.barcode LIKE ?)
        ORDER BY p.name ASC
      ''', ['%$query%', '%$query%', '%$query%']);
      
      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // ========== SET SEARCH RESULTS ==========
  void setSearchResults(List<ProductModel> results) {
    _products = results;
    notifyListeners();
  }

  // ========== GET LOW STOCK PRODUCTS ==========
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_PRODUCTS} p
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON p.category_id = c.id
        WHERE p.is_active = 1
          AND p.stock <= p.min_stock
        ORDER BY p.stock ASC
      ''');
      
      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  // ========== GET PRODUCTS BY CATEGORY ==========
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_PRODUCTS} p
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON p.category_id = c.id
        WHERE p.is_active = 1
          AND p.category_id = ?
        ORDER BY p.name ASC
      ''', [categoryId]);
      
      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // ========== RESET ==========
  void reset() {
    _products = [];
    _isLoading = false;
    _error = null;
    clearSelectedImage();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}