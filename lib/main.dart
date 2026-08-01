// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_desk/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== HAPUS DATABASE LAMA ==========
  // await _deleteDatabase();
  
  runApp(const MyApp());
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