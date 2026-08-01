// lib/data/controllers/package_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:salon_desk/data/models/package_detail_model.dart';
import 'package:salon_desk/data/models/package_model.dart';
import 'package:salon_desk/data/models/product_model.dart';
import 'package:salon_desk/data/models/service_model.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class PackageController extends ChangeNotifier {
  // ========== STATE ==========
  List<PackageModel> _packages = [];
  List<ProductModel> _products = []; // <-- Tipe eksplisit
  List<ServiceModel> _services = []; // <-- Tipe eksplisit
  bool _isLoading = false;
  String? _error;
  
  // Image state
  String? _selectedImagePath;
  File? _selectedImageFile;

  // ========== GETTERS ==========
  List<PackageModel> get packages => _packages;
  List<ProductModel> get products => _products; // <-- Tipe eksplisit
  List<ServiceModel> get services => _services; // <-- Tipe eksplisit
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedImagePath => _selectedImagePath;
  File? get selectedImageFile => _selectedImageFile;

  // ========== INIT ==========
  Future<void> init() async {
    await loadPackages();
    await loadProducts();
    await loadServices();
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
      final imageDir = Directory('${directory.path}/package_images');
      
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

  // ========== LOAD PRODUCTS & SERVICES ==========
  Future<void> loadProducts() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PRODUCTS,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );
      _products = result.map((map) => ProductModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> loadServices() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_SERVICES,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );
      _services = result.map((map) => ServiceModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading services: $e');
    }
  }

  // ========== LOAD PACKAGES ==========
  Future<void> loadPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final result = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'is_active = 1',
        orderBy: 'name ASC',
      );

      _packages = result.map((map) => PackageModel.fromMap(map)).toList();
      
      // Load package details untuk setiap package
      for (var i = 0; i < _packages.length; i++) {
        final details = await db.query(
          DatabaseHelper.TABLE_PACKAGE_DETAILS,
          where: 'package_id = ?',
          whereArgs: [_packages[i].id],
        );
        
        _packages[i].details = details.map((map) => PackageDetailModel.fromMap(map)).toList();
      }
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading packages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== CREATE PACKAGE ==========
  Future<bool> createPackage(PackageModel package, List<PackageDetailModel> details) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'name = ?',
        whereArgs: [package.name],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama paket sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save image jika ada
      String? savedImagePath;
      if (_selectedImageFile != null) {
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final packageWithImage = package.copyWith(
        imagePath: savedImagePath ?? package.imagePath,
      );

      final id = await db.insert(
        DatabaseHelper.TABLE_PACKAGES,
        packageWithImage.toMap(),
      );
      
      if (id > 0) {
        // Insert package details
        for (var detail in details) {
          await db.insert(
            DatabaseHelper.TABLE_PACKAGE_DETAILS,
            PackageDetailModel(
              packageId: id,
              itemType: detail.itemType,
              itemId: detail.itemId,
              quantity: detail.quantity,
            ).toMap(),
          );
        }
        
        clearSelectedImage();
        await loadPackages();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== UPDATE PACKAGE ==========
  Future<bool> updatePackage(PackageModel package, List<PackageDetailModel> details) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'name = ? AND id != ?',
        whereArgs: [package.name, package.id],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama paket sudah digunakan oleh paket lain';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Handle image update
      String? savedImagePath = package.imagePath;
      
      if (_selectedImageFile != null) {
        if (package.imagePath.isNotEmpty) {
          await deleteImage(package.imagePath);
        }
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final packageWithImage = package.copyWith(
        imagePath: savedImagePath ?? package.imagePath,
      );

      final data = packageWithImage.toMap();
      data.remove('id');
      data.remove('created_at');
      
      final count = await db.update(
        DatabaseHelper.TABLE_PACKAGES,
        data,
        where: 'id = ?',
        whereArgs: [package.id],
      );
      
      if (count > 0) {
        // Delete old details
        await db.delete(
          DatabaseHelper.TABLE_PACKAGE_DETAILS,
          where: 'package_id = ?',
          whereArgs: [package.id],
        );
        
        // Insert new details
        for (var detail in details) {
          await db.insert(
            DatabaseHelper.TABLE_PACKAGE_DETAILS,
            PackageDetailModel(
              packageId: package.id!,
              itemType: detail.itemType,
              itemId: detail.itemId,
              quantity: detail.quantity,
            ).toMap(),
          );
        }
        
        clearSelectedImage();
        await loadPackages();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== DELETE PACKAGE ==========
  Future<bool> deletePackage(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // Get package to delete image
      final package = await getPackage(id);
      if (package != null && package.imagePath.isNotEmpty) {
        await deleteImage(package.imagePath);
      }
      
      // Delete details first (cascade will handle in DB)
      await db.delete(
        DatabaseHelper.TABLE_PACKAGE_DETAILS,
        where: 'package_id = ?',
        whereArgs: [id],
      );
      
      final count = await db.update(
        DatabaseHelper.TABLE_PACKAGES,
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadPackages();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> getItemById(String type, int id) {
    if (type == 'product') {
      try {
        final product = _products.firstWhere((p) => p.id == id);
        return {
          'name': product.name,
          'price': product.sellingPrice,
        };
      } catch (e) {
        return {
          'name': 'Produk tidak ditemukan',
          'price': 0,
        };
      }
    } else {
      try {
        final service = _services.firstWhere((s) => s.id == id);
        return {
          'name': service.name,
          'price': service.price,
        };
      } catch (e) {
        return {
          'name': 'Jasa tidak ditemukan',
          'price': 0,
        };
      }
    }
  }

  // ========== GET SINGLE PACKAGE ==========
  Future<PackageModel?> getPackage(int id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (result.isNotEmpty) {
        final package = PackageModel.fromMap(result.first);
        
        // Load details
        final details = await db.query(
          DatabaseHelper.TABLE_PACKAGE_DETAILS,
          where: 'package_id = ?',
          whereArgs: [id],
        );
        
        package.details = details.map((map) => PackageDetailModel.fromMap(map)).toList();
        return package;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting package: $e');
      return null;
    }
  }

  // ========== SEARCH PACKAGES ==========
  Future<List<PackageModel>> searchPackages(String query) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PACKAGES,
        where: 'is_active = 1 AND (name LIKE ? OR description LIKE ?)',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      
      return result.map((map) => PackageModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching packages: $e');
      return [];
    }
  }

  // ========== SET SEARCH RESULTS ==========
  void setSearchResults(List<PackageModel> results) {
    _packages = results;
    notifyListeners();
  }

  // ========== RESET ==========
  void reset() {
    _packages = [];
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