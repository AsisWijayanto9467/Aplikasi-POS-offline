// lib/data/controller/qris_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/qris_model.dart';

class QrisController extends ChangeNotifier {
  QrisModel? _qrisData;  // ✅ Gunakan QrisModel
  bool _isLoading = false;
  String? _error;

  // ========== GETTERS ==========
  QrisModel? get qrisData => _qrisData;  // ✅ Return QrisModel?
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  String? get qrisImagePath => _qrisData?.qrisImagePath;
  String get merchantName => _qrisData?.merchantName ?? 'Salon Cantik';
  String get merchantId => _qrisData?.merchantId ?? '';
  bool get hasQRISImage => _qrisData?.hasQRISImage ?? false;
  bool get isQRISComplete => _qrisData?.isComplete ?? false;

  // ========== LOAD QRIS ==========
  Future<void> loadQRIS() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        'qris_settings',
        where: 'is_active = 1',
        limit: 1,
      );

      if (result.isNotEmpty) {
        _qrisData = QrisModel.fromMap(result.first);  // ✅ Konversi ke QrisModel
      } else {
        _qrisData = QrisModel.defaultQRIS();
        await db.insert('qris_settings', _qrisData!.toMap());
      }

      _isLoading = false;
      notifyListeners();
      
      debugPrint('QRIS loaded: $_qrisData');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading QRIS: $e');
    }
  }

  // ========== SAVE QRIS ==========
  Future<bool> saveQRIS({
    required String merchantName,
    required String merchantId,
    required String description,
    String? imagePath,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final existing = await db.query('qris_settings', limit: 1);

      String? savedImagePath = imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        if (existing.isNotEmpty && imagePath != existing.first['qris_image_path']) {
          savedImagePath = await _saveImageToLocal(imagePath);
        }
      }

      final updatedQRIS = QrisModel(
        id: existing.isNotEmpty ? existing.first['id'] as int? : null,
        merchantName: merchantName,
        merchantId: merchantId,
        qrisImagePath: savedImagePath ?? (existing.isNotEmpty ? existing.first['qris_image_path'] as String? ?? '' : ''),
        qrisDescription: description,
        isActive: 1,
        createdAt: existing.isNotEmpty ? existing.first['created_at'] as String? : DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      if (existing.isNotEmpty) {
        await db.update(
          'qris_settings',
          updatedQRIS.toMap(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        await db.insert('qris_settings', updatedQRIS.toMap());
      }

      await loadQRIS();
      
      debugPrint('QRIS saved successfully: $updatedQRIS');
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving QRIS: $e');
      return false;
    }
  }

  // ========== DELETE QRIS IMAGE ==========
  Future<bool> deleteQRISImage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final existing = await db.query('qris_settings', limit: 1);

      if (existing.isNotEmpty) {
        final oldImagePath = existing.first['qris_image_path'] as String?;
        if (oldImagePath != null && oldImagePath.isNotEmpty) {
          final file = File(oldImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        }

        final updatedQRIS = QrisModel.fromMap(existing.first).copyWith(
          qrisImagePath: '',
          updatedAt: DateTime.now().toIso8601String(),
        );

        await db.update(
          'qris_settings',
          updatedQRIS.toMap(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }

      await loadQRIS();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== RESET QRIS ==========
  Future<bool> resetQRIS() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.database;
      await db.delete('qris_settings');
      
      final defaultQRIS = QrisModel.defaultQRIS();
      await db.insert('qris_settings', defaultQRIS.toMap());

      await loadQRIS();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== SAVE IMAGE TO LOCAL ==========
  Future<String> _saveImageToLocal(String sourcePath) async {
    try {
      final appDir = Directory('/data/data/com.example.salon_desk/app_flutter/qris');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      final files = appDir.listSync();
      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }

      final fileName = 'qris_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = '${appDir.path}/$fileName';

      await File(sourcePath).copy(savedPath);
      debugPrint('QRIS image saved to: $savedPath');
      return savedPath;
    } catch (e) {
      debugPrint('Error saving QRIS image: $e');
      return sourcePath;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}