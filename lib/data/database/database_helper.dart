import 'package:salon_desk/data/database/database_migration.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String DB_NAME = 'salon_pos.db';
  static const int DB_VERSION = 2;

  // Table Names
  static const String TABLE_CATEGORIES = 'categories';
  static const String TABLE_PRODUCTS = 'products';
  static const String TABLE_SERVICES = 'services';
  static const String TABLE_PACKAGES = 'packages';
  static const String TABLE_PACKAGE_DETAILS = 'package_details';
  static const String TABLE_TRANSACTIONS = 'transactions';
  static const String TABLE_TRANSACTION_ITEMS = 'transaction_items';
  static const String TABLE_SALON_SETTINGS = 'salon_settings';
  static const String TABLE_PRINTER_SETTINGS = 'printer_settings';
  static const String TABLE_PRINTER_HISTORY = 'printer_history'; // ← NEW

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);

    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await DatabaseMigration.migrateToV2(db);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ========== TABLE CATEGORIES ==========
    await db.execute('''
      CREATE TABLE $TABLE_CATEGORIES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT DEFAULT 'category',
        color TEXT DEFAULT '#F68B1F',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== TABLE PRODUCTS ==========
    await db.execute('''
    CREATE TABLE $TABLE_PRODUCTS (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT DEFAULT '',
      purchase_price REAL NOT NULL,  -- <-- HARGA BELI
      selling_price REAL NOT NULL,  -- <-- HARGA JUAL
      stock INTEGER DEFAULT 0,
      min_stock INTEGER DEFAULT 5,
      image_path TEXT DEFAULT '',
      barcode TEXT DEFAULT '',
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES $TABLE_CATEGORIES(id) ON DELETE CASCADE
    )
  ''');

    // ========== TABLE SERVICES ==========
    await db.execute('''
      CREATE TABLE $TABLE_SERVICES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        price REAL NOT NULL,
        duration INTEGER DEFAULT 30,
        image_path TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES $TABLE_CATEGORIES(id) ON DELETE CASCADE
      )
    ''');

    // ========== TABLE PACKAGES ==========
    await db.execute('''
      CREATE TABLE $TABLE_PACKAGES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        normal_price REAL NOT NULL,
        package_price REAL NOT NULL,
        image_path TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== TABLE PACKAGE DETAILS ==========
    await db.execute('''
      CREATE TABLE $TABLE_PACKAGE_DETAILS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (package_id) REFERENCES $TABLE_PACKAGES(id) ON DELETE CASCADE
      )
    ''');

    // ========== TABLE TRANSACTIONS ==========
    await db.execute('''
      CREATE TABLE $TABLE_TRANSACTIONS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        grand_total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        cash_amount REAL DEFAULT 0,
        change_amount REAL DEFAULT 0,
        qris_image_path TEXT DEFAULT '',
        status TEXT DEFAULT 'pending',
        cashier_name TEXT DEFAULT 'Kasir',
        customer_name TEXT DEFAULT '',
        notes TEXT DEFAULT '',
        transaction_date TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== TABLE TRANSACTION ITEMS ==========
    await db.execute('''
      CREATE TABLE $TABLE_TRANSACTION_ITEMS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        notes TEXT DEFAULT '',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (transaction_id) REFERENCES $TABLE_TRANSACTIONS(id) ON DELETE CASCADE
      )
    ''');

    // ========== TABLE SALON SETTINGS ==========
    await db.execute('''
      CREATE TABLE $TABLE_SALON_SETTINGS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        salon_name TEXT DEFAULT 'Salon Cantik',
        address TEXT DEFAULT '',
        phone TEXT DEFAULT '',
        email TEXT DEFAULT '',
        logo_path TEXT DEFAULT '',
        opening_time TEXT DEFAULT '09:00',
        closing_time TEXT DEFAULT '21:00',
        tax_percentage REAL DEFAULT 0,
        currency TEXT DEFAULT 'Rp',
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== TABLE PRINTER SETTINGS ==========
    await db.execute('''
      CREATE TABLE $TABLE_PRINTER_SETTINGS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        printer_name TEXT DEFAULT 'Thermal Printer',
        paper_size TEXT DEFAULT '58mm',
        is_connected INTEGER DEFAULT 0,
        bluetooth_address TEXT DEFAULT '',
        print_header TEXT DEFAULT '',
        print_footer TEXT DEFAULT 'Terima kasih telah berkunjung',
        show_logo INTEGER DEFAULT 1,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== TABLE PRINTER HISTORY (NEW) ==========
    await db.execute('''
      CREATE TABLE $TABLE_PRINTER_HISTORY (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        printed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_reprint INTEGER DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES $TABLE_TRANSACTIONS(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE qris_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant_name TEXT DEFAULT 'Salon Cantik',
        merchant_id TEXT DEFAULT '',
        qris_image_path TEXT DEFAULT '',
        qris_description TEXT DEFAULT 'Pembayaran QRIS',
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ========== INDEXES (NEW) ==========
    await db.execute('CREATE INDEX idx_transactions_date ON $TABLE_TRANSACTIONS(transaction_date)');
    await db.execute('CREATE INDEX idx_transactions_status ON $TABLE_TRANSACTIONS(status)');
    await db.execute('CREATE INDEX idx_transaction_items_transaction_id ON $TABLE_TRANSACTION_ITEMS(transaction_id)');
    await db.execute('CREATE INDEX idx_products_category ON $TABLE_PRODUCTS(category_id)');
    await db.execute('CREATE INDEX idx_services_category ON $TABLE_SERVICES(category_id)');
  }
}