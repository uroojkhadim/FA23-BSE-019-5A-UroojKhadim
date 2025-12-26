import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  String _syncStatus = AppConstants.syncStatusPending;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;

  String get syncStatus => _syncStatus;
  int get pendingSyncCount => _pendingSyncCount;
  bool get isSyncing => _isSyncing;

  SyncProvider() {
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    await _checkConnectivity();
    // Start periodic sync every 5 minutes
    _syncService.startPeriodicSync(const Duration(minutes: 5));
  }

  Future<void> _checkConnectivity() async {
    bool isOnline = await _syncService.checkConnectivity();
    _syncStatus = isOnline ? AppConstants.syncStatusCompleted : AppConstants.syncStatusPending;
    notifyListeners();
  }

  Future<bool> syncNow() async {
    _isSyncing = true;
    _syncStatus = AppConstants.syncStatusSyncing;
    notifyListeners();

    try {
      bool success = await _syncService.syncData();
      _syncStatus = success 
          ? AppConstants.syncStatusCompleted 
          : AppConstants.syncStatusFailed;
      
      _pendingSyncCount = await _syncService.getPendingSyncCount();
      notifyListeners();
      return success;
    } catch (e) {
      _syncStatus = AppConstants.syncStatusFailed;
      notifyListeners();
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> checkConnection() async {
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}