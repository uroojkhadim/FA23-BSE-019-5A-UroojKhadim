import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/user.dart';
import 'database_service.dart';

class SyncService {
  final DatabaseService _databaseService = DatabaseService();
  bool _isOnline = false;
  Timer? _syncTimer;

  // Check network connectivity
  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    return _isOnline;
  }

  // Start periodic sync
  void startPeriodicSync(Duration interval) {
    _syncTimer = Timer.periodic(interval, (timer) {
      syncData();
    });
  }

  // Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  // Sync data when connection is restored
  Future<bool> syncData() async {
    try {
      bool isConnected = await checkConnectivity();
      if (!isConnected) {
        return false;
      }

      // Sync products
      await _syncProducts();
      
      // Sync customers
      await _syncCustomers();
      
      // Sync transactions
      await _syncTransactions();

      return true;
    } catch (e) {
      print('Error syncing data: $e');
      return false;
    }
  }

  // Sync products
  Future<void> _syncProducts() async {
    // Get offline products that need to be synced
    List<Product> offlineProducts = await _databaseService.getAllProducts();
    
    for (Product product in offlineProducts) {
      try {
        // In a real implementation, you would send this to your backend API
        // await _sendProductToServer(product);
        
        // Mark as synced (in a real implementation, you would update a synced field)
        await _databaseService.updateProduct(product);
      } catch (e) {
        print('Error syncing product ${product.id}: $e');
        // Handle sync error - maybe queue for later retry
      }
    }
  }

  // Sync customers
  Future<void> _syncCustomers() async {
    // Get offline customers that need to be synced
    List<Customer> offlineCustomers = await _databaseService.getAllCustomers();
    
    for (Customer customer in offlineCustomers) {
      try {
        // In a real implementation, you would send this to your backend API
        // await _sendCustomerToServer(customer);
        
        // Mark as synced (in a real implementation, you would update a synced field)
        await _databaseService.updateCustomer(customer);
      } catch (e) {
        print('Error syncing customer ${customer.id}: $e');
        // Handle sync error - maybe queue for later retry
      }
    }
  }

  // Sync transactions
  Future<void> _syncTransactions() async {
    // Get offline transactions that need to be synced
    List<Transaction> offlineTransactions = await _databaseService.getAllTransactions();
    
    for (Transaction transaction in offlineTransactions) {
      try {
        // In a real implementation, you would send this to your backend API
        // await _sendTransactionToServer(transaction);
        
        // Mark as synced (in a real implementation, you would update a synced field)
        await _databaseService.updateTransaction(transaction);
      } catch (e) {
        print('Error syncing transaction ${transaction.transactionId}: $e');
        // Handle sync error - maybe queue for later retry
      }
    }
  }

  // Handle offline mode - mark transactions as offline
  Future<void> markAsOffline() async {
    _isOnline = false;
    // In a real implementation, you would update all pending transactions
    // to indicate they are offline and need to be synced later
  }

  // Handle online mode - initiate sync
  Future<void> markAsOnline() async {
    _isOnline = true;
    // Immediately sync data when connection is restored
    await syncData();
  }

  // Check if device is currently online
  bool get isOnline => _isOnline;

  // Get sync status
  String getSyncStatus() {
    if (_isOnline) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  // Get pending sync count
  Future<int> getPendingSyncCount() async {
    // In a real implementation, this would count records that have not been synced
    // For now, returning 0
    return 0;
  }

  // Handle conflicts when syncing
  Future<void> handleSyncConflict(String type, dynamic localData, dynamic serverData) async {
    // In a real implementation, you would implement conflict resolution logic
    // For example, last write wins, or merge changes
    print('Sync conflict detected for $type. Local: $localData, Server: $serverData');
  }

  // Close the sync service
  void dispose() {
    stopPeriodicSync();
  }
}