import 'package:sqflite/sqflite.dart';
import '../models/inventory.dart';
import '../services/database_service.dart';

class InventoryService {
  final DatabaseService _databaseService = DatabaseService();

  // Create inventory tables
  Future<void> createInventoryTables() async {
    final db = await _databaseService.database;
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_transactions(
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_variants(
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

  // Inventory transaction operations
  Future<int> insertInventoryTransaction(InventoryTransaction transaction) async {
    final db = await _databaseService.database;
    return await db.insert('inventory_transactions', transaction.toMap());
  }

  Future<List<InventoryTransaction>> getInventoryTransactionsByProduct(String productId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_transactions',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  Future<List<InventoryTransaction>> getInventoryTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  Future<List<InventoryTransaction>> getAllInventoryTransactions() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_transactions',
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => InventoryTransaction.fromMap(maps[i]));
  }

  // Product variant operations
  Future<int> insertProductVariant(ProductVariant variant) async {
    final db = await _databaseService.database;
    return await db.insert('product_variants', variant.toMap());
  }

  Future<ProductVariant?> getProductVariant(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_variants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProductVariant.fromMap(maps.first);
    }
    return null;
  }

  Future<ProductVariant?> getProductVariantBySku(String sku) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_variants',
      where: 'sku = ?',
      whereArgs: [sku],
    );

    if (maps.isNotEmpty) {
      return ProductVariant.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ProductVariant>> getProductVariantsByProduct(String productId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_variants',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    
    return List.generate(maps.length, (i) => ProductVariant.fromMap(maps[i]));
  }

  Future<List<ProductVariant>> getAllProductVariants() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('product_variants');
    
    return List.generate(maps.length, (i) => ProductVariant.fromMap(maps[i]));
  }

  Future<int> updateProductVariantQuantity(String variantId, int newQuantity) async {
    final db = await _databaseService.database;
    return await db.update(
      'product_variants',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [variantId],
    );
  }

  // Get current inventory level for a product
  Future<int> getCurrentInventoryLevel(String productId) async {
    final db = await _databaseService.database;
    
    // First, get all inventory transactions for this product
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory_transactions',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    
    int totalQuantity = 0;
    for (var map in maps) {
      final transaction = InventoryTransaction.fromMap(map);
      if (transaction.transactionType == 'in' || transaction.transactionType == 'adjustment') {
        totalQuantity += transaction.quantity;
      } else if (transaction.transactionType == 'out' || transaction.transactionType == 'damage') {
        totalQuantity -= transaction.quantity;
      }
    }
    
    // Add any product variants quantities
    final List<Map<String, dynamic>> variantMaps = await db.query(
      'product_variants',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    
    for (var map in variantMaps) {
      totalQuantity += (map['quantity'] as int?) ?? 0;
    }
    
    return totalQuantity;
  }

  // Get low stock products
  Future<List<Map<String, dynamic>>> getLowStockProducts({int threshold = 10}) async {
    final db = await _databaseService.database;
    
    // Get products with quantity below threshold
    final List<Map<String, dynamic>> productMaps = await db.query(
      'products',
      columns: ['id', 'name', 'quantity', 'sku'],
    );
    
    List<Map<String, dynamic>> lowStockProducts = [];
    
    for (var productMap in productMaps) {
      int currentQuantity = await getCurrentInventoryLevel(productMap['id']);
      if (currentQuantity <= threshold) {
        lowStockProducts.add({
          'id': productMap['id'],
          'name': productMap['name'],
          'sku': productMap['sku'],
          'currentQuantity': currentQuantity,
        });
      }
    }
    
    return lowStockProducts;
  }
}