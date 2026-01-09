import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/product.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const int _version = 2;
  static const String _dbName = 'smart_pos.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      // Create accounts table for accounting
      await db.execute('''
        CREATE TABLE accounts(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          balance REAL NOT NULL,
          description TEXT
        )
      ''');

      // Create accounting_entries table for accounting
      await db.execute('''
        CREATE TABLE accounting_entries(
          id TEXT PRIMARY KEY,
          transactionId TEXT NOT NULL,
          accountId TEXT NOT NULL,
          accountName TEXT NOT NULL,
          debit REAL NOT NULL,
          credit REAL NOT NULL,
          date TEXT NOT NULL,
          description TEXT,
          FOREIGN KEY (accountId) REFERENCES accounts (id)
        )
      ''');

      // Create inventory_transactions table for enhanced inventory
      await db.execute('''
        CREATE TABLE inventory_transactions(
          id TEXT PRIMARY KEY,
          productId TEXT NOT NULL,
          productName TEXT NOT NULL,
          transactionType TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unitCost REAL NOT NULL,
          totalCost REAL NOT NULL,
          date TEXT NOT NULL,
          referenceId TEXT,
          notes TEXT
        )
      ''');

      // Create product_variants table for enhanced inventory
      await db.execute('''
        CREATE TABLE product_variants(
          id TEXT PRIMARY KEY,
          productId TEXT NOT NULL,
          variantName TEXT NOT NULL,
          variantValue TEXT NOT NULL,
          sku TEXT UNIQUE NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          cost REAL NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        phone TEXT,
        role TEXT DEFAULT 'cashier',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT UNIQUE NOT NULL,
        price REAL NOT NULL,
        cost REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create customers table
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        totalPurchase REAL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT UNIQUE NOT NULL,
        customerId INTEGER,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL NOT NULL,
        total REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        notes TEXT,
        isOnline INTEGER DEFAULT 0,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    // Create transaction_items table
    await db.execute('''
      CREATE TABLE transaction_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId TEXT NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES transactions (transactionId),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Create accounts table for accounting
    await db.execute('''
      CREATE TABLE accounts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL,
        description TEXT
      )
    ''');

    // Create accounting_entries table for accounting
    await db.execute('''
      CREATE TABLE accounting_entries(
        id TEXT PRIMARY KEY,
        transactionId TEXT NOT NULL,
        accountId TEXT NOT NULL,
        accountName TEXT NOT NULL,
        debit REAL NOT NULL,
        credit REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    // Create inventory_transactions table for enhanced inventory
    await db.execute('''
      CREATE TABLE inventory_transactions(
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        transactionType TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitCost REAL NOT NULL,
        totalCost REAL NOT NULL,
        date TEXT NOT NULL,
        referenceId TEXT,
        notes TEXT
      )
    ''');

    // Create product_variants table for enhanced inventory
    await db.execute('''
      CREATE TABLE product_variants(
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        variantName TEXT NOT NULL,
        variantValue TEXT NOT NULL,
        sku TEXT UNIQUE NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        cost REAL NOT NULL
      )
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product?> getProductBySku(String sku) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Customer operations
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<Customer?> getCustomerByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');

    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> addToCustomerTotalPurchase(int customerId, double amount) async {
    try {
      final db = await database;
      // Get current customer
      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [customerId],
      );

      if (maps.isNotEmpty) {
        final currentTotal =
            (maps.first['totalPurchase'] as num?)?.toDouble() ?? 0.0;
        final newTotal = currentTotal + amount;

        // Update customer with new total
        await db.update(
          'customers',
          {'totalPurchase': newTotal},
          where: 'id = ?',
          whereArgs: [customerId],
        );

        return true;
      }

      return false;
    } catch (e) {
      print('Error adding to customer total purchase: $e');
      return false;
    }
  }

  // Transaction operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Transaction?> getTransaction(String transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transactionDate BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'transactionId = ?',
      whereArgs: [transaction.transactionId],
    );
  }

  Future<int> deleteTransaction(String transactionId) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }

  // Transaction Item operations
  Future<int> insertTransactionItem(TransactionItem item) async {
    final db = await database;
    return await db.insert('transaction_items', item.toMap());
  }

  Future<List<TransactionItem>> getTransactionItems(
    String transactionId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );

    return List.generate(maps.length, (i) => TransactionItem.fromMap(maps[i]));
  }

  Future<int> deleteTransactionItems(String transactionId) async {
    final db = await database;
    return await db.delete(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
