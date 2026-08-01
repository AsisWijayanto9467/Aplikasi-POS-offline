// lib/data/controller/salon_setting_controller.dart
import 'package:flutter/material.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/salon_setting_model.dart';

class SalonSettingController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  SalonSettingModel? _settings;
  bool _isLoading = false;
  String? _error;

  SalonSettingModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== LOAD SETTINGS ==========
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_SALON_SETTINGS,
        limit: 1,
      );

      if (result.isNotEmpty) {
        _settings = SalonSettingModel.fromMap(result.first);
      } else {
        // Create default settings if none exist
        _settings = SalonSettingModel(); // ← Hapus const
        await _insertDefaultSettings();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _insertDefaultSettings() async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert(
        DatabaseHelper.TABLE_SALON_SETTINGS,
        SalonSettingModel().toMap(), // ← Hapus const
      );
      await loadSettings();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ========== SAVE SETTINGS ==========
  Future<bool> saveSettings(SalonSettingModel settings) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;
      
      // Check if settings exist
      final result = await db.query(
        DatabaseHelper.TABLE_SALON_SETTINGS,
        limit: 1,
      );

      int success;
      if (result.isNotEmpty) {
        // Update existing
        final data = settings.toMap();
        data.remove('id');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        success = await db.update(
          DatabaseHelper.TABLE_SALON_SETTINGS,
          data,
          where: 'id = ?',
          whereArgs: [result.first['id']],
        );
      } else {
        // Insert new
        success = await db.insert(
          DatabaseHelper.TABLE_SALON_SETTINGS,
          settings.toMap(),
        );
      }

      if (success > 0) {
        _settings = settings;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}