import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class SeedData {
  static Future<void> seedAll(Database db) async {
    await _seedCategories(db);
    await _seedProducts(db);
    await _seedServices(db);
    await _seedPackages(db);
    await _seedSalonSettings(db);
    await _seedPrinterSettings(db);
  }

  // ========== SEED CATEGORIES ==========
  static Future<void> _seedCategories(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_CATEGORIES}'),
    );
    
    if (count == 0) {
      final categories = [
        {
          'name': 'Shampoo & Perawatan',
          'type': 'product',
          'icon': 'spa',
          'color': '#F68B1F',
        },
        {
          'name': 'Styling',
          'type': 'product',
          'icon': 'content_cut',
          'color': '#E67E22',
        },
        {
          'name': 'Hair Color',
          'type': 'product',
          'icon': 'palette',
          'color': '#D35400',
        },
        {
          'name': 'Aksesoris',
          'type': 'product',
          'icon': 'auto_awesome',
          'color': '#F39C12',
        },
        {
          'name': 'Potong Rambut',
          'type': 'service',
          'icon': 'cut',
          'color': '#F68B1F',
        },
        {
          'name': 'Perawatan Rambut',
          'type': 'service',
          'icon': 'spa',
          'color': '#E67E22',
        },
        {
          'name': 'Pewarnaan',
          'type': 'service',
          'icon': 'palette',
          'color': '#D35400',
        },
        {
          'name': 'Styling & Blow',
          'type': 'service',
          'icon': 'air',
          'color': '#F39C12',
        },
        {
          'name': 'Perawatan Wajah',
          'type': 'service',
          'icon': 'face',
          'color': '#E74C3C',
        },
        {
          'name': 'Nail Art',
          'type': 'service',
          'icon': 'pan_tool',
          'color': '#9B59B6',
        },
      ];

      for (final category in categories) {
        await db.insert(DatabaseHelper.TABLE_CATEGORIES, {
          'name': category['name'],
          'type': category['type'],
          'icon': category['icon'],
          'color': category['color'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ========== SEED PRODUCTS ==========
  static Future<void> _seedProducts(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_PRODUCTS}'),
    );

    if (count == 0) {
      final products = [
        // Shampoo & Perawatan (category_id: 1)
        {'category_id': 1, 'name': 'Shampoo Argan Oil', 'price': 85000, 'stock': 25, 'min_stock': 5},
        {'category_id': 1, 'name': 'Conditioner Silk', 'price': 75000, 'stock': 20, 'min_stock': 5},
        {'category_id': 1, 'name': 'Hair Mask Aloe Vera', 'price': 65000, 'stock': 18, 'min_stock': 5},
        {'category_id': 1, 'name': 'Serum Vitamin E', 'price': 120000, 'stock': 12, 'min_stock': 3},
        {'category_id': 1, 'name': 'Tonic Rambut Ginseng', 'price': 55000, 'stock': 30, 'min_stock': 5},
        
        // Styling (category_id: 2)
        {'category_id': 2, 'name': 'Hair Spray Strong Hold', 'price': 45000, 'stock': 15, 'min_stock': 5},
        {'category_id': 2, 'name': 'Pomade Matte Finish', 'price': 55000, 'stock': 10, 'min_stock': 3},
        {'category_id': 2, 'name': 'Wax Styling Clay', 'price': 65000, 'stock': 8, 'min_stock': 3},
        {'category_id': 2, 'name': 'Gel Rambut Natural', 'price': 35000, 'stock': 20, 'min_stock': 5},
        
        // Hair Color (category_id: 3)
        {'category_id': 3, 'name': 'Hair Color Natural Black', 'price': 45000, 'stock': 15, 'min_stock': 5},
        {'category_id': 3, 'name': 'Hair Color Burgundy', 'price': 55000, 'stock': 12, 'min_stock': 3},
        {'category_id': 3, 'name': 'Bleaching Powder 500gr', 'price': 85000, 'stock': 8, 'min_stock': 2},
        {'category_id': 3, 'name': 'Developer 1000ml', 'price': 65000, 'stock': 10, 'min_stock': 3},
        
        // Aksesoris (category_id: 4)
        {'category_id': 4, 'name': 'Sisir Profesional', 'price': 35000, 'stock': 20, 'min_stock': 5},
        {'category_id': 4, 'name': 'Jepit Rambut Set', 'price': 25000, 'stock': 30, 'min_stock': 5},
        {'category_id': 4, 'name': 'Handuk Salon Premium', 'price': 45000, 'stock': 15, 'min_stock': 5},
        {'category_id': 4, 'name': 'Cape Salon', 'price': 15000, 'stock': 50, 'min_stock': 10},
      ];

      for (final product in products) {
        await db.insert(DatabaseHelper.TABLE_PRODUCTS, {
          'category_id': product['category_id'],
          'name': product['name'],
          'description': '${product['name']} berkualitas premium untuk perawatan rambut terbaik.',
          'price': product['price'],
          'stock': product['stock'],
          'min_stock': product['min_stock'],
          'image_path': '',
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ========== SEED SERVICES ==========
  static Future<void> _seedServices(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_SERVICES}'),
    );

    if (count == 0) {
      final services = [
        // Potong Rambut (category_id: 5)
        {'category_id': 5, 'name': 'Potong Pria', 'price': 50000, 'duration': 30},
        {'category_id': 5, 'name': 'Potong Wanita', 'price': 75000, 'duration': 45},
        {'category_id': 5, 'name': 'Potong Anak', 'price': 35000, 'duration': 25},
        {'category_id': 5, 'name': 'Pangkas Ujung', 'price': 45000, 'duration': 20},
        
        // Perawatan Rambut (category_id: 6)
        {'category_id': 6, 'name': 'Creambath', 'price': 85000, 'duration': 60},
        {'category_id': 6, 'name': 'Hair Spa', 'price': 120000, 'duration': 60},
        {'category_id': 6, 'name': 'Hair Mask Premium', 'price': 150000, 'duration': 45},
        {'category_id': 6, 'name': 'Scalp Treatment', 'price': 100000, 'duration': 40},
        
        // Pewarnaan (category_id: 7)
        {'category_id': 7, 'name': 'Coloring Single', 'price': 200000, 'duration': 90},
        {'category_id': 7, 'name': 'Highlight', 'price': 350000, 'duration': 120},
        {'category_id': 7, 'name': 'Balayage', 'price': 500000, 'duration': 150},
        {'category_id': 7, 'name': 'Bleaching Full', 'price': 400000, 'duration': 120},
        
        // Styling & Blow (category_id: 8)
        {'category_id': 8, 'name': 'Blow Dry Biasa', 'price': 50000, 'duration': 30},
        {'category_id': 8, 'name': 'Blow Dry Variasi', 'price': 75000, 'duration': 45},
        {'category_id': 8, 'name': 'Styling Pesta', 'price': 150000, 'duration': 60},
        
        // Perawatan Wajah (category_id: 9)
        {'category_id': 9, 'name': 'Facial Basic', 'price': 85000, 'duration': 45},
        {'category_id': 9, 'name': 'Facial Premium', 'price': 150000, 'duration': 60},
        {'category_id': 9, 'name': 'Totok Wajah', 'price': 75000, 'duration': 30},
        
        // Nail Art (category_id: 10)
        {'category_id': 10, 'name': 'Manicure Basic', 'price': 60000, 'duration': 30},
        {'category_id': 10, 'name': 'Pedicure Basic', 'price': 70000, 'duration': 35},
        {'category_id': 10, 'name': 'Nail Art Simple', 'price': 100000, 'duration': 45},
        {'category_id': 10, 'name': 'Nail Art Premium', 'price': 180000, 'duration': 60},
      ];

      for (final service in services) {
        await db.insert(DatabaseHelper.TABLE_SERVICES, {
          'category_id': service['category_id'],
          'name': service['name'],
          'description': 'Layanan ${service['name']} oleh profesional terbaik.',
          'price': service['price'],
          'duration': service['duration'],
          'image_path': '',
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ========== SEED PACKAGES ==========
  static Future<void> _seedPackages(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_PACKAGES}'),
    );

    if (count == 0) {
      final packages = [
        {
          'name': 'Paket Potong & Creambath',
          'description': 'Potong rambut + Creambath segar',
          'normal_price': 135000,
          'package_price': 110000,
        },
        {
          'name': 'Paket Hair Spa & Blow',
          'description': 'Hair Spa premium + Blow Dry variasi',
          'normal_price': 195000,
          'package_price': 160000,
        },
        {
          'name': 'Paket Coloring Lengkap',
          'description': 'Coloring + Hair Mask + Blow Dry',
          'normal_price': 400000,
          'package_price': 320000,
        },
        {
          'name': 'Paket Facial & Totok Wajah',
          'description': 'Facial Premium + Totok Wajah',
          'normal_price': 225000,
          'package_price': 185000,
        },
        {
          'name': 'Paket Nail Art Combo',
          'description': 'Manicure + Pedicure + Nail Art Simple',
          'normal_price': 230000,
          'package_price': 190000,
        },
        {
          'name': 'Paket Pengantin Basic',
          'description': 'Potong + Creambath + Facial + Blow Pesta',
          'normal_price': 410000,
          'package_price': 350000,
        },
      ];

      for (final package in packages) {
        await db.insert(DatabaseHelper.TABLE_PACKAGES, {
          'name': package['name'],
          'description': package['description'],
          'normal_price': package['normal_price'],
          'package_price': package['package_price'],
          'image_path': '',
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Seed Package Details
      final packageDetails = [
        // Paket 1: Potong & Creambath
        {'package_id': 1, 'item_type': 'service', 'item_id': 1, 'quantity': 1},
        {'package_id': 1, 'item_type': 'service', 'item_id': 9, 'quantity': 1},
        
        // Paket 2: Hair Spa & Blow
        {'package_id': 2, 'item_type': 'service', 'item_id': 10, 'quantity': 1},
        {'package_id': 2, 'item_type': 'service', 'item_id': 14, 'quantity': 1},
        
        // Paket 3: Coloring Lengkap
        {'package_id': 3, 'item_type': 'service', 'item_id': 11, 'quantity': 1},
        {'package_id': 3, 'item_type': 'service', 'item_id': 12, 'quantity': 1},
        {'package_id': 3, 'item_type': 'service', 'item_id': 13, 'quantity': 1},
        
        // Paket 4: Facial & Totok
        {'package_id': 4, 'item_type': 'service', 'item_id': 17, 'quantity': 1},
        {'package_id': 4, 'item_type': 'service', 'item_id': 18, 'quantity': 1},
        
        // Paket 5: Nail Art Combo
        {'package_id': 5, 'item_type': 'service', 'item_id': 19, 'quantity': 1},
        {'package_id': 5, 'item_type': 'service', 'item_id': 20, 'quantity': 1},
        {'package_id': 5, 'item_type': 'service', 'item_id': 21, 'quantity': 1},
        
        // Paket 6: Pengantin Basic
        {'package_id': 6, 'item_type': 'service', 'item_id': 2, 'quantity': 1},
        {'package_id': 6, 'item_type': 'service', 'item_id': 9, 'quantity': 1},
        {'package_id': 6, 'item_type': 'service', 'item_id': 17, 'quantity': 1},
        {'package_id': 6, 'item_type': 'service', 'item_id': 14, 'quantity': 1},
      ];

      for (final detail in packageDetails) {
        await db.insert(DatabaseHelper.TABLE_PACKAGE_DETAILS, {
          'package_id': detail['package_id'],
          'item_type': detail['item_type'],
          'item_id': detail['item_id'],
          'quantity': detail['quantity'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ========== SEED SALON SETTINGS ==========
  static Future<void> _seedSalonSettings(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_SALON_SETTINGS}'),
    );

    if (count == 0) {
      await db.insert(DatabaseHelper.TABLE_SALON_SETTINGS, {
        'salon_name': 'Salon Cantik',
        'address': 'Jl. Melati Indah No. 10, Jakarta',
        'phone': '0812-3456-7890',
        'email': 'info@saloncantik.com',
        'logo_path': '',
        'opening_time': '09:00',
        'closing_time': '21:00',
        'tax_percentage': 0,
        'currency': 'Rp',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ========== SEED PRINTER SETTINGS ==========
  static Future<void> _seedPrinterSettings(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.TABLE_PRINTER_SETTINGS}'),
    );

    if (count == 0) {
      await db.insert(DatabaseHelper.TABLE_PRINTER_SETTINGS, {
        'printer_name': 'Thermal Printer',
        'paper_size': '58mm',
        'is_connected': 0,
        'bluetooth_address': '',
        'print_header': 'Salon Cantik',
        'print_footer': 'Terima kasih telah berkunjung',
        'show_logo': 1,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
}