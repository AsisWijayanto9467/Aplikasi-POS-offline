// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_desk/presentation/screens/main_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== HAPUS DATABASE LAMA ==========
  // await _deleteDatabase();
  
  // ✅ Panggil fungsi request permissions
  await _requestPermissions();

  runApp(const MyApp());
}

// ✅ TAMBAHKAN FUNGSI INI
Future<void> _requestPermissions() async {
  try {
    // Request semua permission yang diperlukan
    final permissions = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage,
    ].request();
    
    // Cek status permission
    bool allGranted = true;
    permissions.forEach((permission, status) {
      if (!status.isGranted && !status.isPermanentlyDenied) {
        allGranted = false;
        print('Permission ${permission.toString()} status: $status');
      }
    });
    
    if (!allGranted) {
      print('⚠️ Beberapa permission belum diberikan');
    } else {
      print('✅ Semua permission diberikan');
    }
  } catch (e) {
    print('Error requesting permissions: $e');
  }
}

Future<void> _deleteDatabase() async {
  try {
    String path = await getDatabasesPath();
    String dbPath = '$path/salon_pos.db';
    await deleteDatabase(dbPath);
    print('✅ Database deleted successfully');
  } catch (e) {
    print('Error deleting database: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon Desk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}