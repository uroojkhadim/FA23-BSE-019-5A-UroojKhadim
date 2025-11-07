import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'todays_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'progress_screen.dart';
import 'import_screen.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';
import '../services/google_drive_service.dart';
import '../models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  MainScreen({
    Key? key,
    this.isDarkMode = false,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 
        ? _TasksTabBar() 
        : _currentIndex == 1 
          ? ProgressScreen() 
          : SettingsScreen(
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _TasksTabBar extends StatefulWidget {
  @override
  __TasksTabBarState createState() => __TasksTabBarState();
}

class __TasksTabBarState extends State<_TasksTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All Tasks'),
              Tab(text: 'Today'),
              Tab(text: 'Completed'),
              Tab(text: 'Repeated'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TaskListScreen(),
            TodaysTasksScreen(),
            CompletedTasksScreen(),
            RepeatedTasksScreen(),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  SettingsScreen({
    Key? key,
    this.isDarkMode = false,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _defaultSortOrder = 'date';
  bool _autoBackupEnabled = false;
  bool _isSignedIn = false;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkSignInStatus();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _defaultSortOrder = prefs.getString('defaultSortOrder') ?? 'date';
      _autoBackupEnabled = prefs.getBool('autoBackupEnabled') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('defaultSortOrder', _defaultSortOrder);
    await prefs.setBool('autoBackupEnabled', _autoBackupEnabled);
  }

  Future<void> _checkSignInStatus() async {
    final isSignedIn = await GoogleDriveService().isSignedIn();
    setState(() {
      _isSignedIn = isSignedIn;
    });
  }

  Future<void> _handleGoogleDriveSignIn() async {
    if (_isSignedIn) {
      // Sign out
      await GoogleDriveService().signOut();
    } else {
      // Sign in
      final success = await GoogleDriveService().signIn();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signed in to Google Drive')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign in to Google Drive')),
          );
        }
      }
    }
    _checkSignInStatus();
  }

  Future<void> _exportTasks() async {
    try {
      final tasks = await DatabaseService.instance.getAllTasks();
      final filePath = await ExportService().exportTasksToCSV(tasks);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tasks exported to: $filePath'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export tasks: $e')),
        );
      }
    }
  }

  Future<void> _importTasks() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportScreen(),
      ),
    );
  }

  Future<void> _backupToGoogleDrive() async {
    try {
      final tasks = await DatabaseService.instance.getAllTasks();
      final fileId = await GoogleDriveService().backupTasks(tasks);
      
      if (fileId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup to Google Drive successful')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to backup to Google Drive')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during backup: $e')),
        );
      }
    }
  }

  Future<void> _clearAllTasks() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Tasks'),
          content: Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Clear All'),
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseService.instance.deleteAllTasks();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All tasks have been cleared')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Theme Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Dark Mode'),
                      trailing: Switch(
                        value: widget.isDarkMode,
                        onChanged: (value) {
                          widget.onThemeChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Notification Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Enable Reminders'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          _savePreferences();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Sort Order Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Sort Order',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Sort by Date'),
                      leading: Radio<String>(
                        value: 'date',
                        groupValue: _defaultSortOrder,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _defaultSortOrder = value;
                            });
                            _savePreferences();
                          }
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _defaultSortOrder = 'date';
                        });
                        _savePreferences();
                      },
                    ),
                    ListTile(
                      title: Text('Sort by Priority'),
                      leading: Radio<String>(
                        value: 'priority',
                        groupValue: _defaultSortOrder,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _defaultSortOrder = value;
                            });
                            _savePreferences();
                          }
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _defaultSortOrder = 'priority';
                        });
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Import/Export Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Management',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Import Tasks'),
                      subtitle: Text('Import tasks from CSV file'),
                      trailing: Icon(Icons.file_download),
                      onTap: _importTasks,
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Export Tasks'),
                      subtitle: Text('Export all tasks to CSV file'),
                      trailing: Icon(Icons.file_upload),
                      onTap: _exportTasks,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Backup Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Auto Backup'),
                      subtitle: Text(_isSignedIn
                          ? 'Automatically backup tasks to Google Drive'
                          : 'Sign in to Google Drive to enable auto backup'),
                      trailing: Switch(
                        value: _autoBackupEnabled && _isSignedIn,
                        onChanged: _isSignedIn
                            ? (value) {
                                setState(() {
                                  _autoBackupEnabled = value;
                                });
                                _savePreferences();
                              }
                            : null,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Google Drive Backup'),
                      subtitle: Text(_isSignedIn
                          ? 'Backup tasks to Google Drive'
                          : 'Sign in to enable backup'),
                      trailing: _isSignedIn
                          ? Icon(Icons.cloud_upload)
                          : Icon(Icons.cloud_off),
                      onTap: _isSignedIn ? _backupToGoogleDrive : null,
                    ),
                    Divider(),
                    ListTile(
                      title: Text(_isSignedIn
                          ? 'Sign Out of Google Drive'
                          : 'Sign In to Google Drive'),
                      subtitle: Text(_isSignedIn
                          ? 'Currently signed in'
                          : 'Sign in to enable backup and sync'),
                      trailing: Icon(
                          _isSignedIn ? Icons.logout : Icons.login),
                      onTap: _handleGoogleDriveSignIn,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Reset Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Clear All Tasks'),
                      subtitle: Text('Delete all tasks from the app'),
                      trailing: Icon(Icons.delete_forever),
                      onTap: _clearAllTasks,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // About Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('App Version'),
                      subtitle: Text('v$_appVersion'),
                    ),
                    ListTile(
                      title: Text('Developer'),
                      subtitle: Text('Task Management App'),
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
}