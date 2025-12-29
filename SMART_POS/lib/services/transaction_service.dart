import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/accounting.dart';
import 'database_service.dart';
import 'accounting_service.dart';

class TransactionService {
  final DatabaseService _databaseService = DatabaseService();
  final AccountingService _accountingService = AccountingService();

  // Add a new transaction
  Future<String> addTransaction(Transaction transaction) async {
    int result = await _databaseService.insertTransaction(transaction);
    if (result != 0) {
      // Create accounting entries for the transaction
      await _createAccountingEntries(transaction);
      
      // Update customer's total purchase if customer exists
      if (transaction.customerId != null) {
        await _updateCustomerTotalPurchase(transaction.customerId!, transaction.total);
      }
      
      return transaction.transactionId;
    }
    return '';
  }
  
  // Update customer's total purchase
  Future<void> _updateCustomerTotalPurchase(int customerId, double amount) async {
    try {
      await _databaseService.addToCustomerTotalPurchase(customerId, amount);
    } catch (e) {
      print('Error updating customer total purchase: $e');
    }
  }
  
  // Create accounting entries for a transaction
  Future<void> _createAccountingEntries(Transaction transaction) async {
    // Create revenue account entry
    final revenueEntry = AccountingEntry(
      id: 'revenue_${transaction.transactionId}',
      transactionId: transaction.transactionId,
      accountId: 'revenue',
      accountName: 'Revenue',
      debit: 0.0,
      credit: transaction.total,
      date: transaction.transactionDate,
      description: 'Revenue from transaction ${transaction.transactionId}',
    );
    await _accountingService.insertAccountingEntry(revenueEntry);
    
    // Create cash/credit account entry
    final cashEntry = AccountingEntry(
      id: 'cash_${transaction.transactionId}',
      transactionId: transaction.transactionId,
      accountId: transaction.paymentMethod.toLowerCase(),
      accountName: '${transaction.paymentMethod} Account',
      debit: transaction.total,
      credit: 0.0,
      date: transaction.transactionDate,
      description: 'Cash received from transaction ${transaction.transactionId}',
    );
    await _accountingService.insertAccountingEntry(cashEntry);
    
    // Create tax liability account entry
    if (transaction.tax > 0) {
      final taxEntry = AccountingEntry(
        id: 'tax_${transaction.transactionId}',
        transactionId: transaction.transactionId,
        accountId: 'tax_liability',
        accountName: 'Tax Liability',
        debit: 0.0,
        credit: transaction.tax,
        date: transaction.transactionDate,
        description: 'Tax liability from transaction ${transaction.transactionId}',
      );
      await _accountingService.insertAccountingEntry(taxEntry);
    }
    
    // Create discount expense account entry
    if (transaction.discount > 0) {
      final discountEntry = AccountingEntry(
        id: 'discount_${transaction.transactionId}',
        transactionId: transaction.transactionId,
        accountId: 'discount_expense',
        accountName: 'Discount Expense',
        debit: transaction.discount,
        credit: 0.0,
        date: transaction.transactionDate,
        description: 'Discount expense from transaction ${transaction.transactionId}',
      );
      await _accountingService.insertAccountingEntry(discountEntry);
    }
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