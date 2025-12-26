import '../models/transaction.dart';
import '../models/transaction_item.dart';
import 'database_service.dart';

class TransactionService {
  final DatabaseService _databaseService = DatabaseService();

  // Add a new transaction
  Future<String> addTransaction(Transaction transaction) async {
    int result = await _databaseService.insertTransaction(transaction);
    if (result != 0) {
      return transaction.transactionId;
    }
    return '';
  }

  // Get a transaction by ID
  Future<Transaction?> getTransaction(String transactionId) async {
    return await _databaseService.getTransaction(transactionId);
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    return await _databaseService.getAllTransactions();
  }

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    return await _databaseService.getTransactionsByDateRange(start, end);
  }

  // Update a transaction
  Future<int> updateTransaction(Transaction transaction) async {
    return await _databaseService.updateTransaction(transaction);
  }

  // Delete a transaction
  Future<int> deleteTransaction(String transactionId) async {
    // First delete related transaction items
    await _databaseService.deleteTransactionItems(transactionId);
    // Then delete the transaction
    return await _databaseService.deleteTransaction(transactionId);
  }

  // Add transaction item
  Future<int> addTransactionItem(TransactionItem item) async {
    return await _databaseService.insertTransactionItem(item);
  }

  // Get transaction items for a transaction
  Future<List<TransactionItem>> getTransactionItems(String transactionId) async {
    return await _databaseService.getTransactionItems(transactionId);
  }

  // Get total sales for a date range
  Future<double> getTotalSales({DateTime? startDate, DateTime? endDate}) async {
    List<Transaction> transactions = await _databaseService.getAllTransactions();
    
    DateTime start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime end = endDate ?? DateTime.now();
    
    double total = 0.0;
    for (Transaction transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate.toIso8601String());
      if (transactionDate.isAfter(start) && transactionDate.isBefore(end.add(const Duration(days: 1)))) {
        if (transaction.status == 'completed') {
          total += transaction.total;
        }
      }
    }
    
    return total;
  }

  // Get total number of transactions for a date range
  Future<int> getTransactionCount({DateTime? startDate, DateTime? endDate}) async {
    List<Transaction> transactions = await _databaseService.getAllTransactions();
    
    DateTime start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime end = endDate ?? DateTime.now();
    
    int count = 0;
    for (Transaction transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate.toIso8601String());
      if (transactionDate.isAfter(start) && transactionDate.isBefore(end.add(const Duration(days: 1)))) {
        if (transaction.status == 'completed') {
          count++;
        }
      }
    }
    
    return count;
  }

  // Get sales by date
  Future<Map<DateTime, double>> getSalesByDate({DateTime? startDate, DateTime? endDate}) async {
    List<Transaction> transactions = await _databaseService.getAllTransactions();
    
    DateTime start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime end = endDate ?? DateTime.now();
    
    Map<DateTime, double> salesByDate = {};
    
    for (Transaction transaction in transactions) {
      DateTime transactionDate = DateTime(
        transaction.transactionDate.year, 
        transaction.transactionDate.month, 
        transaction.transactionDate.day
      );
      
      if (transactionDate.isAfter(start.subtract(const Duration(days: 1))) && 
          transactionDate.isBefore(end.add(const Duration(days: 1)))) {
        if (transaction.status == 'completed') {
          if (salesByDate.containsKey(transactionDate)) {
            salesByDate[transactionDate] = salesByDate[transactionDate]! + transaction.total;
          } else {
            salesByDate[transactionDate] = transaction.total;
          }
        }
      }
    }
    
    return salesByDate;
  }

  // Get top selling products
  Future<Map<String, int>> getTopSellingProducts({DateTime? startDate, DateTime? endDate}) async {
    List<Transaction> transactions = await _databaseService.getAllTransactions();
    
    DateTime start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime end = endDate ?? DateTime.now();
    
    Map<String, int> productSales = {};
    
    for (Transaction transaction in transactions) {
      DateTime transactionDate = transaction.transactionDate;
      
      if (transactionDate.isAfter(start.subtract(const Duration(days: 1))) && 
          transactionDate.isBefore(end.add(const Duration(days: 1)))) {
        if (transaction.status == 'completed') {
          List<TransactionItem> items = await getTransactionItems(transaction.transactionId);
          for (TransactionItem item in items) {
            if (productSales.containsKey(item.productName)) {
              productSales[item.productName] = productSales[item.productName]! + item.quantity;
            } else {
              productSales[item.productName] = item.quantity;
            }
          }
        }
      }
    }
    
    return productSales;
  }
}