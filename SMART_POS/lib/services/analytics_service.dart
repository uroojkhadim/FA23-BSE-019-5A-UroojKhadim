import '../services/database_service.dart';

class AnalyticsService {
  final DatabaseService _databaseService = DatabaseService();

  // Sales analytics
  Future<Map<String, dynamic>> getSalesSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;

    String dateCondition = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateCondition = 'WHERE transactionDate BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      dateCondition = 'WHERE transactionDate >= ?';
      dateArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      dateCondition = 'WHERE transactionDate <= ?';
      dateArgs = [endDate.toIso8601String()];
    }

    // Total sales
    final List<Map<String, dynamic>> totalSalesResult = await db.rawQuery(
      'SELECT SUM(total) as totalSales, COUNT(*) as transactionCount FROM transactions $dateCondition',
      dateArgs,
    );

    // Total items sold
    final List<Map<String, dynamic>> totalItemsResult = await db.rawQuery(
      'SELECT SUM(quantity) as totalItems FROM transaction_items ti '
      'JOIN transactions t ON ti.transactionId = t.transactionId $dateCondition',
      dateArgs,
    );

    // Top selling products
    final List<Map<String, dynamic>> topProductsResult = await db.rawQuery(
      'SELECT ti.productName, SUM(ti.quantity) as totalQuantity, SUM(ti.total) as totalRevenue '
      'FROM transaction_items ti '
      'JOIN transactions t ON ti.transactionId = t.transactionId $dateCondition '
      'GROUP BY ti.productId ORDER BY totalQuantity DESC LIMIT 5',
      dateArgs,
    );

    return {
      'totalSales':
          (totalSalesResult.first['totalSales'] as num?)?.toDouble() ?? 0.0,
      'transactionCount':
          (totalSalesResult.first['transactionCount'] as int?) ?? 0,
      'totalItemsSold': (totalItemsResult.first['totalItems'] as int?) ?? 0,
      'topProducts': topProductsResult,
    };
  }

  // Customer analytics
  Future<Map<String, dynamic>> getCustomerAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;

    String dateCondition = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateCondition = 'WHERE t.transactionDate BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      dateCondition = 'WHERE t.transactionDate >= ?';
      dateArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      dateCondition = 'WHERE t.transactionDate <= ?';
      dateArgs = [endDate.toIso8601String()];
    }

    // Top customers by purchase amount
    final List<Map<String, dynamic>> topCustomersResult = await db.rawQuery(
      'SELECT c.name, c.email, c.phone, SUM(t.total) as totalSpent, COUNT(t.id) as transactionCount '
      'FROM customers c '
      'JOIN transactions t ON c.id = t.customerId $dateCondition '
      'GROUP BY c.id ORDER BY totalSpent DESC LIMIT 10',
      dateArgs,
    );

    // Customer count
    final List<Map<String, dynamic>> customerCountResult = await db.rawQuery(
      'SELECT COUNT(*) as customerCount FROM customers',
    );

    // New customers in period
    final List<Map<String, dynamic>> newCustomersResult = await db.rawQuery(
      'SELECT COUNT(*) as newCustomerCount FROM customers '
      'WHERE createdAt BETWEEN ? AND ?',
      [
        (startDate ?? DateTime.now().subtract(const Duration(days: 30)))
            .toIso8601String(),
        (endDate ?? DateTime.now()).toIso8601String(),
      ],
    );

    return {
      'topCustomers': topCustomersResult,
      'totalCustomers':
          (customerCountResult.first['customerCount'] as int?) ?? 0,
      'newCustomers':
          (newCustomersResult.first['newCustomerCount'] as int?) ?? 0,
    };
  }

  // Product analytics
  Future<Map<String, dynamic>> getProductAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;

    String dateCondition = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateCondition = 'WHERE t.transactionDate BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      dateCondition = 'WHERE t.transactionDate >= ?';
      dateArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      dateCondition = 'WHERE t.transactionDate <= ?';
      dateArgs = [endDate.toIso8601String()];
    }

    // Best selling products
    final List<Map<String, dynamic>> bestSellingResult = await db.rawQuery(
      'SELECT ti.productId, ti.productName, SUM(ti.quantity) as totalQuantity, SUM(ti.total) as totalRevenue '
      'FROM transaction_items ti '
      'JOIN transactions t ON ti.transactionId = t.transactionId $dateCondition '
      'GROUP BY ti.productId ORDER BY totalQuantity DESC LIMIT 10',
      dateArgs,
    );

    // Products with highest revenue
    final List<Map<String, dynamic>> highestRevenueResult = await db.rawQuery(
      'SELECT ti.productId, ti.productName, SUM(ti.total) as totalRevenue, SUM(ti.quantity) as totalQuantity '
      'FROM transaction_items ti '
      'JOIN transactions t ON ti.transactionId = t.transactionId $dateCondition '
      'GROUP BY ti.productId ORDER BY totalRevenue DESC LIMIT 10',
      dateArgs,
    );

    // Low stock products
    final List<Map<String, dynamic>> lowStockResult = await db.query(
      'products',
      where: 'quantity <= ?',
      whereArgs: [5], // threshold for low stock
    );

    return {
      'bestSellingProducts': bestSellingResult,
      'highestRevenueProducts': highestRevenueResult,
      'lowStockProducts': lowStockResult,
    };
  }

  // Daily sales trend
  Future<List<Map<String, dynamic>>> getDailySalesTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DATE(transactionDate) as date, SUM(total) as dailyTotal, COUNT(*) as transactionCount '
      'FROM transactions '
      'WHERE transactionDate BETWEEN ? AND ? '
      'GROUP BY DATE(transactionDate) '
      'ORDER BY date',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return result;
  }

  // Monthly sales summary
  Future<List<Map<String, dynamic>>> getMonthlySalesSummary({
    required int year,
  }) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT '
      'strftime(\'%m\', transactionDate) as month, '
      'SUM(total) as monthlyTotal, '
      'COUNT(*) as transactionCount, '
      'AVG(total) as averageTransactionValue '
      'FROM transactions '
      'WHERE strftime(\'%Y\', transactionDate) = ? '
      'GROUP BY strftime(\'%m\', transactionDate) '
      'ORDER BY month',
      [year.toString()],
    );

    return result;
  }

  // Payment method analysis
  Future<Map<String, dynamic>> getPaymentMethodAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;

    String dateCondition = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateCondition = 'WHERE transactionDate BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      dateCondition = 'WHERE transactionDate >= ?';
      dateArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      dateCondition = 'WHERE transactionDate <= ?';
      dateArgs = [endDate.toIso8601String()];
    }

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT paymentMethod, COUNT(*) as count, SUM(total) as totalAmount '
      'FROM transactions $dateCondition '
      'GROUP BY paymentMethod',
      dateArgs,
    );

    return {'paymentMethods': result};
  }
}
