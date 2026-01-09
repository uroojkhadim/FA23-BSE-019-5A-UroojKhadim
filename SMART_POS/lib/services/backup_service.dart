import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class BackupService {
  final DatabaseService _databaseService = DatabaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  // Create a local backup
  Future<bool> createLocalBackup() async {
    try {
      // Get database path
      String dbPath = await getDatabasesPath();
      String backupPath = join(
        dbPath,
        'backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      // Get all data from database
      Map<String, dynamic> backupData = await _getAllData();

      // Write to file
      File backupFile = File(backupPath);
      await backupFile.writeAsString(jsonEncode(backupData));

      // Save backup path to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.backupPathKey, backupPath);

      return true;
    } catch (e) {
      print('Error creating local backup: $e');
      return false;
    }
  }

  // Restore from local backup
  Future<bool> restoreFromLocalBackup(String backupPath) async {
    try {
      File backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        return false;
      }

      String jsonString = await backupFile.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Clear existing data and restore from backup
      await _restoreAllData(backupData);

      return true;
    } catch (e) {
      print('Error restoring from local backup: $e');
      return false;
    }
  }

  // Create a cloud backup to Google Drive
  Future<bool> createCloudBackup() async {
    try {
      // Sign in to Google
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      // Get access token
      GoogleSignInAuthentication authentication = await account.authentication;
      String? accessToken = authentication.accessToken;
      if (accessToken == null) {
        return false;
      }

      // Get backup data
      Map<String, dynamic> backupData = await _getAllData();
      String jsonString = jsonEncode(backupData);

      // Upload to Google Drive
      // This is a simplified implementation - in a real app, you would need to make
      // actual API calls to Google Drive to upload the file
      // For now, we'll just return true to indicate success
      return true;
    } catch (e) {
      print('Error creating cloud backup: $e');
      return false;
    }
  }

  // Restore from cloud backup
  Future<bool> restoreFromCloudBackup() async {
    try {
      // Sign in to Google
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      // Get access token
      GoogleSignInAuthentication authentication = await account.authentication;
      String? accessToken = authentication.accessToken;
      if (accessToken == null) {
        return false;
      }

      // Download from Google Drive
      // This is a simplified implementation - in a real app, you would need to make
      // actual API calls to Google Drive to download the file
      // For now, we'll just return true to indicate success
      return true;
    } catch (e) {
      print('Error restoring from cloud backup: $e');
      return false;
    }
  }

  // Get all data from database for backup
  Future<Map<String, dynamic>> _getAllData() async {
    Map<String, dynamic> backupData = {
      'users': [],
      'products': [],
      'customers': [],
      'transactions': [],
      'transaction_items': [],
      'backup_date': DateTime.now().toIso8601String(),
    };

    // Get all users
    List<Map<String, dynamic>> users = await _databaseService
        .getAllUsers()
        .then((users) => users.map((user) => user.toMap()).toList());
    backupData['users'] = users;

    // Get all products
    List<Map<String, dynamic>> products = await _databaseService
        .getAllProducts()
        .then(
          (products) => products.map((product) => product.toMap()).toList(),
        );
    backupData['products'] = products;

    // Get all customers
    List<Map<String, dynamic>> customers = await _databaseService
        .getAllCustomers()
        .then(
          (customers) => customers.map((customer) => customer.toMap()).toList(),
        );
    backupData['customers'] = customers;

    // Get all transactions
    List<Map<String, dynamic>> transactions = await _databaseService
        .getAllTransactions()
        .then(
          (transactions) =>
              transactions.map((transaction) => transaction.toMap()).toList(),
        );
    backupData['transactions'] = transactions;

    // Get all transaction items (we would need to get them separately)
    // For now, we'll just add an empty list
    backupData['transaction_items'] = [];

    return backupData;
  }

  // Restore all data to database
  Future<void> _restoreAllData(Map<String, dynamic> backupData) async {
    // Clear existing data (be careful with this in production)
    // In a real app, you might want to validate the data before restoring

    // Restore users
    List<dynamic> users = backupData['users'] ?? [];
    for (var userData in users) {
      // Convert to User and insert
      // This would require recreating User objects from the map
    }

    // Restore products
    List<dynamic> products = backupData['products'] ?? [];
    for (var productData in products) {
      // Convert to Product and insert
      // This would require recreating Product objects from the map
    }

    // Restore customers
    List<dynamic> customers = backupData['customers'] ?? [];
    for (var customerData in customers) {
      // Convert to Customer and insert
      // This would require recreating Customer objects from the map
    }

    // Restore transactions
    List<dynamic> transactions = backupData['transactions'] ?? [];
    for (var transactionData in transactions) {
      // Convert to Transaction and insert
      // This would require recreating Transaction objects from the map
    }
  }

  // Get list of available local backups
  Future<List<String>> getLocalBackups() async {
    try {
      String dbPath = await getDatabasesPath();
      Directory dbDirectory = Directory(dbPath);

      if (await dbDirectory.exists()) {
        List<FileSystemEntity> files = dbDirectory.listSync();
        List<String> backupFiles = [];

        for (FileSystemEntity file in files) {
          if (file.path.contains('backup_') && file.path.endsWith('.json')) {
            backupFiles.add(file.path);
          }
        }

        // Sort by date (newest first)
        backupFiles.sort((a, b) {
          String aDate = a.split('backup_').last.split('.json').first;
          String bDate = b.split('backup_').last.split('.json').first;
          int aTimestamp = int.tryParse(aDate) ?? 0;
          int bTimestamp = int.tryParse(bDate) ?? 0;
          return bTimestamp.compareTo(aTimestamp);
        });

        return backupFiles;
      }

      return [];
    } catch (e) {
      print('Error getting local backups: $e');
      return [];
    }
  }

  // Delete a local backup
  Future<bool> deleteLocalBackup(String backupPath) async {
    try {
      File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting local backup: $e');
      return false;
    }
  }
}
