// lib/data/database/database_migration.dart
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DatabaseMigration {
  static Future<void> migrateToV2(Database db) async {
    try {
      // Cek apakah kolom sudah ada
      final columns = await db.rawQuery('PRAGMA table_info(${DatabaseHelper.TABLE_PRODUCTS})');
      final columnNames = columns.map((col) => col['name'] as String).toList();
      
      // Tambahkan purchase_price jika belum ada
      if (!columnNames.contains('purchase_price')) {
        await db.execute(
          'ALTER TABLE ${DatabaseHelper.TABLE_PRODUCTS} ADD COLUMN purchase_price REAL DEFAULT 0'
        );
        print('Added purchase_price column');
      }
      
      // Tambahkan selling_price jika belum ada
      if (!columnNames.contains('selling_price')) {
        await db.execute(
          'ALTER TABLE ${DatabaseHelper.TABLE_PRODUCTS} ADD COLUMN selling_price REAL DEFAULT 0'
        );
        print('Added selling_price column');
      }
      
      // Update data existing - set selling_price = price jika ada kolom price lama
      // Cek apakah kolom price masih ada
      if (columnNames.contains('price') && columnNames.contains('selling_price')) {
        await db.execute(
          'UPDATE ${DatabaseHelper.TABLE_PRODUCTS} SET selling_price = price WHERE selling_price = 0 AND price > 0'
        );
        print('Updated existing products with selling_price from price column');
      }
      
    } catch (e) {
      print('Migration error: $e');
      rethrow;
    }
  }
}