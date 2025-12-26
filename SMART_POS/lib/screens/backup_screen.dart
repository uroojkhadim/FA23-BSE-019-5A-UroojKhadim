import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../utils/constants.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;
  List<String> _localBackups = [];

  @override
  void initState() {
    super.initState();
    _loadLocalBackups();
  }

  Future<void> _loadLocalBackups() async {
    List<String> backups = await _backupService.getLocalBackups();
    setState(() {
      _localBackups = backups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backup section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup Data',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    const Text('Create backups of your data to prevent loss.'),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: _isCreatingBackup ? null : _createLocalBackup,
                      child: _isCreatingBackup
                          ? const CircularProgressIndicator()
                          : const Text('Create Local Backup'),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ElevatedButton(
                      onPressed: _isCreatingBackup ? null : _createCloudBackup,
                      child: _isCreatingBackup
                          ? const CircularProgressIndicator()
                          : const Text('Create Cloud Backup (Google Drive)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Restore section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restore Data',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    const Text('Restore your data from a backup file.'),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: _isRestoringBackup ? null : _restoreFromCloudBackup,
                      child: _isRestoringBackup
                          ? const CircularProgressIndicator()
                          : const Text('Restore from Cloud Backup'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Local backups section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local Backups',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    if (_localBackups.isEmpty)
                      const Text('No local backups found.')
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _localBackups.length,
                          itemBuilder: (context, index) {
                            String backupPath = _localBackups[index];
                            String fileName = backupPath.split('/').last;
                            return ListTile(
                              title: Text(fileName),
                              subtitle: Text('Created: ${fileName.split('backup_').last.split('.json').first}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.blue),
                                    onPressed: () => _restoreFromLocalBackup(backupPath),
                                    tooltip: 'Restore',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteLocalBackup(backupPath),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createLocalBackup() async {
    setState(() {
      _isCreatingBackup = true;
    });

    bool success = await _backupService.createLocalBackup();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local backup created successfully!'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
      await _loadLocalBackups(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create backup. Please try again.'),
          backgroundColor: Color(AppConstants.errorColorValue),
        ),
      );
    }

    setState(() {
      _isCreatingBackup = false;
    });
  }

  Future<void> _createCloudBackup() async {
    setState(() {
      _isCreatingBackup = true;
    });

    bool success = await _backupService.createCloudBackup();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud backup created successfully!'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create cloud backup. Please check your connection and try again.'),
          backgroundColor: Color(AppConstants.errorColorValue),
        ),
      );
    }

    setState(() {
      _isCreatingBackup = false;
    });
  }

  Future<void> _restoreFromLocalBackup(String backupPath) async {
    setState(() {
      _isRestoringBackup = true;
    });

    bool success = await _backupService.restoreFromLocalBackup(backupPath);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data restored successfully!'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restore data. Please try another backup file.'),
          backgroundColor: Color(AppConstants.errorColorValue),
        ),
      );
    }

    setState(() {
      _isRestoringBackup = false;
    });
  }

  Future<void> _restoreFromCloudBackup() async {
    setState(() {
      _isRestoringBackup = true;
    });

    bool success = await _backupService.restoreFromCloudBackup();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data restored successfully from cloud!'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restore data from cloud. Please check your connection and try again.'),
          backgroundColor: Color(AppConstants.errorColorValue),
        ),
      );
    }

    setState(() {
      _isRestoringBackup = false;
    });
  }

  Future<void> _deleteLocalBackup(String backupPath) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this backup? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      bool success = await _backupService.deleteLocalBackup(backupPath);
      if (success) {
        setState(() {
          _localBackups.remove(backupPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup deleted successfully!'),
            backgroundColor: Color(AppConstants.successColorValue),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete backup.'),
            backgroundColor: Color(AppConstants.errorColorValue),
          ),
        );
      }
    }
  }
}