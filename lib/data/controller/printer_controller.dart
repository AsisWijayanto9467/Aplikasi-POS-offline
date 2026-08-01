// lib/data/controller/printer_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:salon_desk/data/database/database_helper.dart';
import 'package:salon_desk/data/models/printer_setting_model.dart';

class PrinterController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  PrinterSettingModel? _settings;
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isConnected = false;
  String? _error;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  
  PrinterManager _printerManager = PrinterManager();
  StreamSubscription? _scanSubscription;

  PrinterSettingModel? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  String? get error => _error;
  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  // ========== LOAD SETTINGS ==========
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.TABLE_PRINTER_SETTINGS,
        limit: 1,
      );

      if (result.isNotEmpty) {
        _settings = PrinterSettingModel.fromMap(result.first);
        final address = _settings?.bluetoothAddress;
        if (address != null && address.isNotEmpty) {
          _isConnected = true;
          _selectedDevice = BluetoothDevice(
            address: address,
            name: _settings!.printerName,
          );
        }
      } else {
        _settings = PrinterSettingModel();
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
        DatabaseHelper.TABLE_PRINTER_SETTINGS,
        PrinterSettingModel().toMap(),
      );
      await loadSettings();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ========== SAVE SETTINGS ==========
  Future<bool> saveSettings(PrinterSettingModel settings) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final db = await DatabaseHelper.database;
      
      final result = await db.query(
        DatabaseHelper.TABLE_PRINTER_SETTINGS,
        limit: 1,
      );

      int success;
      if (result.isNotEmpty) {
        final data = settings.toMap();
        data.remove('id');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        success = await db.update(
          DatabaseHelper.TABLE_PRINTER_SETTINGS,
          data,
          where: 'id = ?',
          whereArgs: [result.first['id']],
        );
      } else {
        success = await db.insert(
          DatabaseHelper.TABLE_PRINTER_SETTINGS,
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

  // ========== SCAN BLUETOOTH DEVICES ==========
  Future<void> scanDevices() async {
    try {
      _isScanning = true;
      _devices = [];
      _error = null;
      notifyListeners();

      // Check if Bluetooth is enabled
      final isEnabled = await _printerManager.isBluetoothEnabled;
      if (isEnabled != true) {
        _error = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth terlebih dahulu.';
        _isScanning = false;
        notifyListeners();
        return;
      }

      // Start scanning
      _scanSubscription?.cancel();
      _scanSubscription = _printerManager.scanBluetoothDevices().listen(
        (device) {
          if (!_devices.any((d) => d.address == device.address)) {
            _devices.add(device);
            notifyListeners();
          }
        },
        onError: (error) {
          _error = error.toString();
          _isScanning = false;
          notifyListeners();
        },
        onDone: () {
          _isScanning = false;
          notifyListeners();
        },
      );

      // Auto stop after 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        _scanSubscription?.cancel();
        _isScanning = false;
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
      _isScanning = false;
      notifyListeners();
    }
  }

  // ========== CONNECT TO PRINTER ==========
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Connect to printer
      final connected = await _printerManager.connect(device);
      
      if (connected) {
        _selectedDevice = device;
        _isConnected = true;
        
        // Update settings with bluetooth address
        if (_settings != null) {
          final deviceName = device.name ?? '';
          final printerName = deviceName.isNotEmpty ? deviceName : _settings!.printerName;
          final updatedSettings = _settings!.copyWith(
            bluetoothAddress: device.address ?? '',
            isConnected: 1,
            printerName: printerName,
          );
          await saveSettings(updatedSettings);
        }
      }

      _isLoading = false;
      notifyListeners();
      return connected;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  // ========== DISCONNECT PRINTER ==========
  Future<void> disconnectPrinter() async {
    try {
      await _printerManager.disconnect();
      
      if (_settings != null) {
        final updatedSettings = _settings!.copyWith(
          bluetoothAddress: '',
          isConnected: 0,
        );
        await saveSettings(updatedSettings);
      }
      
      _selectedDevice = null;
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== TEST PRINT ==========
  Future<bool> testPrint() async {
    if (!_isConnected) {
      _error = 'Printer tidak terhubung';
      notifyListeners();
      return false;
    }

    try {
      // Create receipt
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      List<int> bytes = [];
      
      // Header
      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        '=' * 32,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Printer: ${_selectedDevice?.name ?? 'Thermal'}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Status: Terhubung',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Waktu: ${DateTime.now().toString()}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        '-' * 32,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Terima kasih',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      // Cut paper
      bytes += generator.cut();
      
      // Send to printer
      await _printerManager.writeBytes(bytes);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ========== PRINT RECEIPT ==========
  Future<bool> printReceipt(Map<String, dynamic> data) async {
    if (!_isConnected) {
      _error = 'Printer tidak terhubung';
      notifyListeners();
      return false;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      List<int> bytes = [];
      
      // Header
      bytes += generator.text(
        data['header'] ?? 'SALON',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        '=' * 32,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Items
      if (data['items'] != null) {
        for (var item in data['items']) {
          bytes += generator.text(
            item['name'] ?? '',
            styles: const PosStyles(align: PosAlign.left),
          );
          bytes += generator.text(
            '${item['qty']} x Rp ${item['price']}',
            styles: const PosStyles(align: PosAlign.left),
          );
          bytes += generator.text(
            'Subtotal: Rp ${item['subtotal']}',
            styles: const PosStyles(align: PosAlign.right),
          );
          bytes += generator.text(
            '-' * 32,
            styles: const PosStyles(align: PosAlign.center),
          );
        }
      }
      
      // Total
      bytes += generator.text(
        'TOTAL: Rp ${data['total'] ?? 0}',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      
      // Footer
      bytes += generator.text(
        '=' * 32,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        data['footer'] ?? 'Terima kasih telah berkunjung',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Cut paper
      bytes += generator.cut();
      
      // Send to printer
      await _printerManager.writeBytes(bytes);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _printerManager.disconnect();
    super.dispose();
  }
}