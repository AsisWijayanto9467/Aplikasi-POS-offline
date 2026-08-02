// lib/data/controller/printer_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';
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
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  
  StreamSubscription? _scanSubscription;

  PrinterSettingModel? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  String? get error => _error;
  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _connectedDevice;

  Future<void> init() async {
    await _checkBluetoothPermissions();
    await loadSettings();
  }

  // ========== CHECK PERMISSIONS ==========
  Future<bool> _checkBluetoothPermissions() async {
    try {
      // ✅ Request semua permission
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      
      bool allGranted = true;
      String deniedPermission = '';
      
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
          deniedPermission = permission.toString();
          print('❌ Permission denied: $permission');
        } else {
          print('✅ Permission granted: $permission');
        }
      });
      
      if (!allGranted) {
        _error = 'Izin diperlukan: $deniedPermission. Mohon aktifkan di pengaturan.';
        notifyListeners();
        return false;
      }
      
      return true;
    } catch (e) {
      _error = 'Error permission: $e';
      print('Error checking permissions: $e');
      return false;
    }
  }

  // ========== CHECK GPS/LOCATION ==========
  Future<bool> _checkLocationServices() async {
    try {
      // Cek apakah GPS aktif
      final serviceStatus = await Permission.location.serviceStatus;
      if (!serviceStatus.isEnabled) {
        _error = 'Mohon aktifkan GPS/Lokasi untuk mencari perangkat Bluetooth.';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      return true; // Skip jika error
    }
  }

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
          try {
            final devices = await FlutterBluePlus.connectedDevices;
            for (var device in devices) {
              if (device.remoteId.toString() == address) {
                _connectedDevice = device;
                _selectedDevice = device;
                await _discoverCharacteristics(device);
                break;
              }
            }
          } catch (e) {
            // Device not found
          }
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

  // ========== PRINT RECEIPT ==========
  Future<bool> printReceipt(Map<String, dynamic> data) async {
    if (!_isConnected || _connectedDevice == null) {
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
      final success = await _sendData(bytes);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }


  // ========== DISCOVER CHARACTERISTICS ==========
  Future<void> _discoverCharacteristics(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            return;
          }
          if (characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            return;
          }
        }
      }
      
      _error = 'Tidak ditemukan karakteristik write pada printer';
    } catch (e) {
      _error = 'Gagal discover services: $e';
    }
  }

  // ========== SCAN BLUETOOTH DEVICES ==========
  Future<void> scanDevices() async {
    try {
      _isScanning = true;
      _devices = [];
      _error = null;
      notifyListeners();

      // ✅ CEK IZIN
      final hasPermission = await _checkBluetoothPermissions();
      if (!hasPermission) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      // ✅ CEK GPS/LOCATION
      final hasLocation = await _checkLocationServices();
      if (!hasLocation) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      // ✅ CEK BLUETOOTH
      if (!await FlutterBluePlus.isOn) {
        _error = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth terlebih dahulu.';
        _isScanning = false;
        notifyListeners();
        return;
      }

      // ✅ AMBIL DEVICE YANG SUDAH DIPAIR
      try {
        final bondedDevices = await FlutterBluePlus.bondedDevices;
        print('Bonded devices: ${bondedDevices.length}');
        for (var device in bondedDevices) {
          if (!_devices.any((d) => d.remoteId == device.remoteId)) {
            _devices.add(device);
            print('Bonded: ${device.platformName} - ${device.remoteId}');
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error getting bonded devices: $e');
      }

      // ✅ PERBAIKAN: Tunggu sebentar sebelum scan
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ STOP SCAN SEBELUMNYA
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        // Ignore
      }

      // ✅ START SCAN
      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 20),
        );
      } catch (e) {
        print('Error starting scan: $e');
        _error = 'Gagal memulai scan Bluetooth: $e';
        _isScanning = false;
        notifyListeners();
        return;
      }

      // ✅ LISTEN SCAN RESULTS
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          if (!_devices.any((d) => d.remoteId == device.remoteId)) {
            _devices.add(device);
            print('Device ditemukan: ${device.platformName} - ${device.remoteId}');
            notifyListeners();
          }
        }
      });

      // ✅ AUTO STOP
      Future.delayed(const Duration(seconds: 20), () async {
        try {
          await FlutterBluePlus.stopScan();
        } catch (e) {
          // Ignore
        }
        _scanSubscription?.cancel();
        _isScanning = false;
        print('Scan selesai, ditemukan ${_devices.length} device');
        notifyListeners();
      });

    } catch (e) {
      print('Error scan: $e');
      _error = 'Error scanning: $e';
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

      final hasPermission = await _checkBluetoothPermissions();
      if (!hasPermission) {
        _isLoading = false;
        return false;
      }

      await device.connect(timeout: const Duration(seconds: 10));

      if (device.isConnected) {
        _selectedDevice = device;
        _connectedDevice = device;
        _isConnected = true;
        
        await _discoverCharacteristics(device);
        
        if (_settings != null) {
          final deviceAddress = device.remoteId.toString();
          final deviceName = device.platformName.isNotEmpty 
              ? device.platformName 
              : _settings!.printerName;
          
          final updatedSettings = _settings!.copyWith(
            bluetoothAddress: deviceAddress,
            isConnected: 1,
            printerName: deviceName,
          );
          await saveSettings(updatedSettings);
        }
      }

      _isLoading = false;
      notifyListeners();
      return _isConnected;

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
      if (_connectedDevice != null && _connectedDevice!.isConnected) {
        await _connectedDevice!.disconnect();
      }
      
      if (_settings != null) {
        final updatedSettings = _settings!.copyWith(
          bluetoothAddress: '',
          isConnected: 0,
        );
        await saveSettings(updatedSettings);
      }
      
      _selectedDevice = null;
      _connectedDevice = null;
      _writeCharacteristic = null;
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== SEND DATA TO PRINTER ==========
  Future<bool> _sendData(List<int> data) async {
    if (_writeCharacteristic == null) {
      _error = 'Karakteristik write tidak tersedia';
      return false;
    }

    try {
      const int chunkSize = 20;
      for (int i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final chunk = data.sublist(i, end);
        await _writeCharacteristic!.write(chunk);
      }
      return true;
    } catch (e) {
      _error = 'Gagal mengirim data: $e';
      return false;
    }
  }

  // ========== TEST PRINT ==========
  Future<bool> testPrint() async {
    if (!_isConnected || _connectedDevice == null) {
      _error = 'Printer tidak terhubung';
      notifyListeners();
      return false;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      List<int> bytes = [];
      
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
        'Printer: ${_connectedDevice?.platformName ?? 'Thermal'}',
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
      
      bytes += generator.cut();
      
      final success = await _sendData(bytes);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  

  @override
  void dispose() {
    _scanSubscription?.cancel();
    if (_connectedDevice != null && _connectedDevice!.isConnected) {
      _connectedDevice!.disconnect();
    }
    super.dispose();
  }
}