import 'package:sqflite/sqflite.dart';
import '../models/accounting.dart';
import '../services/database_service.dart';

class AccountingService {
  final DatabaseService _databaseService = DatabaseService();

  // Create accounting entries table
  Future<void> createAccountingTables() async {
    final db = await _databaseService.database;
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS accounts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS accounting_entries(
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
  }

  // Account operations
  Future<int> insertAccount(Account account) async {
    final db = await _databaseService.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<Account?> getAccount(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  // Accounting entry operations
  Future<int> insertAccountingEntry(AccountingEntry entry) async {
    final db = await _databaseService.database;
    return await db.insert('accounting_entries', entry.toMap());
  }

  Future<List<AccountingEntry>> getAccountingEntriesByTransaction(String transactionId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounting_entries',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    
    return List.generate(maps.length, (i) => AccountingEntry.fromMap(maps[i]));
  }

  Future<List<AccountingEntry>> getAccountingEntriesByAccount(String accountId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounting_entries',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    
    return List.generate(maps.length, (i) => AccountingEntry.fromMap(maps[i]));
  }

  Future<List<AccountingEntry>> getAllAccountingEntries() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('accounting_entries');
    
    return List.generate(maps.length, (i) => AccountingEntry.fromMap(maps[i]));
  }

  Future<double> getAccountBalance(String accountId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounting_entries',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    
    double balance = 0.0;
    for (var map in maps) {
      final entry = AccountingEntry.fromMap(map);
      balance += (entry.credit - entry.debit);
    }
    
    return balance;
  }
}