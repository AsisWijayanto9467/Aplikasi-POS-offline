// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_desk/presentation/screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // await _deleteDatabase();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  try {
    final permissions = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage,
    ].request();
    
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
      home: const SplashScreen(),
    );
  }
}