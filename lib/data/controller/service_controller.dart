// lib/data/controllers/service_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:salon_desk/data/models/service_model.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class ServiceController extends ChangeNotifier {
  // ========== STATE ==========
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  
  // Image state
  String? _selectedImagePath;
  File? _selectedImageFile;

  // ========== GETTERS ==========
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get categories => _categories;
  String? get selectedImagePath => _selectedImagePath;
  File? get selectedImageFile => _selectedImageFile;

  // ========== INIT ==========
  Future<void> init() async {
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
      final imageDir = Directory('${directory.path}/service_images');
      
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

  // ========== LOAD SERVICES ==========
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final result = await db.rawQuery('''
        SELECT 
          s.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_SERVICES} s
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON s.category_id = c.id
        WHERE s.is_active = 1
        ORDER BY s.name ASC
      ''');

      _services = result.map((map) => ServiceModel.fromMap(map)).toList();
      await _loadCategories();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading services: $e');
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
        where: "type = 'service'",
        orderBy: 'name ASC',
      );
      _categories = result;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // ========== CREATE SERVICE ==========
  Future<bool> createService(ServiceModel service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_SERVICES,
        where: 'name = ?',
        whereArgs: [service.name],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama jasa sudah ada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save image jika ada
      String? savedImagePath;
      if (_selectedImageFile != null) {
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final serviceWithImage = service.copyWith(
        imagePath: savedImagePath ?? service.imagePath,
      );

      final id = await db.insert(
        DatabaseHelper.TABLE_SERVICES,
        serviceWithImage.toMap(),
      );
      
      if (id > 0) {
        clearSelectedImage();
        await loadServices();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating service: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== UPDATE SERVICE ==========
  Future<bool> updateService(ServiceModel service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final existing = await db.query(
        DatabaseHelper.TABLE_SERVICES,
        where: 'name = ? AND id != ?',
        whereArgs: [service.name, service.id],
      );
      
      if (existing.isNotEmpty) {
        _error = 'Nama jasa sudah digunakan oleh jasa lain';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Handle image update
      String? savedImagePath = service.imagePath;
      
      if (_selectedImageFile != null) {
        if (service.imagePath.isNotEmpty) {
          await deleteImage(service.imagePath);
        }
        savedImagePath = await saveImage(_selectedImageFile!);
      }

      final serviceWithImage = service.copyWith(
        imagePath: savedImagePath ?? service.imagePath,
      );

      final data = serviceWithImage.toMap();
      data.remove('id');
      data.remove('created_at');
      
      final count = await db.update(
        DatabaseHelper.TABLE_SERVICES,
        data,
        where: 'id = ?',
        whereArgs: [service.id],
      );
      
      if (count > 0) {
        clearSelectedImage();
        await loadServices();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating service: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== DELETE SERVICE (Soft Delete) ==========
  Future<bool> deleteService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // Get service to delete image
      final service = await getService(id);
      if (service != null && service.imagePath.isNotEmpty) {
        await deleteImage(service.imagePath);
      }
      
      final count = await db.update(
        DatabaseHelper.TABLE_SERVICES,
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadServices();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting service: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET SINGLE SERVICE ==========
  Future<ServiceModel?> getService(int id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          s.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_SERVICES} s
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON s.category_id = c.id
        WHERE s.id = ?
      ''', [id]);
      
      if (result.isNotEmpty) {
        return ServiceModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting service: $e');
      return null;
    }
  }

  // ========== SEARCH SERVICES ==========
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          s.*,
          c.name as category_name
        FROM ${DatabaseHelper.TABLE_SERVICES} s
        LEFT JOIN ${DatabaseHelper.TABLE_CATEGORIES} c 
          ON s.category_id = c.id
        WHERE s.is_active = 1
          AND (s.name LIKE ? OR s.description LIKE ?)
        ORDER BY s.name ASC
      ''', ['%$query%', '%$query%']);
      
      return result.map((map) => ServiceModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching services: $e');
      return [];
    }
  }

  // ========== SET SEARCH RESULTS ==========
  void setSearchResults(List<ServiceModel> results) {
    _services = results;
    notifyListeners();
  }

  // ========== RESET ==========
  void reset() {
    _services = [];
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