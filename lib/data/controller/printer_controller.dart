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

  // Konstanta untuk lebar kertas
  static const int paperWidth = 32; // 32 karakter untuk kertas 58mm

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
      final serviceStatus = await Permission.location.serviceStatus;
      if (!serviceStatus.isEnabled) {
        _error = 'Mohon aktifkan GPS/Lokasi untuk mencari perangkat Bluetooth.';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      return true;
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

  // ====================================================================
  // ✅ PRINT RECEIPT - VERSI FINAL (DIPERBAIKI)
  // ====================================================================
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
      
      // ========== HEADER ==========
      bytes += generator.text(
        data['header']?.toString() ?? 'SALON CANTIK',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text(
        'Jl. Contoh No. 123',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Telp: 0812-3456-7890',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.hr();
      
      // ========== INVOICE INFO ==========
      if (data['invoice'] != null) {
        bytes += generator.text(
          'No. ${data['invoice']}',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        );
      }
      
      if (data['date'] != null) {
        final dateStr = data['date'].toString();
        try {
          final date = DateTime.parse(dateStr);
          bytes += generator.text(
            '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            styles: const PosStyles(align: PosAlign.center),
          );
        } catch (e) {
          bytes += generator.text(
            dateStr,
            styles: const PosStyles(align: PosAlign.center),
          );
        }
      }
      
      if (data['cashier'] != null) {
        bytes += generator.text(
          'Kasir: ${data['cashier']}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.hr();
      
      // ========== ITEMS ==========
      final items = data['items'];
      if (items != null && items is List && items.isNotEmpty) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is Map<String, dynamic>) {
            final name = (item['name'] ?? '').toString();
            final qty = item['qty'] ?? 1;
            final price = item['price'] ?? 0;
            final subtotal = item['subtotal'] ?? 0;
            
            // ✅ Baris 1: NAMA (kiri) | QTY (kanan) - BOLD
            String qtyStr = 'x$qty';
            String line1 = _padTwoColumns(name, qtyStr, paperWidth);
            bytes += generator.text(
              line1,
              styles: const PosStyles(
                align: PosAlign.left,
                bold: true,
              ),
            );
            
            // ✅ Baris 2: HARGA (kiri) | SUBTOTAL (kanan) - NORMAL
            String priceStr = _formatCurrency(price);
            String subtotalStr = _formatCurrency(subtotal);
            String line2 = _padTwoColumns('  @$priceStr', subtotalStr, paperWidth);
            bytes += generator.text(
              line2,
              styles: const PosStyles(
                align: PosAlign.left,
              ),
            );
            
            // Garis pemisah antar item
            if (i < items.length - 1) {
              bytes += generator.text(
                '- ' * 16,
                styles: const PosStyles(align: PosAlign.center),
              );
            }
          }
        }
      } else {
        bytes += generator.text(
          'Tidak ada item',
          styles: const PosStyles(align: PosAlign.center),
        );
        bytes += generator.feed(1);
      }
      
      bytes += generator.hr();
      
      // ========== TOTAL ==========
      final total = data['total'];
      if (total != null) {
        String totalStr = _formatCurrency(total);
        String lineTotal = _padTwoColumns('TOTAL', totalStr, paperWidth);
        bytes += generator.text(
          lineTotal,
          styles: const PosStyles(
            align: PosAlign.left,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );
      }
      
      bytes += generator.text(
        '- ' * 16,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // ========== PAYMENT DETAILS ==========
      if (data['payment_method'] != null) {
        String methodLine = _padTwoColumns(
          'Metode Bayar',
          data['payment_method'].toString().toUpperCase(),
          paperWidth,
        );
        bytes += generator.text(
          methodLine,
          styles: const PosStyles(align: PosAlign.left),
        );
      }
      
      if (data['cash_amount'] != null && data['cash_amount'] > 0) {
        String cashLine = _padTwoColumns(
          'Tunai',
          _formatCurrency(data['cash_amount']),
          paperWidth,
        );
        bytes += generator.text(
          cashLine,
          styles: const PosStyles(align: PosAlign.left),
        );
      }
      
      if (data['change_amount'] != null && data['change_amount'] > 0) {
        String changeLine = _padTwoColumns(
          'Kembalian',
          _formatCurrency(data['change_amount']),
          paperWidth,
        );
        bytes += generator.text(
          changeLine,
          styles: const PosStyles(
            align: PosAlign.left,
            bold: true,
          ),
        );
      }
      
      bytes += generator.hr();
      
      // ========== FOOTER ==========
      bytes += generator.feed(1);
      
      if (data['footer'] != null) {
        bytes += generator.text(
          data['footer'].toString(),
          styles: const PosStyles(
            align: PosAlign.center,
            bold: false,
          ),
        );
      }
      
      bytes += generator.feed(2);
      
      // Cut paper
      bytes += generator.cut();
      
      // Send to printer
      final success = await _sendData(bytes);
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ====================================================================
  // ✅ HELPER METHODS
  // ====================================================================

  /// Format dua kolom dengan spasi di tengah
  /// Contoh: "Nama Barang          x1"
  String _padTwoColumns(String left, String right, int width) {
    // Hitung panjang teks kiri dan kanan
    int leftLen = left.length;
    int rightLen = right.length;
    
    // Jika total melebihi lebar, potong teks kiri
    if (leftLen + rightLen > width) {
      int maxLeft = width - rightLen - 1;
      if (maxLeft > 3) {
        left = '${left.substring(0, maxLeft - 2)}..';
        leftLen = left.length;
      }
    }
    
    // Hitung jumlah spasi
    int spaces = width - leftLen - rightLen;
    if (spaces < 1) spaces = 1;
    
    // Return dengan spasi di tengah
    return '$left${' ' * spaces}$right';
  }

  /// Format currency dengan pemisah ribuan
  String _formatCurrency(dynamic value) {
    double amount = 0;
    if (value is double) {
      amount = value;
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is String) {
      amount = double.tryParse(value) ?? 0;
    }
    
    // Format angka dengan titik pemisah ribuan
    String formatted = amount.toStringAsFixed(0);
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(regExp, (Match m) => '${m[1]}.');
    
    return 'Rp$formatted';
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

  Future<void> scanDevices() async {
    try {
      _isScanning = true;
      _devices = [];
      _error = null;
      notifyListeners();

      final hasPermission = await _checkBluetoothPermissions();
      if (!hasPermission) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      final hasLocation = await _checkLocationServices();
      if (!hasLocation) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        _error = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth terlebih dahulu.';
        _isScanning = false;
        notifyListeners();
        return;
      }

      try {
        final bondedDevices = await FlutterBluePlus.bondedDevices;
        print('📱 Bonded devices found: ${bondedDevices.length}');
        for (var device in bondedDevices) {
          if (!_devices.any((d) => d.remoteId == device.remoteId)) {
            _devices.add(device);
            print('  📎 Bonded: ${device.platformName} - ${device.remoteId}');
          }
        }
        notifyListeners();
      } catch (e) {
        print('Error getting bonded devices: $e');
      }

      try {
        final connectedDevices = await FlutterBluePlus.connectedDevices;
        print('🔗 Connected devices: ${connectedDevices.length}');
        for (var device in connectedDevices) {
          if (!_devices.any((d) => d.remoteId == device.remoteId)) {
            _devices.add(device);
            print('  🔌 Connected: ${device.platformName} - ${device.remoteId}');
          }
        }
        notifyListeners();
      } catch (e) {
        print('Error getting connected devices: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        // Ignore
      }

      print('🔍 Starting Bluetooth scan...');
      
      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 30),
        );
        print('✅ Scan started successfully');
      } catch (e) {
        print('❌ Error starting scan: $e');
        _error = 'Gagal memulai scan Bluetooth. Coba restart Bluetooth HP Anda.';
        _isScanning = false;
        notifyListeners();
        return;
      }

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          print('📡 Scan results received: ${results.length} devices');
          
          for (ScanResult result in results) {
            final device = result.device;
            final rssi = result.rssi;
            final serviceUuids = result.advertisementData.serviceUuids;
            
            print('  📻 Found: ${device.platformName}');
            print('     Address: ${device.remoteId}');
            print('     RSSI: $rssi dBm');
            print('     Service UUIDs: $serviceUuids');
            
            if (!_devices.any((d) => d.remoteId == device.remoteId)) {
              _devices.add(device);
              notifyListeners();
              print('     ✅ Added to list');
            }
          }
        },
        onError: (error) {
          print('❌ Scan error: $error');
        },
      );

      Future.delayed(const Duration(seconds: 30), () async {
        await stopScan();
      });

    } catch (e) {
      print('❌ Error scan: $e');
      _error = 'Error scanning: $e';
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      print('🛑 Scan stopped');
    } catch (e) {
      print('Error stopping scan: $e');
    }
    _scanSubscription?.cancel();
    _isScanning = false;
    print('📊 Total devices found: ${_devices.length}');
    notifyListeners();
  }
  
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
      
      bytes += generator.hr();
      
      bytes += generator.text(
        'Printer: ${_connectedDevice?.platformName ?? 'Thermal'}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Status: Terhubung',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Waktu: ${DateTime.now().toString().substring(0, 19)}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.hr();
      
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